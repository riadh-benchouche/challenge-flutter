// lib/models/message.dart
import 'user.dart';
import 'association.dart';

enum MessageStatus {
  sending,   // Message en cours d'envoi
  sent,      // Message envoyé au serveur
  delivered, // Message reçu par le serveur
  read,      // Message lu par le destinataire
  failed     // Échec de l'envoi
}

class Message {
  final String id;
  final String content;
  final String senderId;
  final String associationId;
  final DateTime createdAt;
  final User sender;
  final Association association;
  final MessageStatus status;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.associationId,
    required this.createdAt,
    required this.sender,
    required this.association,
    this.status = MessageStatus.sent,
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
      status: MessageStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'association_id': associationId,
      'sender_id': senderId,
    };
  }

  Message copyWith({
    String? id,
    String? content,
    String? senderId,
    String? associationId,
    DateTime? createdAt,
    User? sender,
    Association? association,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      associationId: associationId ?? this.associationId,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      association: association ?? this.association,
      status: status ?? this.status,
    );
  }

  bool isFromCurrentUser(String currentUserId) => senderId == currentUserId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Message &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              content == other.content &&
              senderId == other.senderId &&
              associationId == other.associationId;

  @override
  int get hashCode =>
      id.hashCode ^
      content.hashCode ^
      senderId.hashCode ^
      associationId.hashCode;
}