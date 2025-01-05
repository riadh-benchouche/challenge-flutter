import 'package:challenge_flutter/providers/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<void> _loadAssociationsFuture;

  @override
  void initState() {
    super.initState();
    _loadAssociationsFuture = _loadData();
  }

  Future<void> _loadData() async {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    await messageProvider.loadUserAssociations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: FutureBuilder(
          future: _loadAssociationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur: ${snapshot.error}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _loadAssociationsFuture = _loadData();
                      }),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            return Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final associations = messageProvider.userAssociations;

                if (associations.isEmpty) {
                  return const Center(
                    child: Text('Aucune conversation'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: associations.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  itemBuilder: (context, index) {
                    final association = associations[index];
                    final unreadCount = messageProvider.getUnreadCount(association.id);
                    final lastMessage = messageProvider.getLastMessage(association.id);

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.group, color: Colors.grey[400])
                      ),
                      title: Text(
                        association.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: lastMessage != null
                          ? Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${lastMessage.sender.name}: ${lastMessage.content}',
                              style: TextStyle(
                                color: unreadCount > 0
                                    ? Colors.black87
                                    : Colors.grey,
                                fontSize: 14,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatMessageTime(lastMessage.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        'Aucun message',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      trailing: unreadCount > 0
                          ? Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                          : null,
                      onTap: () {
                        context.go('/messages/${association.id}');
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return DateFormat('dd/MM').format(time);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'maintenant';
    }
  }
}