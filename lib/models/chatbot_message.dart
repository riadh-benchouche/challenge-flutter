class ChatbotMessage {
  final String id;
  final String content;
  final bool isFromBot;
  final DateTime createdAt;

  ChatbotMessage({
    required this.id,
    required this.content,
    required this.isFromBot,
    required this.createdAt,
  });

  factory ChatbotMessage.fromUser(String content) {
    return ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromBot: false,
      createdAt: DateTime.now(),
    );
  }

  factory ChatbotMessage.fromBot(String content) {
    return ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromBot: true,
      createdAt: DateTime.now(),
    );
  }
}