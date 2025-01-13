import 'package:challenge_flutter/models/user.dart';

class Participation {
  final String id;
  final bool isAttending;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String eventId;
  final User? user;

  Participation({
    required this.id,
    required this.isAttending,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.eventId,
    required this.user,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'] ?? '',
      isAttending: json['is_attending'] ?? false,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      userId: json['user_id'] ?? '',
      eventId: json['event_id'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_attending': isAttending,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'event_id': eventId,
      'user': user?.toJson(),
    };
  }
}
