import 'package:challenge_flutter/models/category_model.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  static List<CategoryModel> _categories = [];

  // Getter pour accéder aux catégories
  static List<CategoryModel> get categories => _categories;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AuthService.token != null)
          'Authorization': 'Bearer ${AuthService.token}',
      };

  static Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/categories'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          _categories =
              decodedData.map((item) => CategoryModel.fromJson(item)).toList();
        } else if (decodedData is Map && decodedData.containsKey('rows')) {
          _categories = (decodedData['rows'] as List)
              .map((item) => CategoryModel.fromJson(item))
              .toList();
        }
        return _categories;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expirée');
      }
      throw Exception('Erreur lors de la récupération des catégories');
    } catch (error) {
      debugPrint('Erreur fetchCategories : $error');
      rethrow;
    }
  }

  static Future<void> deleteCategory(String ulid) async {
    try {
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/categories/$ulid'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _categories.removeWhere((category) => category.id == ulid);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expirée');
      } else {
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['message']
            : 'Erreur lors de la suppression';
        throw Exception(errorMessage);
      }
    } catch (error) {
      debugPrint('Error in deleteCategory: $error');
      rethrow;
    }
  }

  static Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/categories'),
        headers: _headers,
        body: jsonEncode(categoryData),
      );

      if (response.statusCode == 201) {
        await fetchCategories(); // Rafraîchir la liste
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors de l\'ajout de la catégorie');
      }
    } catch (error) {
      debugPrint('Erreur addCategory : $error');
      rethrow;
    }
  }

  static Future<void> updateCategory(
      String ulid, Map<String, dynamic> categoryData) async {
    try {
      final response = await http.put(
        Uri.parse('${AuthService.baseUrl}/categories/$ulid'),
        headers: _headers,
        body: jsonEncode(categoryData),
      );

      if (response.statusCode == 200) {
        await fetchCategories(); // Rafraîchir la liste
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors de la mise à jour de la catégorie');
      }
    } catch (error) {
      debugPrint('Erreur updateCategory : $error');
      rethrow;
    }
  }
}
