import 'dart:convert';
import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'websocket_service.dart';

class MessageService {
  static WebSocketService? _webSocket;
  static List<Association> userAssociations = [];
  static Association? currentAssociation;
  static final Map<String, List<Message>> _messages = {};
  static Function(Message)? onNewMessage;
  static String? lastError;
  static bool isWebSocketConnected = false;
  static Function(String)? onError;
  static Function(bool)? onConnectionStatusChanged;

  // Méthode pour initialiser/récupérer la connexion WebSocket
  static Future<WebSocketService> _getWebSocket() async {
    if (_webSocket == null) {
      final token = AuthService.token;
      if (token == null) throw Exception('No token available');

      _webSocket = WebSocketService(token: token)
        ..onMessageReceived = _handleNewMessage
        ..onConnectionClosed = _handleConnectionClosed
        ..onError = _handleError;

      await _webSocket!.connect();
    }
    return _webSocket!;
  }

  static void _handleNewMessage(Message message) {
    final messages = _messages[message.associationId] ?? [];
    if (!messages.any((m) => m.id == message.id)) {
      messages.add(message);
      _messages[message.associationId] = messages;
      onNewMessage?.call(message);
    }
  }

  static void _handleConnectionClosed() {
    isWebSocketConnected = false;
    onConnectionStatusChanged?.call(false);
    lastError =
        'La connexion au serveur a été perdue. Tentative de reconnexion...';
    onError?.call(lastError!);
    debugPrint('WebSocket: $lastError');
  }

  static void _handleError(dynamic error) {
    String errorMessage;

    if (error.toString().contains('token')) {
      errorMessage = 'Erreur d\'authentification. Veuillez vous reconnecter.';
    } else if (error.toString().contains('connection refused')) {
      errorMessage =
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    } else if (error.toString().contains('timeout')) {
      errorMessage =
          'Le serveur met trop de temps à répondre. Réessayez plus tard.';
    } else {
      errorMessage = 'Une erreur est survenue: ${error.toString()}';
    }

    lastError = errorMessage;
    onError?.call(errorMessage);
    debugPrint('WebSocket Error: $errorMessage');
  }

  static Future<void> loadUserAssociations() async {
    try {
      final token = AuthService.token;
      if (token == null) throw Exception('No token available');

      final response = await http.get(
        Uri.parse(
            '${AuthService.baseUrl}/users/${AuthService.userData!['id']}/associations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        userAssociations =
            data.map((json) => Association.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load associations');
      }
    } catch (e) {
      throw Exception('Error loading associations: $e');
    }
  }

  static Future<void> loadMessages(String associationId) async {
    try {
      final token = AuthService.token;
      if (token == null) throw Exception('No token available');

      // Initialise la connexion WebSocket en même temps que le chargement des messages
      await _getWebSocket();

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/messages/association/$associationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _messages[associationId] =
            data.map((json) => Message.fromJson(json)).toList();
        currentAssociation = userAssociations.firstWhere(
          (a) => a.id == associationId,
          orElse: () => throw Exception('Association not found'),
        );
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }

  static Future<void> sendMessage(String content, String associationId) async {
    try {
      // S'assure que le WebSocket est connecté avant d'envoyer
      final ws = await _getWebSocket();
      await ws.sendMessage(content, associationId);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  static List<Message> getMessagesForAssociation(String associationId) {
    return _messages[associationId] ?? [];
  }

  static Message? getLastMessage(String associationId) {
    final messages = _messages[associationId] ?? [];
    return messages.isEmpty ? null : messages.last;
  }

  static void dispose() {
    _webSocket?.dispose();
    _webSocket = null;
    _messages.clear();
  }
}
