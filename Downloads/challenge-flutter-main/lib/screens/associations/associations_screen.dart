// lib/models/association.dart
class Association {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final String code;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String ownerId;

  Association({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    required this.ownerId,
  });

  factory Association.fromJson(Map<String, dynamic> json) {
    return Association(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      isActive: json['is_active'],
      code: json['code'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      imageUrl: json['image_url'],
      ownerId: json['owner_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'is_active': isActive,
    'code': code,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'image_url': imageUrl,
    'owner_id': ownerId,
  };
}