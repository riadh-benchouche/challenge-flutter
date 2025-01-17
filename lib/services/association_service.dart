// lib/services/association_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:challenge_flutter/models/association.dart';

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

class AssociationService {
  static String get baseUrl => AuthService.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AuthService.token != null)
          'Authorization': 'Bearer ${AuthService.token}',
      };

  // État local du service
  static List<Association>? _associations;
  static List<Association>? _associationsAll;
  static Association? _currentAssociation;

  // Getters
  static List<Association>? get associations => _associations;

  static Association? get currentAssociation => _currentAssociation;

  static List<Association>? get associationsAll => _associationsAll;

  static bool get canCreateAssociation =>
      AuthService.userData?['role'] == 'association_leader';

  static Future<List<Association>> getAssociationsByUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/associations'),
        headers: _headers,
      );

      // Si c'est 204 (No Content) ou 200 avec un tableau vide, on retourne une liste vide
      if (response.statusCode == 204 || response.body.isEmpty) {
        _associations = [];
        return [];
      }

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = jsonDecode(utf8DecodedBody);
        _associations =
            jsonData.map((json) => Association.fromJson(json)).toList();
        return _associations!;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Échec du chargement des associations');
    } catch (e) {
      debugPrint('Erreur getAssociationsByUser: ${e.toString()}');
      rethrow;
    }
  }

  static Future<List<Association>> getAssociations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/associations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(utf8DecodedBody);
        final List<dynamic> rows = jsonData['rows'] as List;
        if (rows.isEmpty) {
          _associations = [];
          return [];
        }
        _associations = rows.map((json) => Association.fromJson(json)).toList();
        return _associations!;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Échec du chargement des associations');
    } catch (e) {
      debugPrint('Erreur getAssociations: ${e.toString()}');
      rethrow;
    }
  }

  static Future<List<Association>> getAssociationsAll() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/associations/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(utf8DecodedBody);
        final List<dynamic> rows = jsonData['rows'] as List;
        if (rows.isEmpty) {
          _associationsAll = []; // Correction ici
          return [];
        }
        _associationsAll =
            rows.map((json) => Association.fromJson(json)).toList(); // Et ici
        return _associationsAll!;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Échec du chargement des associations');
    } catch (e) {
      debugPrint('Erreur getAssociations: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> updateAssociationAdmin(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/associations/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Rafraîchir la liste après la mise à jour
        await getAssociationsAll();
        return;
      }

      throw Exception(
          'Impossible de mettre à jour l\'association : ${response.body}');
    } catch (e) {
      debugPrint('Erreur updateAssociationAdmin: ${e.toString()}');
      rethrow;
    }
  }

  static Future<Association> getAssociationById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/associations/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        _currentAssociation = Association.fromJson(jsonDecode(utf8DecodedBody));
        return _currentAssociation!;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Association non trouvée');
    } catch (e) {
      debugPrint('Erreur getAssociationById: ${e.toString()}');
      rethrow;
    }
  }

  static Future<bool> checkAssociationMembership(String associationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/associations/$associationId/check-membership'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
        return data['isMember'] ?? false;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      return false;
    } catch (e) {
      debugPrint('Erreur checkAssociationMembership: ${e.toString()}');
      return false;
    }
  }

  static Future<void> joinAssociation(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/associations/join/$code'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Rafraîchir la liste des associations après avoir rejoint
        await getAssociationsByUser(AuthService.userData!['id']);
      } else if (response.statusCode == 409) {
        throw Exception('Vous êtes déjà membre de cette association');
      } else if (response.statusCode == 401) {
        await AuthService.refreshTokenIfNeeded();
      } else {
        throw Exception('Impossible de rejoindre l\'association');
      }
    } catch (e) {
      debugPrint('Erreur joinAssociation: ${e.toString()}');
      rethrow;
    }
  }

  static Future<Association> createAssociation(
      String name, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/associations'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final newAssociation =
            Association.fromJson(jsonDecode(utf8DecodedBody));
        await getAssociations(); // Rafraîchir la liste
        return newAssociation;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Impossible de créer l\'association');
    } catch (e) {
      debugPrint('Erreur createAssociation: ${e.toString()}');
      rethrow;
    }
  }

  static Future<List<Association>> getAssociationByOwner(String ownerId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/users/$ownerId/owner-associations'),
        headers: _headers);

    if (response.statusCode == 200) {
      final String utf8DecodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonData = jsonDecode(utf8DecodedBody);
      return jsonData.map((json) => Association.fromJson(json)).toList();
    } else {
      throw Exception('Associations non trouvées : ${response.body}');
    }
  }

  static Future<Association> updateAssociation(
      String id, String name, String description) async {
    final response = await http.put(
      Uri.parse('$baseUrl/associations/$id'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      final String utf8DecodedBody = utf8.decode(response.bodyBytes);
      return Association.fromJson(jsonDecode(utf8DecodedBody));
    }

    throw Exception(
        'Impossible de mettre à jour l\'association : ${response.body}');
  }

  static Future<Association> uploadAssociationImage(
      String associationId, File image) async {
    final url = Uri.parse('$baseUrl/associations/$associationId/upload-image');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll(_headers);

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: request.files[0].filename,
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final String utf8DecodedBody = utf8.decode(response.bodyBytes);
      return Association.fromJson(jsonDecode(utf8DecodedBody));
    }

    throw Exception('Impossible de mettre à jour l\'image : ${response.body}');
  }

  static Future<void> leaveAssociation(String associationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/associations/$associationId/leave'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Rafraîchir la liste des associations après avoir quitté
        await getAssociationsByUser(AuthService.userData!['id']);
      } else if (response.statusCode == 401) {
        await AuthService.refreshTokenIfNeeded();
      } else {
        throw Exception('Impossible de quitter l\'association');
      }
    } catch (e) {
      debugPrint('Erreur leaveAssociation: ${e.toString()}');
      rethrow;
    }
  }
}
