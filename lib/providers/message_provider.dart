import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../models/message.dart';
import '../models/association.dart';
import '../models/user.dart';
import './user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessageProvider with ChangeNotifier {
  final UserProvider userProvider;
  late WebSocketService _webSocketService;
  final Map<String, List<Message>> _messages = {};
  bool _isConnected = false;
  Association? _currentAssociation;
  List<Association> _userAssociations = [];
  final Map<String, int> _unreadCounts = {};
  final Set<String> _readMessageIds = {};

  MessageProvider({required this.userProvider}) {
    _initWebSocket();
  }

  List<Association> get userAssociations => _userAssociations;

  String get baseUrl => userProvider.baseUrl;

  Association? get currentAssociation => _currentAssociation;

  void _initWebSocket() {
    _webSocketService = WebSocketService(
      token: userProvider.token ?? '',
    );

    _webSocketService.onMessageReceived = _handleNewMessage;
    _webSocketService.onConnectionClosed = _handleConnectionClosed;
    _webSocketService.onError = _handleError;

    connect();
  }

  Future<void> loadUserAssociations() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${userProvider.baseUrl}/users/${userProvider.userData!['id']}/associations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userProvider.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _userAssociations =
            data.map((json) => Association.fromJson(json)).toList();

        // Charger les messages non lus pour chaque association
        for (var association in _userAssociations) {
          await loadMessages(association.id);
        }

        notifyListeners();
      } else {
        throw Exception('Échec du chargement des associations');
      }
    } catch (error) {
      debugPrint('Error loading associations: $error');
      rethrow;
    }
  }

  Future<void> loadMessages(String associationId) async {
    try {
      // Charger les détails de l'association
      final associationResponse = await http.get(
        Uri.parse('${userProvider.baseUrl}/associations/$associationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userProvider.token}',
        },
      );

      if (associationResponse.statusCode == 200) {
        _currentAssociation =
            Association.fromJson(jsonDecode(associationResponse.body));
      }

      // Charger les messages
      final response = await http.get(
        Uri.parse(
            '${userProvider.baseUrl}/messages/association/$associationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userProvider.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _messages[associationId] =
            data.map((json) => Message.fromJson(json)).toList();
        _updateUnreadCount(associationId);
        notifyListeners();
      } else {
        throw Exception('Échec du chargement des messages');
      }
    } catch (error) {
      debugPrint('Error loading messages: $error');
      rethrow;
    }
  }

  void connect() {
    if (!_isConnected) {
      _webSocketService.connect();
      _isConnected = true;
      notifyListeners();
    }
  }

  void _handleNewMessage(Message message) {
    final associationId = message.associationId;
    if (!_messages.containsKey(associationId)) {
      _messages[associationId] = [];
    }

    // Ne pas ajouter le message si c'est nous qui l'avons envoyé
    if (message.senderId == userProvider.userData!['id']) {
      // Mettre à jour uniquement le statut du message existant
      final existingIndex = _messages[associationId]!.indexWhere((m) => m.id == message.id);
      if (existingIndex != -1) {
        _messages[associationId]![existingIndex] = message.copyWith(status: MessageStatus.sent);
        notifyListeners();
      }
      return;
    }

    // Sinon, ajouter le nouveau message reçu
    _messages[associationId]!.add(message);
    _updateUnreadCount(associationId);
    notifyListeners();
  }

  void _handleConnectionClosed() {
    _isConnected = false;
    notifyListeners();
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content, String associationId) async {
    // Créer le message local
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: userProvider.userData!['id'],
      associationId: associationId,
      createdAt: DateTime.now(),
      sender: User.fromJson(userProvider.userData!),
      association: _currentAssociation ?? Association.fromJson({}),
      status: MessageStatus.sending,
    );

    try {
      // Ajouter le message localement avec status "sending"
      if (!_messages.containsKey(associationId)) {
        _messages[associationId] = [];
      }
      _messages[associationId]!.add(message);
      notifyListeners();

      // Envoyer uniquement via WebSocket
      _webSocketService.sendMessage(message);

    } catch (e) {
      // En cas d'erreur, mettre à jour le statut du message local
      final messageIndex = _messages[associationId]!.indexWhere((m) => m.id == message.id);
      if (messageIndex != -1) {
        _messages[associationId]![messageIndex] = message.copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
      debugPrint('Erreur envoi message: $e');
      throw Exception('Impossible d\'envoyer le message: $e');
    }
  }

  int getUnreadCount(String associationId) {
    return _unreadCounts[associationId] ?? 0;
  }

  Message? getLastMessage(String associationId) {
    final messages = _messages[associationId];
    if (messages == null || messages.isEmpty) return null;
    return messages.last;
  }

  void _updateUnreadCount(String associationId) {
    final messages = _messages[associationId] ?? [];
    final currentUserId = userProvider.userData!['id'];

    _unreadCounts[associationId] = messages
        .where((msg) =>
            msg.senderId != currentUserId && !_readMessageIds.contains(msg.id))
        .length;

    notifyListeners();
  }

  void markMessageAsRead(String messageId, String associationId) {
    _readMessageIds.add(messageId);
    _updateUnreadCount(associationId);
  }

  void markAllMessagesAsRead(String associationId) {
    final messages = _messages[associationId] ?? [];
    for (var message in messages) {
      _readMessageIds.add(message.id);
    }
    _updateUnreadCount(associationId);
  }

  List<Message> getMessagesForAssociation(String associationId) {
    return _messages[associationId] ?? [];
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    _isConnected = false;
    super.dispose();
  }
}
