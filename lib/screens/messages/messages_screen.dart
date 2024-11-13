import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen({super.key});

  final List<Map<String, dynamic>> _associations = [
    {
      'id': '1',
      'name': 'Association A',
      'imageUrl': 'assets/images/association-1.jpg',
      'unreadMessages': 5,
    },
    {
      'id': '2',
      'name': 'Association B',
      'imageUrl': 'assets/images/association-1.jpg',
      'unreadMessages': 2,
    },
    {
      'id': '3',
      'name': 'Association C',
      'imageUrl': 'assets/images/association-1.jpg',
      'unreadMessages': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        userName: 'John Doe',
        pageTitle: 'Messages',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _associations.length,
        itemBuilder: (context, index) {
          final association = _associations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(association['imageUrl']),
              radius: 25,
              backgroundColor: Colors.grey[200],
            ),
            title: Text(
              association['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: association['unreadMessages'] > 0
                ? const Text(
                    'You have new messages',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  )
                : const Text(
                    'No new messages',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
            trailing: association['unreadMessages'] > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${association['unreadMessages']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              context.go('/messages/${association['id']}');
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
