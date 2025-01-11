import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'chatbot_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  List<Association> _associations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await MessageService.loadUserAssociations();
      setState(() {
        _associations = MessageService.userAssociations;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
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

  Widget _buildConversationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $_error'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_associations.isEmpty) {
      return const Center(
        child: Text('Aucune conversation'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _associations.length,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
        itemBuilder: (context, index) {
          final association = _associations[index];
          final lastMessage = MessageService.getLastMessage(association.id);

          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              backgroundImage: association.imageUrl.isEmpty
                  ? const AssetImage('assets/images/association-1.jpg')
                  : NetworkImage(
                      'https://invooce.online/${association.imageUrl}',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(
                icon: Icon(Icons.message),
                text: 'Conversations',
              ),
              Tab(
                icon: Icon(Icons.smart_toy),
                text: 'Chatbot',
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationsList(),
          const ChatbotScreen(),
        ],
      ),
    );
  }
}
