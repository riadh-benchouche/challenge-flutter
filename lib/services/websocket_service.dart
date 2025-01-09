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

  WebSocketService({required this.token}) {
    debugPrint('WebSocketService initialized with token');
  }

  void connect() {
    if (_isConnected) return;

    try {
      debugPrint('Attempting to connect to WebSocket...');

      _channel = IOWebSocketChannel.connect(
        Uri.parse('wss://invooce.online/ws'),
        headers: {
          'Authorization': 'Bearer $token',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
          'Sec-WebSocket-Version': '13',
          'Sec-WebSocket-Protocol': 'ws',
        },
        pingInterval: const Duration(seconds: 30),
      );

      debugPrint('WebSocket connection initiated');
      _isConnected = true;

      _channel?.stream.listen(
        (data) {
          try {
            debugPrint('WebSocket received: $data');
            final message = Message.fromJson(jsonDecode(data));
            onMessageReceived?.call(message);
          } catch (e, stackTrace) {
            debugPrint('Error parsing message: $e');
            debugPrint('Stack trace: $stackTrace');
            onError?.call(e);
          }
        },
        onError: (error, stackTrace) {
          debugPrint('WebSocket error: $error');
          debugPrint('Stack trace: $stackTrace');
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
    } catch (e, stackTrace) {
      debugPrint('Connection error: $e');
      debugPrint('Stack trace: $stackTrace');
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
      debugPrint('Not connected, attempting to connect before sending message');
      connect();
      return;
    }

    try {
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
    debugPrint('Disposing WebSocket service');
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
  }
}
