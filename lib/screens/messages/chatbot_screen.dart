import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../models/chatbot_message.dart';
import '../../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatbotMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late ChatbotService _chatbotService;

  @override
  void initState() {
    super.initState();
    _chatbotService = ChatbotService(
      baseUrl: AuthService.baseUrl,
      token: AuthService.token!,
    );

    // Ajouter un message de bienvenue
    setState(() {
      _messages.add(ChatbotMessage.fromBot(
        'Bonjour ! Je suis votre assistant virtuel. Comment puis-je vous aider ?',
      ));
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _messages.add(ChatbotMessage.fromUser(message));
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await _chatbotService.sendMessage(message);
      setState(() {
        _messages.add(response);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatbotMessage.fromBot(
          'Désolé, une erreur est survenue. Veuillez réessayer.',
        ));
      });
      _scrollToBottom();
    }
  }

  Widget _buildMessage(ChatbotMessage message) {
    return Align(
      alignment: message.isFromBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isFromBot
              ? Colors.grey[300]
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isFromBot ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _buildMessage(_messages[index]),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(0, -1),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrivez votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  )
                      : Icon(
                    Icons.send,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}