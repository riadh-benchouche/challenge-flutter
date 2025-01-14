import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:challenge_flutter/services/message_service.dart';
import 'package:intl/intl.dart';

class ConversationsList extends StatelessWidget {
  const ConversationsList({super.key});

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: MessageService.loadUserAssociations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Chargement des conversations...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
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
                  onPressed: () => (context as Element).markNeedsBuild(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final associations = MessageService.userAssociations;

        if (associations.isEmpty) {
          return const Center(
            child: Text('Aucune conversation'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => (context as Element).markNeedsBuild(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: associations.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
            itemBuilder: (context, index) {
              final association = associations[index];
              final lastMessage = MessageService.getLastMessage(association.id);

              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: association.imageUrl.isEmpty
                      ? const AssetImage('assets/images/association-1.jpg')
                      : NetworkImage(
                          'https://10.0.2.2:8080/${association.imageUrl}',
                        ) as ImageProvider,
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
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
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
                onTap: () => context.go('/messages/${association.id}'),
              );
            },
          ),
        );
      },
    );
  }
}
