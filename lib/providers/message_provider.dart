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
  Association? _currentAssociation;
  List<Association> _userAssociations = [];

  MessageProvider({required this.userProvider}) {
    initWebSocket();
  }

  List<Association> get userAssociations => _userAssociations;

  Association? get currentAssociation => _currentAssociation;

  void initWebSocket() {
    if (userProvider.token == null || userProvider.token!.isEmpty) {
      debugPrint('No token available, skipping WebSocket initialization');
      return;
    }

    debugPrint('Initializing WebSocket with token');
    _webSocketService = WebSocketService(token: userProvider.token!);
    _webSocketService.onMessageReceived = _handleNewMessage;
    _webSocketService.onError = (error) {
      debugPrint('WebSocket error in provider: $error');
    };
    _webSocketService.onConnectionClosed = () {
      debugPrint('WebSocket connection closed in provider');
    };
    _webSocketService.connect();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  Future<void> loadUserAssociations() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${userProvider.baseUrl}/users/${userProvider.userData!['id']}/associations'),
        headers: {
          'Authorization': 'Bearer ${userProvider.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _userAssociations =
            data.map((json) => Association.fromJson(json)).toList();

        for (var association in _userAssociations) {
          await loadMessages(association.id);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load associations');
      }
    } catch (error) {
      debugPrint('Error loading associations: $error');
      rethrow;
    }
  }

  Future<void> loadMessages(String associationId) async {
    try {
      final associationResponse = await http.get(
        Uri.parse('${userProvider.baseUrl}/associations/$associationId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.token}',
        },
      );

      if (associationResponse.statusCode == 200) {
        _currentAssociation =
            Association.fromJson(jsonDecode(associationResponse.body));
      }

      final response = await http.get(
        Uri.parse(
            '${userProvider.baseUrl}/messages/association/$associationId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _messages[associationId] =
            data.map((json) => Message.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error loading messages: $error');
      rethrow;
    }
  }

  void _handleNewMessage(Message message) {
    final associationId = message.associationId;
    if (!_messages.containsKey(associationId)) {
      _messages[associationId] = [];
    }
    // Ajouter le message uniquement s'il n'existe pas déjà
    if (!_messages[associationId]!.any((m) =>
        m.content == message.content &&
        m.createdAt.difference(message.createdAt).inSeconds.abs() < 2)) {
      _messages[associationId]!.add(message);
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content, String associationId) async {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: userProvider.userData!['id'],
      associationId: associationId,
      createdAt: DateTime.now(),
      sender: User.fromJson(userProvider.userData!),
      association: _currentAssociation ?? Association.fromJson({}),
    );

    try {
      // Ne plus ajouter le message localement ici
      // Laisser le WebSocket gérer l'ajout quand il reçoit la confirmation
      _webSocketService.sendMessage(message);
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Cannot send message: $e');
    }
  }

  Message? getLastMessage(String associationId) {
    final messages = _messages[associationId];
    if (messages == null || messages.isEmpty) return null;
    return messages.last;
  }

  List<Message> getMessagesForAssociation(String associationId) {
    return _messages[associationId] ?? [];
  }
}
