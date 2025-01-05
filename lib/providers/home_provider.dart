import 'package:flutter/foundation.dart';
import '../services/home_service.dart';
import '../models/statistics.dart';
import '../models/association.dart';
import '../models/event.dart';
import './user_provider.dart';

class HomeProvider with ChangeNotifier {
  final UserProvider userProvider;
  late HomeService _homeService;

  Statistics? _statistics;
  List<Association>? _topAssociations;
  List<Event>? _recentEvents;

  HomeProvider({required this.userProvider}) {
    _initHomeService();
  }

  void _initHomeService() {
    _homeService = HomeService(
      baseUrl: userProvider.baseUrl,
      token: userProvider.token,
    );
  }

  Statistics? get statistics => _statistics;
  List<Association>? get topAssociations => _topAssociations;
  List<Event>? get recentEvents => _recentEvents;

  Future<Statistics> fetchStatistics() async {
    try {
      _statistics = await _homeService.getStatistics();
      notifyListeners();
      return _statistics!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<List<Association>> fetchTopAssociations() async {
    try {
      _topAssociations = await _homeService.getTopAssociations();
      notifyListeners();
      return _topAssociations!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<List<Event>> fetchRecentEvents() async {
    try {
      _recentEvents = await _homeService.getRecentEvents();
      notifyListeners();
      return _recentEvents!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<void> refreshAll() async {
    try {
      await Future.wait([
        fetchStatistics(),
        fetchTopAssociations(),
        fetchRecentEvents(),
      ]);
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }
}