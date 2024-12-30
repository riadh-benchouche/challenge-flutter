// lib/services/home_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/statistics.dart';
import '../models/association.dart';
import '../models/event.dart';

class HomeService {
  final String baseUrl;
  final String? token;

  HomeService({required this.baseUrl, this.token});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Statistics> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Statistics.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Échec du chargement des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<List<Association>> getTopAssociations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/top-associations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .take(3) // Prendre seulement les 3 premières associations
            .map((json) => Association.fromJson(json))
            .toList();
      } else {
        throw Exception('Échec du chargement des associations');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<List<Event>> getRecentEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/events'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<Event> events = (jsonData['rows'] as List)
            .map((json) => Event.fromJson(json))
            .toList();
        return events.take(3).toList(); // Prendre seulement les 3 premiers événements
      } else {
        throw Exception('Échec du chargement des événements');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }
}