import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/event.dart';

class PaginatedResponse<T> {
  final int limit;
  final int page;
  final String sort;
  final int total;
  final int pages;
  final List<T> rows;

  PaginatedResponse({
    required this.limit,
    required this.page,
    required this.sort,
    required this.total,
    required this.pages,
    required this.rows,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponse(
      limit: json['limit'] ?? 0,
      page: json['page'] ?? 1,
      sort: json['sort'] ?? '',
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
      rows: (json['rows'] as List<dynamic>?)?.map((item) => fromJson(item as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class EventService {
  final String baseUrl;
  final String? token;

  EventService({required this.baseUrl, this.token});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<List<Event>> getAssociationEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/associations/events'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final paginatedResponse = PaginatedResponse.fromJson(
          jsonData,
              (json) => Event.fromJson(json),
        );
        return paginatedResponse.rows;
      } else {
        throw Exception('Échec du chargement des événements : ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getAssociationEvents: $e');
      rethrow;
    }
  }

  // Mettez à jour aussi le modèle Event pour correspondre à la réponse de l'API
  Future<List<Event>> getParticipatingEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/events'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final paginatedResponse = PaginatedResponse.fromJson(
          jsonData,
              (json) => Event.fromJson(json),
        );
        return paginatedResponse.rows;
      } else {
        throw Exception('Échec du chargement des événements : ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getParticipatingEvents: $e');
      rethrow;
    }
  }

  Future<Event> getEventById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Event.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Événement non trouvé : ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getEventById: $e');
      rethrow;
    }
  }

  Future<void> toggleEventParticipation(String eventId, bool isAttending) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/user-event-participation'),
        headers: headers,
        body: jsonEncode({
          'is_attending': isAttending,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['is_attending'] != isAttending) {
          throw Exception('Erreur lors de la mise à jour de la participation');
        }
      } else {
        throw Exception(isAttending
            ? 'Impossible de rejoindre l\'événement'
            : 'Impossible de quitter l\'événement');
      }
    } catch (e) {
      debugPrint('Error in toggleEventParticipation: $e');
      rethrow;
    }
  }
}