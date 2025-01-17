import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class AuthService {
  static const String TOKEN_KEY = 'auth_token';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const String USER_DATA_KEY = 'user_data';
  static const String IS_LOGGED_IN_KEY = 'is_logged_in';
  static const String TOKEN_EXPIRY_KEY = 'token_expiry';

  static String baseUrl = 'https://invooce.online'; // Android emulator

  static String? _token;
  static String? _refreshToken;
  static DateTime? _tokenExpiry;
  static Map<String, dynamic>? _userData;
  static bool _isLoggedIn = false;
  static bool _initialized = false;
  static List<Map<String, dynamic>> _users = [];

  static String? get token => _token;

  static Map<String, dynamic>? get userData => _userData;

  static bool get isLoggedIn => _isLoggedIn;

  static bool get initialized => _initialized;

  static bool get isAdmin => _userData != null && _userData!['role'] == 'admin';

  static List<Map<String, dynamic>> get users => _users;

  static Future<void> initializeApp() async {
    if (!_initialized) {
      await _loadStoredData();
      _initialized = true;
    }
  }

  static Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(TOKEN_KEY);
      _refreshToken = prefs.getString(REFRESH_TOKEN_KEY);
      final expiryString = prefs.getString(TOKEN_EXPIRY_KEY);
      if (expiryString != null) {
        _tokenExpiry = DateTime.parse(expiryString);
      }

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

  // Méthode de login
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
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8DecodedBody);
        _token = data['token'];
        _refreshToken = data['refresh_token'];
        _userData = data['user'];
        _tokenExpiry = DateTime.now().add(const Duration(minutes: 15));
        _isLoggedIn = true;
        await _saveAuthData(_token!, _refreshToken!, _userData!);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la connexion');
      }
    } catch (error) {
      throw Exception('Erreur de connexion: ${error.toString()}');
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        debugPrint('Email de réinitialisation envoyé avec succès.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Échec de l\'envoi de l\'email de réinitialisation.');
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la demande de réinitialisation: ${e.toString()}');
    }
  }

  // Méthode de refresh token
  static Future<bool> refreshTokenIfNeeded() async {
    if (_tokenExpiry == null || _refreshToken == null) return false;

    // Rafraîchir si moins de 1 minute reste ou token expiré
    if (_tokenExpiry!
        .isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': _refreshToken}),
        );

        if (response.statusCode == 200) {
          final String utf8DecodedBody = utf8.decode(response.bodyBytes);
          final data = jsonDecode(utf8DecodedBody);
          _token = data['token'];
          _refreshToken = data['refresh_token'];
          _tokenExpiry = DateTime.now().add(const Duration(minutes: 15));
          await _saveAuthData(_token!, _refreshToken!, _userData!);
          return true;
        } else {
          await logout();
          return false;
        }
      } catch (e) {
        debugPrint('Erreur refresh token: $e');
        await logout();
        return false;
      }
    }
    return true;
  }

  // Méthode pour les requêtes authentifiées
  static Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    if (!await refreshTokenIfNeeded()) {
      throw Exception('Session expirée');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
      ...?headers,
    };

    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: requestHeaders);
        break;
      case 'POST':
        response = await http.post(url, headers: requestHeaders, body: body);
        break;
      case 'PUT':
        response = await http.put(url, headers: requestHeaders, body: body);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: requestHeaders);
        break;
      default:
        throw Exception('Méthode HTTP non supportée');
    }

    if (response.statusCode == 401) {
      await logout();
      throw Exception('Session expirée');
    }

    return response;
  }

  // Méthode d'inscription
  static Future<void> register(
      String name,
      String email,
      String password,
      BuildContext context,
      ) async {
    try {
      // Récupérer le token Firebase
      String? firebaseToken = await getFirebaseToken();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'firebase_token': firebaseToken,
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


  // Méthode de déconnexion
  static Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _refreshToken = null;
    _tokenExpiry = null;
    _userData = null;
    await _clearAuthData();
  }

  // Méthodes utilitaires
  static String _getErrorMessage(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return errorData['message'] ?? 'Une erreur est survenue';
    } catch (_) {
      return 'Une erreur est survenue';
    }
  }

  static Future<void> _saveAuthData(
    String token,
    String refreshToken,
    Map<String, dynamic> userData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(TOKEN_KEY, token);
      await prefs.setString(REFRESH_TOKEN_KEY, refreshToken);
      if (_tokenExpiry != null) {
        await prefs.setString(
            TOKEN_EXPIRY_KEY, _tokenExpiry!.toIso8601String());
      }
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
      await prefs.remove(REFRESH_TOKEN_KEY);
      await prefs.remove(TOKEN_EXPIRY_KEY);
      await prefs.remove(USER_DATA_KEY);
      await prefs.remove(IS_LOGGED_IN_KEY);
    } catch (e) {
      debugPrint('Erreur lors de la suppression des données: $e');
    }
  }

  // Méthodes de gestion des utilisateurs
  static Future<void> refreshUserData() async {
    try {
      final response = await authenticatedRequest('GET', '/me');
      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final newData = jsonDecode(utf8DecodedBody);
        _userData = newData;
        await _saveAuthData(_token!, _refreshToken!, _userData!);
      }
    } catch (e) {
      debugPrint('Erreur refresh user data: $e');
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    try {
      _userData = updatedData;
      await _saveAuthData(_token!, _refreshToken!, updatedData);
    } catch (e) {
      debugPrint('Erreur updateUserData: $e');
      rethrow;
    }
  }

  static Future<void> fetchUsers() async {
    try {
      final response = await authenticatedRequest('GET', '/users');
      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(utf8DecodedBody);
        final List<dynamic> rows = jsonData['rows'] as List;
        _users = rows.map((user) => user as Map<String, dynamic>).toList();
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
      final response = await authenticatedRequest(
        'PUT',
        '/users/$userId',
        body: jsonEncode({
          'name': name,
          'email': email,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final updatedUser = jsonDecode(utf8DecodedBody);

        final index = _users.indexWhere((user) => user['id'] == userId);
        if (index != -1) {
          _users[index] = updatedUser;
        }

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
      final response = await authenticatedRequest('DELETE', '/users/$userId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _users.removeWhere((user) => user['id'] == userId);
      } else {
        throw Exception('Erreur lors de la suppression de l\'utilisateur');
      }
    } catch (e) {
      debugPrint('Erreur deleteUser: ${e.toString()}');
      rethrow;
    }
  }

  static Future<String?> getFirebaseToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      return await messaging.getToken(vapidKey:"BONuruARy1l6U3xYRw2ALx5JMIWJv5Y5cGw_iYCXVEwTfIjANrI2gqzEnk5jiD4-zGul0OD63ueKwvzfRhthz5o");
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token Firebase : $e');
      return null;
    }
  }

}
