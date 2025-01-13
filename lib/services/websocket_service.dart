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

  WebSocketService({required this.token});

  Future<bool> connect() async {
    if (_isConnected) return true;
    if (token.isEmpty) {
      debugPrint('Token is empty, not connecting');
      return false;
    }

    try {
      const wsUrl = 'ws://10.0.2.2:3000/ws';
      debugPrint('Connecting to WebSocket...');

      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _channel?.stream.listen(
        (data) {
          try {
            debugPrint('WebSocket received raw data: $data');
            if (data is String) {
              final jsonData = jsonDecode(data);
              debugPrint('Parsed JSON data: $jsonData');

              // Crée directement le Message à partir des données complètes
              final message = Message.fromJson(jsonData);
              debugPrint('Created Message object: ${message.id}');

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
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _handleDisconnect('Error: $error');
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _handleDisconnect('Connection closed');
        },
      );

      _isConnected = true;
      debugPrint('WebSocket connected successfully');
      return true;
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _handleDisconnect(e.toString());
      return false;
    }
  }

  Future<void> sendMessage(String content, String associationId) async {
    if (!_isConnected || _channel == null) {
      final connected = await connect();
      if (!connected) {
        throw Exception('Failed to connect to WebSocket');
      }
    }

    try {
      // Envoie uniquement le contenu et l'ID de l'association
      final messageData = {
        'content': content,
        'association_id': associationId,
      };
      debugPrint('Sending message: ${jsonEncode(messageData)}');
      _channel?.sink.add(jsonEncode(messageData));
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  void _handleDisconnect(String reason) {
    if (_isConnected) {
      _isConnected = false;
      onConnectionClosed?.call();
    }
    _attemptReconnect();
  }

  void _attemptReconnect() {
    if (!_isConnected && _reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      Future.delayed(
        Duration(seconds: _reconnectAttempts * 2),
        () {
          if (!_isConnected) {
            connect();
          }
        },
      );
    }
  }

  void dispose() {
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
  }
}
