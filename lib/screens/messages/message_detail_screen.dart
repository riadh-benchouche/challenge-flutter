import 'package:challenge_flutter/models/message.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:challenge_flutter/services/message_service.dart';
import 'package:flutter/material.dart';
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
  List<Message> _messages = [];
  String? _error;

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

  Future<void> _loadMessages() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await MessageService.loadMessages(widget.roomId);
      if (mounted) {
        setState(() {
          _messages = MessageService.getMessagesForAssociation(widget.roomId);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
      await MessageService.sendMessage(
        _messageController.text.trim(),
        widget.roomId,
      );
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final currentUserId = AuthService.userData?['id'] ?? '';
    final currentAssociation = MessageService.currentAssociation;

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Erreur', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $_error'),
              ElevatedButton(
                onPressed: _loadMessages,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          currentAssociation?.name ?? 'Chargement...',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Aucun message'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isCurrentUser = message.senderId == currentUserId;
                      return _buildMessage(message, isCurrentUser, theme);
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
