class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final String categoryId;
  final String associationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? association;
  final bool isParticipating;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.categoryId,
    required this.associationId,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.association,
    this.isParticipating = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      categoryId: json['category_id'] ?? '',
      associationId: json['association_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      category: json['category'] as Map<String, dynamic>?,
      association: json['association'] as Map<String, dynamic>?,
      isParticipating: json['is_participating'] ?? false,
    );
  }

  String get categoryName => category?['name'] ?? 'Non catégorisé';
  String get associationName => association?['name'] ?? 'Association inconnue';
}