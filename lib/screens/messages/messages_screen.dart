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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15),
        itemCount: _associations.length,
        itemBuilder: (context, index) {
          final association = _associations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(association['imageUrl']),
              radius: 25,
            ),
            title: Text(
              association['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: association['unreadMessages'] > 0
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDE01),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${association['unreadMessages']}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              // Navigation vers la salle de discussion avec l'ID
              context.go('/messages/${association['id']}');
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
