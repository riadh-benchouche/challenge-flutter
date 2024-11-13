import 'package:flutter/material.dart';

class MessageDetailScreen extends StatelessWidget {
  final String roomId;
  const MessageDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Details')),
      body: Center(
        child: Text('Details for Room ID: $roomId'),
      ),
    );
  }
}
