import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/auth'; // Pour émulateur Android
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:3000/auth'; // Pour émulateur iOS
    } else {
      return 'http://localhost:3000/auth'; // Pour le web ou autre
    }
  }

  bool _isLoggedIn = false;
  String? _token;
  Map<String, dynamic>? _userData;

  bool get isLoggedIn => _isLoggedIn;

  String? get token => _token;

  Map<String, dynamic>? get userData => _userData;

  Future<void> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

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
        _userData = data['user'];
        _isLoggedIn = true;
        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la connexion');
      }
    } catch (error) {
      print('Erreur détaillée: $error'); // Pour debug
      throw Exception('Erreur de connexion: ${error.toString()}');
    }
  }

  Future<void> register(String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      final response = await http.post(
        url,
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
