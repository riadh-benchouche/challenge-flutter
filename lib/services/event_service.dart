import 'dart:convert';
import 'package:challenge_flutter/models/category_model.dart';
import 'package:challenge_flutter/models/event.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

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
  static String get baseUrl => AuthService.baseUrl;
  static bool _shouldSwitchToParticipating = false;

  static List<Event>? _associationEvents;
  static List<Event>? _participatingEvents;
  static List<CategoryModel>? _categories;
  static Event? _currentEvent;
  static bool _isLoadingAssociations = false;
  static bool _isLoadingParticipations = false;

  // Getters
  static List<Event>? get associationEvents => _associationEvents;

  static List<Event>? get participatingEvents => _participatingEvents;

  static List<CategoryModel>? get categories => _categories;

  static Event? get currentEvent => _currentEvent;

  static bool get isLoadingAssociations => _isLoadingAssociations;

  static bool get isLoadingParticipations => _isLoadingParticipations;

  static bool get shouldSwitchToParticipating => _shouldSwitchToParticipating;

  static bool get canCreateEvent =>
      AuthService.userData?['role'] == 'association_leader';

  static void resetSwitchFlag() {
    _shouldSwitchToParticipating = false;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AuthService.token != null)
          'Authorization': 'Bearer ${AuthService.token}',
      };

  static Future<void> resetAndRefreshEvents() async {
    _associationEvents = null;
    _participatingEvents = null;
    await Future.wait([
      getAssociationEvents(),
      getParticipatingEvents(),
    ]);
  }

  static Future<List<Event>> getAssociationEvents() async {
    if (_isLoadingAssociations) return _associationEvents ?? [];

    try {
      _isLoadingAssociations = true;
      final response = await http.get(
        Uri.parse('$baseUrl/users/associations/events'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
        _associationEvents = (jsonData['rows'] as List)
            .map((json) => Event.fromJson(json))
            .toList();
        return _associationEvents!;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Échec du chargement des événements');
    } catch (e) {
      debugPrint('Error in getAssociationEvents: $e');
      rethrow;
    } finally {
      _isLoadingAssociations = false;
    }
  }

  static Future<List<Event>> getParticipatingEvents() async {
    if (_isLoadingParticipations) return _participatingEvents ?? [];

    try {
      _isLoadingParticipations = true;
      final response = await http.get(
        Uri.parse('$baseUrl/users/events'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(utf8DecodedBody);
        _participatingEvents = (jsonData['rows'] as List)
            .map((json) => Event.fromJson(json))
            .toList();
        return _participatingEvents!;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Échec du chargement des événements');
    } catch (e) {
      debugPrint('Error in getParticipatingEvents: $e');
      rethrow;
    } finally {
      _isLoadingParticipations = false;
    }
  }

  static Future<Event> getEventById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        _currentEvent = Event.fromJson(jsonDecode(utf8DecodedBody));
        return _currentEvent!;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Événement non trouvé');
    } catch (e) {
      debugPrint('Error in getEventById: $e');
      rethrow;
    }
  }

  static Future<bool> checkEventParticipation(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/is-attended'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_attended'] ?? false;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Impossible de vérifier la participation');
    } catch (e) {
      debugPrint('Error in checkEventParticipation: $e');
      rethrow;
    }
  }

  static Future<void> toggleEventParticipation(
      String eventId, bool isAttending) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/user-event-participation'),
        headers: _headers,
        body: jsonEncode({'is_attending': isAttending}),
      );

      if (response.statusCode == 200) {
        if (isAttending) {
          _shouldSwitchToParticipating = true;
          if (_currentEvent?.id == eventId) {
            _currentEvent = await getEventById(eventId);
          }
          await Future.wait([
            getAssociationEvents(),
            getParticipatingEvents(),
          ]);
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
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

  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
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

  static Future<Event> createEvent({
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
        headers: _headers,
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

  static Future<List<Map<String, dynamic>>> getEventParticipations(
      String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/participations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(utf8DecodedBody)['rows'];
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Échec du chargement des participations');
    } catch (e) {
      debugPrint('Error in getEventParticipations: $e');
      rethrow;
    }
  }

  static Future<void> confirmParticipation(String participationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/participations/$participationId/confirm'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('Participation confirmée');
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      } else {
        throw Exception('Échec de la confirmation de la participation');
      }
    } catch (e) {
      debugPrint('Error in confirmParticipation: $e');
      rethrow;
    }
  }

  static Future<Event> updateEvent(
      {required String eventId,
      required String name,
      required String description,
      required DateTime date,
      required String location,
      required String categoryId,
      required String associationId}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: _headers,
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
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        return Event.fromJson(jsonDecode(utf8DecodedBody));
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
