import 'package:flutter/material.dart';
import 'package:challenge_flutter/services/message_service.dart';
import 'conversations_list.dart';
import 'chatbot_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    MessageService.dispose();
    super.dispose();
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
        children: const [
          ConversationsList(),
          ChatbotScreen(),
        ],
      ),
    );
  }
}