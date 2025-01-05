import 'package:challenge_flutter/models/category_model.dart';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import './user_provider.dart';

class EventProvider with ChangeNotifier {
  final UserProvider userProvider;
  late EventService _eventService;
  List<Event>? _associationEvents;
  List<Event>? _participatingEvents;
  List<CategoryModel>? _categories;

  List<CategoryModel>? get categories => _categories;
  Event? _currentEvent;
  bool _shouldSwitchToParticipating = false;

  EventProvider({required this.userProvider}) {
    _initEventService();
  }

  bool get shouldSwitchToParticipating => _shouldSwitchToParticipating;

  void resetSwitchFlag() {
    _shouldSwitchToParticipating = false;
  }

  void _initEventService() {
    _eventService = EventService(
      baseUrl: userProvider.baseUrl,
      token: userProvider.token,
    );
  }

  List<Event>? get associationEvents => _associationEvents;

  List<Event>? get participatingEvents => _participatingEvents;

  Event? get currentEvent => _currentEvent;

  Future<List<Event>> fetchAssociationEvents() async {
    try {
      _initEventService();
      _associationEvents = await _eventService.getAssociationEvents();
      notifyListeners();
      return _associationEvents!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<List<Event>> fetchParticipatingEvents() async {
    try {
      _initEventService();
      _participatingEvents = await _eventService.getParticipatingEvents();
      notifyListeners();
      return _participatingEvents!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<Event> fetchEventById(String id) async {
    try {
      _initEventService();
      _currentEvent = await _eventService.getEventById(id);
      notifyListeners();
      return _currentEvent!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<bool> checkParticipation(String eventId) async {
    try {
      _initEventService();
      return await _eventService.checkEventParticipation(eventId);
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }



  Future<void> toggleParticipation(String eventId, bool isAttending) async {
    try {
      _initEventService();
      await _eventService.toggleEventParticipation(eventId, isAttending);

      if (isAttending) {
        _shouldSwitchToParticipating = true;
      }

      // Mettre à jour l'événement courant si c'est celui-ci
      if (_currentEvent?.id == eventId) {
        _currentEvent = await _eventService.getEventById(eventId);
      }

      // Rafraîchir les listes d'événements
      await Future.wait([
        fetchAssociationEvents(),
        fetchParticipatingEvents(),
      ]);

      notifyListeners();
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<Event> createEvent(String name, String description, DateTime date,
      String location, String categoryId, String associationId) async {
    try {
      _initEventService();
      final event = await _eventService.createEvent(
        name: name,
        description: description,
        date: date,
        location: location,
        categoryId: categoryId,
        associationId: associationId,
      );
      await Future.wait([
        fetchAssociationEvents(),
        fetchParticipatingEvents(),
      ]);
      notifyListeners();
      return event;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      _initEventService();
      _categories = await _eventService.getCategories();
      notifyListeners();
      return _categories!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  bool get canCreateEvent {
    return userProvider.userData?['role'] == 'association_leader';
  }
}
