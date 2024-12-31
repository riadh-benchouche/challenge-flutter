import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  bool _isLoggedIn = false;

  String get baseUrl => _baseUrl;
  String? _token;
  Map<String, dynamic>? _userData;

  bool get isLoggedIn => _isLoggedIn;

  String? get token => _token;

  Map<String, dynamic>? get userData => _userData;

  // Méthode pour faire des requêtes HTTP authentifiées
  Future<http.Response> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');

    // Headers avec token d'authentification
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

      // Gestion des erreurs HTTP
      if (response.statusCode == 401) {
        _isLoggedIn = false;
        _token = null;
        notifyListeners();
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
        _isLoggedIn = true;
        print(_token);
        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la connexion');
      }
    } catch (error) {
      throw Exception('Erreur de connexion: ${error.toString()}');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userData = data['user'];
        _isLoggedIn = true;
        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de l\'inscription');
      }
    } catch (error) {
      throw Exception('Erreur d\'inscription: ${error.toString()}');
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _userData = null;
    notifyListeners();
  }
}
