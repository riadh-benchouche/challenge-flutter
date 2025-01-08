import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chatbot_message.dart';

class ChatbotService {
  final String baseUrl;
  final String token;

  ChatbotService({required this.baseUrl, required this.token});

  Future<ChatbotMessage> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatbotMessage.fromBot(data['response']);
      } else {
        throw Exception('Échec de l\'envoi du message au chatbot');
      }
    } catch (e) {
      throw Exception('Erreur de communication avec le chatbot: $e');
    }
  }
}