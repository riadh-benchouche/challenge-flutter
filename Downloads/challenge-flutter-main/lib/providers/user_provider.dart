import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _username = 'Guest';

  String get username => _username;

  void login(String username) {
    _username = username;
    notifyListeners();
  }

  void logout() {
    _username = 'Guest';
    notifyListeners();
  }
}