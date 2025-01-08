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
    if (_isDisposed) return;

    try {
      _channel = IOWebSocketChannel.connect(
        'wss://invooce.online/ws', // Changed to WSS
        headers: {
          'Authorization': 'Bearer $token',
        },
        pingInterval: const Duration(seconds: 30),
      );

      _channel?.stream.listen(
        (data) {
          if (_isDisposed) return;
          try {
            final message = Message.fromJson(jsonDecode(data));
            onMessageReceived?.call(message);
          } catch (e) {
            debugPrint('Error parsing message: $e');
            if (!_isDisposed) onError?.call(e);
          }
        },
        onError: (error) {
          if (!_isDisposed) {
            onError?.call(error);
            _reconnect();
          }
        },
        onDone: () {
          if (!_isDisposed) {
            onConnectionClosed?.call();
            _reconnect();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (!_isDisposed) {
        onError?.call(e);
        _reconnect();
      }
    }
  }

  void _reconnect() {
    if (_isDisposed) return;
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed && _channel?.sink == null) {
        connect();
      }
    });
  }

  void sendMessage(Message message) {
    if (_isDisposed) return;

    try {
      if (_channel?.sink == null) {
        connect();
        throw Exception('Reconnecting to WebSocket');
      }

      final data = jsonEncode(message.toJson());
      _channel!.sink.add(data);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  bool get isConnected => !_isDisposed && _channel?.sink != null;

  void dispose() {
    _isDisposed = true;
    _channel?.sink.close();
    _channel = null;
  }
}
