import 'package:flutter/material.dart';
import 'dart:convert';
import 'user_provider.dart';

class CategoryProvider with ChangeNotifier {
  final UserProvider userProvider;
  List<Map<String, dynamic>> _categories = [];

  CategoryProvider({required this.userProvider});

  List<Map<String, dynamic>> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      final response = await userProvider.authenticatedRequest(
        '/categories',
        method: 'GET',
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          _categories = decodedData.cast<Map<String, dynamic>>();
        } else if (decodedData is Map && decodedData.containsKey('rows')) {
          _categories = (decodedData['rows'] as List).cast<Map<String, dynamic>>();
        }
        notifyListeners();
      } else {
        throw Exception('Erreur lors de la récupération des catégories');
      }
    } catch (error) {
      debugPrint('Erreur fetchCategories : $error');
      rethrow;
    }
  }

  Future<void> deleteCategory(String ulid) async {
    try {
      debugPrint('Deleting category with ULID: $ulid');

      final response = await userProvider.authenticatedRequest(
        '/categories/$ulid',
        method: 'DELETE',
      );

      debugPrint('Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _categories.removeWhere((category) => category['id'] == ulid);
        notifyListeners();
        debugPrint('Category deleted successfully');
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

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await userProvider.authenticatedRequest(
        '/categories',
        method: 'POST',
        body: categoryData,
      );

      if (response.statusCode == 201) {
        await fetchCategories();
      } else {
        throw Exception('Erreur lors de l\'ajout de la catégorie');
      }
    } catch (error) {
      debugPrint('Erreur addCategory : $error');
      rethrow;
    }
  }

  Future<void> updateCategory(String ulid, Map<String, dynamic> categoryData) async {
    try {
      final response = await userProvider.authenticatedRequest(
        '/categories/$ulid',
        method: 'PUT',
        body: categoryData,
      );

      if (response.statusCode == 200) {
        await fetchCategories();
      } else {
        throw Exception('Erreur lors de la mise à jour de la catégorie');
      }
    } catch (error) {
      debugPrint('Erreur updateCategory : $error');
      rethrow;
    }
  }
}