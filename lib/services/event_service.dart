import 'dart:convert';
import 'package:challenge_flutter/models/category_model.dart';
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

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponse(
      limit: json['limit'] ?? 0,
      page: json['page'] ?? 1,
      sort: json['sort'] ?? '',
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
      rows: (json['rows'] as List<dynamic>?)
              ?.map((item) => fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
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
        throw Exception(
            'Échec du chargement des événements : ${response.body}');
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
        throw Exception(
            'Échec du chargement des événements : ${response.body}');
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

  Future<bool> checkEventParticipation(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/is-attended'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_attended'] ?? false;
      } else {
        throw Exception('Impossible de vérifier la participation');
      }
    } catch (e) {
      debugPrint('Error in checkEventParticipation: $e');
      rethrow;
    }
  }

  Future<void> toggleEventParticipation(
      String eventId, bool isAttending) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/user-event-participation'),
        headers: headers,
        body: jsonEncode({
          'is_attending': isAttending,
        }),
      );

      if (response.statusCode == 200) {
        if (isAttending) {
          // Si on s'inscrit, on vérifie que la participation a été créée
          final data = jsonDecode(response.body);
          if (data == null || data['is_attending'] != isAttending) {
            throw Exception('Erreur lors de l\'inscription à l\'événement');
          }
        } else {
          // Si on se désinscrit, response.body sera null ou vide, c'est normal
          // Pas besoin de vérification supplémentaire
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

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final paginatedResponse = PaginatedResponse<CategoryModel>.fromJson(
          jsonData,
          (json) => CategoryModel.fromJson(json),
        );
        return paginatedResponse.rows;
      } else {
        throw Exception(
            'Échec du chargement des catégories : ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getCategories: $e');
      rethrow;
    }
  }

  Future<Event> createEvent({
    required String name,
    required String description,
    required DateTime date,
    required String location,
    required String categoryId,
    required String associationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'date': date.toUtc().toIso8601String(),
          'location': location,
          'category_id': categoryId,
          'association_id': associationId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Event.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Échec de la création de l\'événement');
      }
    } catch (e) {
      debugPrint('Error in createEvent: $e');
      rethrow;
    }
  }

  Future<Event> updateEvent({
    required String eventId,
    required String name,
    required String description,
    required DateTime date,
    required String location,
    required String categoryId,
    required String associationId
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'date': date.toUtc().toIso8601String(),
          'location': location,
          'category_id': categoryId,
          'association_id': associationId
        }),
      );

      if (response.statusCode == 200) {
        return Event.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Impossible de mettre à jour l\'événement');
      }
    } catch (e) {
      debugPrint('Error in updateEvent: $e');
      rethrow;
    }
  }
}
