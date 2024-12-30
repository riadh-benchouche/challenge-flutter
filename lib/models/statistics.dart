class Statistics {
  final int totalAssociations;
  final int totalEvents;
  final int totalUsers;

  Statistics({
    required this.totalAssociations,
    required this.totalEvents,
    required this.totalUsers,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalAssociations: json['total_associations'] ?? 0,
      totalEvents: json['total_events'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
    );
  }
}