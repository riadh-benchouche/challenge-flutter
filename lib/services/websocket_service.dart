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
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  WebSocketService({required this.token}) {
    debugPrint(
        'WebSocketService initialized with token length: ${token.length}');
  }

  Future<bool> connect() async {
    if (_isConnected) return true;
    if (token.isEmpty) {
      debugPrint('Token is empty, not connecting');
      return false;
    }

    try {
      debugPrint('Attempting to connect to WebSocket...');

      _channel = IOWebSocketChannel.connect(
        Uri.parse('ws://10.0.2.2:3000/ws'),
        headers: {
          'Authorization': 'Bearer $token',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
          'Sec-WebSocket-Version': '13',
          'Sec-WebSocket-Protocol': 'ws',
        },
        pingInterval: const Duration(seconds: 30),
      );

      // Attendre que la connexion soit établie
      await Future.delayed(const Duration(seconds: 1));

      _channel?.stream.listen(
        (data) {
          try {
            debugPrint('WebSocket received: $data');
            if (data is String) {
              final message = Message.fromJson(jsonDecode(data));
              _isConnected = true;
              _reconnectAttempts = 0;
              onMessageReceived?.call(message);
            }
          } catch (e, stackTrace) {
            debugPrint('Error parsing message: $e');
            debugPrint('Stack trace: $stackTrace');
            onError?.call(e);
          }
        },
        onError: (error, stackTrace) {
          debugPrint('WebSocket error: $error');
          debugPrint('Stack trace: $stackTrace');
          _handleDisconnect('Error: $error');
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _handleDisconnect('Connection closed');
        },
        cancelOnError: false,
      );

      _isConnected = true;
      debugPrint('WebSocket connection established');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Connection error: $e');
      debugPrint('Stack trace: $stackTrace');
      _handleDisconnect(e.toString());
      return false;
    }
  }

  Future<bool> waitForConnection() async {
    int attempts = 0;
    while (!_isConnected && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    return _isConnected;
  }

  Future<void> sendMessage(Message message) async {
    if (!_isConnected || _channel == null) {
      debugPrint('Not connected, attempting to connect before sending message');
      final connected = await connect();
      if (!connected) {
        throw Exception('WebSocket connection failed');
      }
      await waitForConnection();
    }

    try {
      final data = jsonEncode({
        'content': message.content,
        'association_id': message.associationId,
      });

      debugPrint('Sending message: $data');
      _channel?.sink.add(data);
    } catch (e, stackTrace) {
      debugPrint('Send message error: $e');
      debugPrint('Stack trace: $stackTrace');
      _handleDisconnect('Send error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  void _handleDisconnect(String reason) {
    if (_isConnected) {
      debugPrint('WebSocket disconnected: $reason');
      _isConnected = false;
      onConnectionClosed?.call();
    }
    _reconnect();
  }

  void _reconnect() {
    if (!_isConnected && _reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);
      debugPrint(
          'Attempting reconnection $_reconnectAttempts of $_maxReconnectAttempts in ${delay.inSeconds} seconds');

      Future.delayed(delay, () {
        if (!_isConnected) {
          connect();
        }
      });
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
      onError?.call('Max reconnection attempts reached');
    }
  }

  void dispose() {
    debugPrint('Disposing WebSocket service');
    _isConnected = false;
    _reconnectAttempts = 0;
    _channel?.sink.close();
    _channel = null;
  }
}
