import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_DATA_KEY = 'user_data';
  static const String IS_LOGGED_IN_KEY = 'is_logged_in';

  static String baseUrl = 'http://10.0.2.2:3000'; // Android emulator

  static String? _token;
  static Map<String, dynamic>? _userData;
  static bool _isLoggedIn = false;
  static bool _initialized = false;

  static String? get token => _token;

  static Map<String, dynamic>? get userData => _userData;

  static bool get isLoggedIn => _isLoggedIn;

  static bool get initialized => _initialized;

  static bool get isAdmin => _userData != null && _userData!['role'] == 'admin';

  static Future<void> initializeApp() async {
    if (!_initialized) {
      await _loadStoredData();
      _initialized = true;
    }
  }

  static List<Map<String, dynamic>> _users = [];

  static List<Map<String, dynamic>> get users => _users;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(TOKEN_KEY);
      final userDataString = prefs.getString(USER_DATA_KEY);
      _isLoggedIn = prefs.getBool(IS_LOGGED_IN_KEY) ?? false;

      if (_token != null && userDataString != null) {
        _userData = jsonDecode(userDataString);
        _isLoggedIn = true;
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
    }
  }

  static Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userData = data['user'];
        _isLoggedIn = true;
        await _saveAuthData(_token!, _userData!);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la connexion');
      }
    } catch (error) {
      throw Exception('Erreur de connexion: ${error.toString()}');
    }
  }

  static Future<void> register(
      String name, String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie. Veuillez vous connecter.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(_getErrorMessage(response));
      }
    } catch (error) {
      throw Exception('Erreur d\'inscription: ${error.toString()}');
    }
  }

  static String _getErrorMessage(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return errorData['message'] ?? 'Une erreur est survenue';
    } catch (_) {
      return 'Une erreur est survenue';
    }
  }

  static Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _userData = null;
    await _clearAuthData();
  }

  static Future<void> _saveAuthData(
      String token, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(TOKEN_KEY, token);
      await prefs.setString(USER_DATA_KEY, jsonEncode(userData));
      await prefs.setBool(IS_LOGGED_IN_KEY, true);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des données: $e');
    }
  }

  static Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(TOKEN_KEY);
      await prefs.remove(USER_DATA_KEY);
      await prefs.remove(IS_LOGGED_IN_KEY);
    } catch (e) {
      debugPrint('Erreur lors de la suppression des données: $e');
    }
  }

  static Future<void> refreshUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final newData = jsonDecode(response.body);
        _userData = newData;
      }
    } catch (e) {
      debugPrint('Erreur refresh user data: $e');
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    try {
      _userData = updatedData;
      await _saveAuthData(_token!, updatedData);
    } catch (e) {
      debugPrint('Erreur updateUserData: $e');
      rethrow;
    }
  }

  static Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> rows = jsonData['rows'] as List;
        _users = rows.map((user) => user as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        await logout();
      } else {
        throw Exception('Échec du chargement des utilisateurs');
      }
    } catch (e) {
      debugPrint('Erreur fetchUsers: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> updateUser(
    String userId,
    String name,
    String email,
    String role,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final updatedUser = jsonDecode(response.body);

        // Mettre à jour la liste des utilisateurs
        final index = _users.indexWhere((user) => user['id'] == userId);
        if (index != -1) {
          _users[index] = updatedUser;
        }

        // Mettre à jour les données de l'utilisateur courant si c'est le même
        if (_userData != null && _userData!['id'] == userId) {
          await updateUserData(updatedUser);
        }
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'utilisateur');
      }
    } catch (e) {
      debugPrint('Erreur updateUser: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Supprimer l'utilisateur de la liste locale
        _users.removeWhere((user) => user['id'] == userId);
      } else {
        throw Exception('Erreur lors de la suppression de l\'utilisateur');
      }
    } catch (e) {
      debugPrint('Erreur deleteUser: ${e.toString()}');
      rethrow;
    }
  }
}
