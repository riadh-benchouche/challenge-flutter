import 'package:challenge_flutter/models/message.dart';
import 'package:challenge_flutter/providers/message_provider.dart';
import 'package:challenge_flutter/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MessageDetailScreen extends StatefulWidget {
  final String roomId;

  const MessageDetailScreen({super.key, required this.roomId});

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    await messageProvider.loadMessages(widget.roomId);
    _scrollToBottom();
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
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      await messageProvider.sendMessage(
        _messageController.text.trim(),
        widget.roomId,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMessage(Message message, bool isCurrentUser, ThemeData theme) {
    final time = DateFormat('HH:mm').format(message.createdAt);
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isCurrentUser ? theme.primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.sender.name,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: isCurrentUser ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.userData?['id'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Consumer<MessageProvider>(
          builder: (context, messageProvider, child) {
            final association = messageProvider.currentAssociation;
            return Text(
              association?.name ?? 'Chargement...',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final messages =
                    messageProvider.getMessagesForAssociation(widget.roomId);

                if (messages.isEmpty) {
                  return const Center(child: Text('Aucun message'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.senderId == currentUserId;
                    return _buildMessage(message, isCurrentUser, theme);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrivez un message...',
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
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
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
                        : Icon(Icons.send, color: theme.primaryColor),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
