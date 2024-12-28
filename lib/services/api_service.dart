// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:challenge_flutter/models/association.dart';

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

class ApiService {
  final String baseUrl;
  final String? token;

  ApiService({required this.baseUrl, this.token});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<http.Response> _handleResponse(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Session expirée');
      }
      return response;
    } catch (e) {
      debugPrint('Error in _handleResponse: $e');
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau : ${e.toString()}');
    }
  }

  Future<List<Association>> getAssociations() async {
    final response = await _handleResponse(() =>
        http.get(Uri.parse('$baseUrl/associations'), headers: headers)
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final paginatedResponse = PaginatedResponse.fromJson(
        jsonData,
            (json) => Association.fromJson(json),
      );
      return paginatedResponse.rows;
    } else {
      throw Exception('Échec du chargement des associations : ${response.body}');
    }
  }

  Future<Association> getAssociationById(String id) async {
    final response = await _handleResponse(() =>
        http.get(Uri.parse('$baseUrl/associations/$id'), headers: headers)
    );

    if (response.statusCode == 200) {
      return Association.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Association non trouvée : ${response.body}');
    }
  }

  Future<void> joinAssociation(String code) async {
    final response = await _handleResponse(() =>
        http.post(
          Uri.parse('$baseUrl/associations/join'),
          headers: headers,
          body: jsonEncode({'code': code}),
        )
    );

    if (response.statusCode != 200) {
      throw Exception('Code d\'association invalide : ${response.body}');
    }
  }
}