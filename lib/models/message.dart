import 'package:challenge_flutter/models/user.dart';

import 'association.dart';

class Message {
  final String id;
  final String content;
  final String senderId;
  final String associationId;
  final DateTime createdAt;
  final User sender;
  final Association association;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.associationId,
    required this.createdAt,
    required this.sender,
    required this.association,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['sender_id'] ?? '',
      associationId: json['association_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      sender: User.fromJson(json['user'] ?? {}),
      association: Association.fromJson(json['association'] ?? {}),
    );
  }
}
