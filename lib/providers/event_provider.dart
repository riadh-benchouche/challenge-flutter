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
  bool _isLoadingAssociations = false;
  bool _isLoadingParticipations = false;

  List<CategoryModel>? get categories => _categories;
  Event? _currentEvent;
  bool _shouldSwitchToParticipating = false;

  EventProvider({required this.userProvider}) {
    initEventService();
  }

  bool get shouldSwitchToParticipating => _shouldSwitchToParticipating;

  void resetSwitchFlag() {
    _shouldSwitchToParticipating = false;
  }

  void initEventService() {
    _eventService = EventService(
      baseUrl: userProvider.baseUrl,
      token: userProvider.token,
    );
  }

  List<Event>? get associationEvents => _associationEvents;

  List<Event>? get participatingEvents => _participatingEvents;

  Event? get currentEvent => _currentEvent;
  bool get isLoadingAssociations => _isLoadingAssociations;
  bool get isLoadingParticipations => _isLoadingParticipations;


  Future<List<Event>> fetchAssociationEvents() async {
    if (_isLoadingAssociations) return _associationEvents ?? [];

    try {
      _isLoadingAssociations = true;
      notifyListeners();  // Notifier pour afficher le loading

      initEventService();
      _associationEvents = await _eventService.getAssociationEvents();
      return _associationEvents!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    } finally {
      _isLoadingAssociations = false;
      notifyListeners();
    }
  }


  Future<List<Event>> fetchParticipatingEvents() async {
    if (_isLoadingParticipations) return _participatingEvents ?? [];

    try {
      _isLoadingParticipations = true;
      notifyListeners();  // Notifier pour afficher le loading

      initEventService();
      _participatingEvents = await _eventService.getParticipatingEvents();
      return _participatingEvents!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    } finally {
      _isLoadingParticipations = false;
      notifyListeners();
    }
  }

  Future<Event> fetchEventById(String id) async {
    try {
      initEventService();
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
      initEventService();
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
      initEventService();
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
      initEventService();
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
      initEventService();
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
