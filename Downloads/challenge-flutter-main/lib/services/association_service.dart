// lib/services/association_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/association.dart';

class AssociationService {
  final String baseUrl = 'http://10.0.2.2:8080';  // Ajustez le port si nécessaire

  Future<Map<String, dynamic>> getAssociations({
    int page = 1,
    int limit = 10,
    String? filterColumn,
    String? filterValue,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (filterColumn != null) 'column': filterColumn,
        if (filterValue != null) 'value': filterValue,
      };

      final uri = Uri.parse('$baseUrl/associations').replace(queryParameters: queryParams);
      print('DEBUG: Tentative de connexion à: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('DEBUG: Code de statut: ${response.statusCode}');
      print('DEBUG: Type de contenu: ${response.headers['content-type']}');
      print('DEBUG: Corps brut de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') == true) {
          return json.decode(response.body);
        } else {
          throw Exception('La réponse n\'est pas au format JSON');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Erreur détaillée: $e');
      rethrow;
    }
  }
}