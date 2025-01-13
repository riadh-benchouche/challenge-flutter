class User {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final String role;
  final int pointsOpen;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.role,
    required this.pointsOpen,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      role: json['role'] ?? 'user',
      pointsOpen: json['points_open'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'role': role,
      'points_open': pointsOpen,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    String? role,
    int? pointsOpen,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      pointsOpen: pointsOpen ?? this.pointsOpen,
    );
  }
}
