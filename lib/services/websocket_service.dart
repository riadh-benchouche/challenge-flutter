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
  bool _isConnected = false;

  WebSocketService({required this.token});

  void connect() {
    if (_isConnected) return;

    try {
      _channel = IOWebSocketChannel.connect(
        'wss://invooce.online/ws',
        headers: {
          'Authorization': 'Bearer $token',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        },
      );

      _isConnected = true;

      _channel?.stream.listen(
            (data) {
          try {
            debugPrint('WebSocket received: $data');
            final message = Message.fromJson(jsonDecode(data));
            onMessageReceived?.call(message);
          } catch (e) {
            debugPrint('Error parsing message: $e');
            onError?.call(e);
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          onError?.call(error);
          _reconnect();
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isConnected = false;
          onConnectionClosed?.call();
          _reconnect();
        },
      );
    } catch (e) {
      debugPrint('Connection error: $e');
      _isConnected = false;
      onError?.call(e);
      _reconnect();
    }
  }

  void _reconnect() {
    if (!_isConnected) {
      Future.delayed(const Duration(seconds: 3), () {
        connect();
      });
    }
  }

  void sendMessage(Message message) {
    if (!_isConnected) {
      connect();
    }

    try {
      // Simplifier la structure du message pour correspondre à ce que le serveur attend
      final data = jsonEncode({
        'content': message.content,
        'association_id': message.associationId,
      });

      debugPrint('Sending message: $data');
      _channel?.sink.add(data);
    } catch (e) {
      debugPrint('Send message error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  void dispose() {
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
  }
}