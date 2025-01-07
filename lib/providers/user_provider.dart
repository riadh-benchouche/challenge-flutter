import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'platform_helper.dart';

class UserProvider extends ChangeNotifier {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_DATA_KEY = 'user_data';
  static const String IS_LOGGED_IN_KEY = 'is_logged_in';
  bool _initialized = false;
  bool get initialized => _initialized;

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000'; // URL pour Web
    } else if (isAndroid) {
      return 'http://10.0.2.2:3000'; // URL pour Android (émulateur)
    } else if (isIOS) {
      return 'http://127.0.0.1:3000'; // URL pour iOS (émulateur)
    } else {
      return 'http://localhost:3000'; // Desktop ou autres
    }
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

  List<Map<String, dynamic>> _users = [];

  List<Map<String, dynamic>> get users => _users;

  Future<void> fetchUsers() async {
    try {
      int page = 1; // Page de départ
      const int limit = 12; // Nombre d'éléments par page (peut être ajusté)
      bool hasMore = true;

      List<Map<String, dynamic>> allUsers = []; // Stocker tous les utilisateurs

      while (hasMore) {
        final response = await authenticatedRequest(
          '/users?page=$page&limit=$limit',
          method: 'GET',
        );

        if (response.statusCode == 200) {
          final decodedData = jsonDecode(response.body);

          if (decodedData is Map && decodedData.containsKey('rows')) {
            final List<dynamic> rows = decodedData['rows'];

            // Ajouter les utilisateurs récupérés
            allUsers.addAll(rows.map((user) => user as Map<String, dynamic>));

            // Vérifier s'il reste encore des pages
            final int totalPages = decodedData['pages'] ?? 1;
            page++;

            if (page > totalPages) {
              hasMore = false;
            }
          } else {
            throw Exception('Structure inattendue dans la réponse');
          }
        } else {
          throw Exception('Erreur lors de la récupération des utilisateurs');
        }
      }

      _users = allUsers;
      notifyListeners();
    } catch (error) {
      debugPrint('Erreur fetchUsers : $error');
      rethrow;
    }
  }
  Future<void> updateUser(
      String userId, String name, String email, String role) async {
    try {
      final response = await authenticatedRequest(
        '/users/$userId',
        method: 'PUT',
        body: {
          'name': name,
          'email': email,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        final userIndex = _users.indexWhere((user) => user['id'] == userId);
        if (userIndex != -1) {
          _users[userIndex] = {
            'id': userId,
            'name': name,
            'email': email,
            'role': role,
          };
          notifyListeners();
        }
      } else {
        throw Exception('Erreur mise à jour utilisateur. Code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Erreur updateUser : $error');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await authenticatedRequest('/users/$userId', method: 'DELETE');
      if (response.statusCode == 204) {
        _users.removeWhere((user) => user['id'] == userId);
        notifyListeners();
      } else {
        throw Exception('Erreur lors de la suppression de l\'utilisateur');
      }
    } catch (error) {
      debugPrint('Erreur deleteUser : $error');
      rethrow;
    }
  }



}
