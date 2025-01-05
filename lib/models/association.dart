// lib/models/association.dart
class Association {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final String imageUrl;
  final String code;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Association({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.imageUrl,
    required this.code,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Association.fromJson(Map<String, dynamic> json) {
    return Association(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      imageUrl: json['image_url'] ?? '',
      code: json['code'] ?? '',
      ownerId: json['owner_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}