import 'dart:convert';
import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/models/event.dart';
import 'package:challenge_flutter/models/statistics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HomeService {
  static final String baseUrl = AuthService.baseUrl;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (AuthService.token != null) 'Authorization': 'Bearer ${AuthService.token}',
  };

  static Statistics? _statistics;
  static List<Association>? _topAssociations;
  static List<Event>? _recentEvents;

  // Getters
  static Statistics? get statistics => _statistics;
  static List<Association>? get topAssociations => _topAssociations;
  static List<Event>? get recentEvents => _recentEvents;

  static Future<Statistics?> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _statistics = Statistics.fromJson(jsonDecode(response.body));
        return _statistics;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getStatistics: ${e.toString()}');
      return null;
    }
  }

  static Future<List<Association>?> getTopAssociations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/top-associations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = jsonDecode(utf8DecodedBody);
        _topAssociations = jsonData
            .take(3)
            .map((json) => Association.fromJson(json))
            .toList();
        return _topAssociations;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getTopAssociations: ${e.toString()}');
      return null;
    }
  }

  static Future<List<Event>?> getRecentEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/events'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(utf8DecodedBody);
        _recentEvents = (jsonData['rows'] as List)
            .map((json) => Event.fromJson(json))
            .toList()
            .take(3)
            .toList();
        return _recentEvents;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getRecentEvents: ${e.toString()}');
      return null;
    }
  }

  static Future<void> refreshAll() async {
    try {
      await Future.wait([
        getStatistics(),
        getTopAssociations(),
        getRecentEvents(),
      ]);
    } catch (e) {
      debugPrint('Erreur refreshAll: ${e.toString()}');
    }
  }
}