import 'dart:convert';
import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/models/message.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'association_service.dart';
import 'auth_service.dart';
import 'offline_storage_service.dart';
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

  // Instance du service de stockage hors ligne
  static final _offlineStorage = OfflineStorageService();

  // Surveillance de la connectivité
  static final Connectivity _connectivity = Connectivity();
  static bool _isOnline = true;

  // Initialisation de la surveillance de connectivité
  static Future<void> initConnectivityListener() async {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      bool wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;

      // Si on passe de hors ligne à en ligne
      if (wasOffline && _isOnline) {
        await synchronizePendingMessages();
      }
    });

    // Vérifier l'état initial de la connexion
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

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
    lastError = 'La connexion au serveur a été perdue. Tentative de reconnexion...';
    onError?.call(lastError!);
    debugPrint('WebSocket: $lastError');
  }

  static void _handleError(dynamic error) {
    String errorMessage;
    if (error.toString().contains('token')) {
      errorMessage = 'Erreur d\'authentification. Veuillez vous reconnecter.';
    } else if (error.toString().contains('connection refused')) {
      errorMessage = 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    } else if (error.toString().contains('timeout')) {
      errorMessage = 'Le serveur met trop de temps à répondre. Réessayez plus tard.';
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
        Uri.parse('${AuthService.baseUrl}/users/${AuthService.userData!['id']}/associations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        userAssociations = data.map((json) => Association.fromJson(json)).toList();
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

      // Vérifier les messages en attente si on est en ligne
      if (_isOnline) {
        await synchronizePendingMessages();
      }

      // Initialise la connexion WebSocket si on est en ligne
      if (_isOnline) {
        await _getWebSocket();
      }

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/messages/association/$associationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _messages[associationId] = data.map((json) => Message.fromJson(json)).toList();
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

  static Future<void> synchronizePendingMessages() async {
    if (!_isOnline) return;

    try {
      final pendingMessages = await _offlineStorage.getPendingMessages();
      if (pendingMessages.isEmpty) return;

      final ws = await _getWebSocket();

      for (final message in pendingMessages) {
        try {
          // Vérifier si l'utilisateur est toujours membre de l'association
          final isMember = await AssociationService.checkAssociationMembership(
              message.associationId
          );

          if (!isMember) {
            await _offlineStorage.deleteMessage(message.id);
            continue;
          }

          await ws.sendMessage(message.content, message.associationId);
          await _offlineStorage.markMessageAsSent(message.id);
          await _offlineStorage.deleteMessage(message.id);
        } catch (e) {
          debugPrint('Erreur lors de l\'envoi du message ${message.id}: $e');
          continue;
        }
      }

      lastError = 'Messages synchronisés avec succès';
      onError?.call(lastError!);
    } catch (e) {
      debugPrint('Erreur lors de la synchronisation: $e');
      lastError = 'Erreur lors de la synchronisation des messages';
      onError?.call(lastError!);
    }
  }

  static Future<void> sendMessage(String content, String associationId) async {
    if (AuthService.userData == null) {
      throw Exception("Utilisateur non connecté");
    }

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      associationId: associationId,
      senderId: AuthService.userData!['id'],
      createdAt: DateTime.now(),
      sender: User.fromJson(AuthService.userData!),
      association: currentAssociation!,
    );

    // Ajouter le message à la liste locale
    _messages[associationId] = [...(_messages[associationId] ?? []), message];
    onNewMessage?.call(message);

    try {
      if (_isOnline) {
        // Essayer d'envoyer en ligne
        final ws = await _getWebSocket();
        await ws.sendMessage(content, associationId);
      } else {
        // Sauvegarder en mode hors ligne
        await _offlineStorage.savePendingMessage(message);
        lastError = 'Message sauvegardé localement (mode hors ligne)';
        onError?.call(lastError!);
      }
    } catch (e) {
      // En cas d'erreur, sauvegarder localement
      debugPrint('Erreur envoi message: $e');
      await _offlineStorage.savePendingMessage(message);
      lastError = 'Message sauvegardé localement';
      onError?.call(lastError!);
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
