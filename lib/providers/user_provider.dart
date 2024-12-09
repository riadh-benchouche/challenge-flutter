import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token; // Pour stocker le token d'authentification
  String? _userId; // Pour stocker l'ID de l'utilisateur

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;

  Future<void> login(String email, String password) async {
    final url = Uri.parse('https://example.com/api/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['user']['id'];
        _isLoggedIn = true;
        notifyListeners();
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (error) {
      rethrow; // Remontez l'erreur pour la gérer dans l'interface utilisateur
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _userId = null;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) return;

    final url = Uri.parse('https://example.com/api/profile');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Mettez à jour les informations utilisateur si nécessaire
        notifyListeners();
      } else {
        throw Exception('Failed to fetch profile: ${response.body}');
      }
    } catch (error) {
      rethrow;
    }
  }
}
