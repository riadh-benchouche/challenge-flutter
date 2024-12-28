// lib/models/association.dart
class Association {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final String code;
  final String? imageUrl;

  Association({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.code,
    this.imageUrl,
  });

  factory Association.fromJson(Map<String, dynamic> json) {
    return Association(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      code: json['code'],
      imageUrl: json['image_url'],
    );
  }
}