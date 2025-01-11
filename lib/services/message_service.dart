import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import '../models/message.dart';
import '../models/association.dart';
import '../models/user.dart';

class MessageService {
  static WebSocketService? _webSocketService;
  static final Map<String, List<Message>> _messages = {};
  static Association? _currentAssociation;
  static List<Association> _userAssociations = [];
  static bool _initialized = false;

  // Getters
  static List<Association> get userAssociations => _userAssociations;

  static Association? get currentAssociation => _currentAssociation;

  static bool get initialized => _initialized;

  static Future<void> initWebSocket() async {
    if (_initialized) return;

    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      return;
    }

    _webSocketService = WebSocketService(token: token);
    _webSocketService!.onMessageReceived = _handleNewMessage;
    _webSocketService!.onError = (error) {
      debugPrint('WebSocket error in service: $error');
    };
    _webSocketService!.onConnectionClosed = () {
      debugPrint('WebSocket connection closed in service');
    };

    await Future.delayed(const Duration(milliseconds: 500));
    await _webSocketService!.connect();
    _initialized = true;
  }

  static void dispose() {
    _webSocketService?.dispose();
    _webSocketService = null;
    _initialized = false;
  }

  static Future<void> loadUserAssociations() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AuthService.baseUrl}/users/${AuthService.userData!['id']}/associations'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      // Gérer le cas où il n'y a pas d'associations (204 ou body vide)
      if (response.statusCode == 204 || response.body.isEmpty) {
        _userAssociations = [];
        return;
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _userAssociations =
            data.map((json) => Association.fromJson(json)).toList();

        // Charger les messages uniquement s'il y a des associations
        if (_userAssociations.isNotEmpty) {
          for (var association in _userAssociations) {
            await loadMessages(association.id);
          }
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
    } catch (error) {
      debugPrint('Error loading associations: $error');
      // Au lieu de rethrow, on définit une liste vide
      _userAssociations = [];
    }
  }

  static Future<void> loadMessages(String associationId) async {
    try {
      final associationResponse = await http.get(
        Uri.parse('${AuthService.baseUrl}/associations/$associationId'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (associationResponse.statusCode == 200) {
        _currentAssociation =
            Association.fromJson(jsonDecode(associationResponse.body));
      }

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/messages/association/$associationId'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      // Gérer le cas où il n'y a pas de messages
      if (response.statusCode == 204 || response.body.isEmpty) {
        _messages[associationId] = [];
        return;
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _messages[associationId] =
            data.map((json) => Message.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
    } catch (error) {
      debugPrint('Error loading messages: $error');
      // Au lieu de rethrow, on définit une liste vide pour les messages
      _messages[associationId] = [];
    }
  }

  static void _handleNewMessage(Message message) {
    final associationId = message.associationId;
    if (!_messages.containsKey(associationId)) {
      _messages[associationId] = [];
    }
    if (!_messages[associationId]!.any((m) =>
        m.content == message.content &&
        m.createdAt.difference(message.createdAt).inSeconds.abs() < 2)) {
      _messages[associationId]!.add(message);
    }
  }

  static Future<void> sendMessage(String content, String associationId) async {
    if (AuthService.token == null || AuthService.token!.isEmpty) {
      throw Exception('No token available');
    }

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: AuthService.userData!['id'],
      associationId: associationId,
      createdAt: DateTime.now(),
      sender: User.fromJson(AuthService.userData!),
      association: _currentAssociation ?? Association.fromJson({}),
    );

    try {
      await _webSocketService?.sendMessage(message);
    } catch (e) {
      debugPrint('Error sending message: $e');
      await initWebSocket();
      throw Exception('Cannot send message: $e');
    }
  }

  static Message? getLastMessage(String associationId) {
    final messages = _messages[associationId];
    if (messages == null || messages.isEmpty) return null;
    return messages.last;
  }

  static List<Message> getMessagesForAssociation(String associationId) {
    return _messages[associationId] ?? [];
  }
}
