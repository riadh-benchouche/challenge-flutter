import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_DATA_KEY = 'user_data';
  static const String IS_LOGGED_IN_KEY = 'is_logged_in';
  bool _initialized = false;

  bool get initialized => _initialized;

  String get _baseUrl {
    return 'https://invooce.online';
  }

  bool get isAdmin {
    return _userData != null && _userData!['role'] == 'admin';
  }

  bool _isLoggedIn = false;
  String? _token;
  Map<String, dynamic>? _userData;

  String get baseUrl => _baseUrl;

  bool get isLoggedIn => _isLoggedIn;

  String? get token => _token;

  Map<String, dynamic>? get userData => _userData;

  UserProvider();

  Future<void> initializeApp() async {
    if (!_initialized) {
      await _loadStoredData();
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(TOKEN_KEY);
      final userDataString = prefs.getString(USER_DATA_KEY);
      _isLoggedIn = prefs.getBool(IS_LOGGED_IN_KEY) ?? false;

      if (_token != null && userDataString != null) {
        _userData = jsonDecode(userDataString);
        if (_userData != null && _userData!.containsKey('role')) {
          _userData!['role'] = _userData!['role'];
        }
        _isLoggedIn = true; // S'assurer que isLoggedIn est à true
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
    }
  }

  Future<void> _saveAuthData(
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

  void updateUserData(Map<String, dynamic> newData) {
    _userData = newData;
    _saveAuthData(_token!, _userData!);
    notifyListeners();
  }

  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(TOKEN_KEY);
      await prefs.remove(USER_DATA_KEY);
      await prefs.remove(IS_LOGGED_IN_KEY);
    } catch (e) {
      debugPrint('Erreur lors de la suppression des données: $e');
    }
  }

  Future<http.Response> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');

    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    try {
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }

      if (response.statusCode == 401) {
        await logout();
        throw Exception('Session expirée, veuillez vous reconnecter');
      }

      return response;
    } catch (error) {
      throw Exception('Erreur de requête: ${error.toString()}');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
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
        if (_userData != null && _userData!.containsKey('role')) {
          _userData!['role'] = data['user']['role'];
        }

        _isLoggedIn = true;
        await _saveAuthData(_token!, _userData!);
        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la connexion');
      }
    } catch (error) {
      throw Exception('Erreur de connexion: ${error.toString()}');
    }
  }

  Future<void> register(
      String name, String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Réponse HTTP status: ${response.statusCode}');

      if (response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie. Veuillez vous connecter.'),
              backgroundColor: Colors.green,
            ),
          );
          GoRouter.of(context).go('/login');
        }
        notifyListeners();
      } else if (response.statusCode == 409) {
        throw Exception('Cet utilisateur existe déjà.');
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Les données sont invalides.');
      } else {
        throw Exception('Erreur d\'inscription: Code ${response.statusCode}');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw Exception('Erreur d\'inscription: ${error.toString()}');
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _userData = null;
    await _clearAuthData();
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    try {
      final response = await authenticatedRequest('/me');
      if (response.statusCode == 200) {
        final newData = jsonDecode(response.body);
        updateUserData(newData);
      }
    } catch (e) {
      debugPrint('Erreur refresh user data: $e');
    }
  }
}

