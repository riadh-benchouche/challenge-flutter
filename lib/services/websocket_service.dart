import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../models/message.dart';
import 'package:flutter/foundation.dart';

class WebSocketService {
  final String token;
  IOWebSocketChannel? _channel;
  Function(Message)? onMessageReceived;
  Function()? onConnectionClosed;
  Function(dynamic)? onError;
  bool _isDisposed = false;

  WebSocketService({required this.token});

  void connect() {
    if (_isDisposed) return;  // Ne pas se reconnecter si disposé

    try {
      _channel = IOWebSocketChannel.connect(
        'ws://10.0.2.2:3000/ws',
        headers: {
          'Authorization': 'Bearer $token',
        },
        pingInterval: const Duration(seconds: 30),
      );

      _channel?.stream.listen(
            (data) {
          if (_isDisposed) return;  // Ne pas traiter si disposé
          debugPrint('Message reçu: $data');
          try {
            final message = Message.fromJson(jsonDecode(data));
            onMessageReceived?.call(message);
          } catch (e) {
            debugPrint('Erreur parsing message: $e');
            if (!_isDisposed) onError?.call(e);
          }
        },
        onError: (error) {
          debugPrint('Erreur WebSocket: $error');
          if (!_isDisposed) {
            onError?.call(error);
            _reconnect();
          }
        },
        onDone: () {
          debugPrint('Connexion WebSocket fermée');
          if (!_isDisposed) {
            onConnectionClosed?.call();
            _reconnect();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('Erreur connexion WebSocket: $e');
        onError?.call(e);
        _reconnect();
      }
    }
  }

  void _reconnect() {
    debugPrint('Tentative de reconnexion dans 5 secondes...');
    Future.delayed(const Duration(seconds: 5), () {
      if (_channel?.sink == null) {
        connect();
      }
    });
  }

  void sendMessage(Message message) {
    try {
      if (_channel?.sink != null) {
        final data = jsonEncode(message.toJson());
        debugPrint('Envoi message: $data');
        _channel!.sink.add(data);
      } else {
        throw Exception('WebSocket non connecté');
      }
    } catch (e) {
      debugPrint('Erreur envoi message: $e');
      throw Exception('Impossible d\'envoyer le message: $e');
    }
  }

  bool get isConnected => _channel?.sink != null;

  void dispose() {
    debugPrint('Fermeture WebSocket');
    _isDisposed = true;
    _channel?.sink.close();
    _channel = null;
  }
}
