import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/api_service.dart';
import 'package:challenge_flutter/providers/user_provider.dart';

class AssociationProvider with ChangeNotifier {
  final UserProvider userProvider;
  late ApiService _apiService;
  List<Association>? _associations;
  Association? _currentAssociation;

  AssociationProvider({required this.userProvider}) {
    _initApiService();
  }

  void _initApiService() {
    _apiService = ApiService(
      baseUrl: userProvider.baseUrl,
      token: userProvider.token,
    );
  }

  List<Association>? get associations => _associations;
  Association? get currentAssociation => _currentAssociation;

  Future<List<Association>> fetchAssociationByUser() async {
    try {
      _initApiService();
      _associations = (await _apiService.getAssociationsByUser(userProvider.userData!['id'])) as List<Association>?;
      notifyListeners();
      return _associations!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<List<Association>> fetchAssociations() async {
    try {
      // Réinitialiser le service API pour avoir le dernier token
      _initApiService();
      _associations = await _apiService.getAssociations();
      notifyListeners();
      return _associations!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      throw error;
    }
  }

  Future<Association> fetchAssociationById(String id) async {
    try {
      _initApiService();
      final association = await _apiService.getAssociationById(id);
      _currentAssociation = association;
      notifyListeners();
      return association;
    } catch (error) {
      debugPrint('Error fetching association: $error');
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      throw error;
    }
  }

  Future<void> joinAssociation(String code) async {
    try {
      _initApiService();
      debugPrint('Joining association with code: $code');

      await _apiService.joinAssociation(code);
      // Rafraîchir les associations après avoir rejoint
      await fetchAssociationByUser();
      notifyListeners();
    } catch (error) {
      debugPrint('Error joining association: $error');
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<Association> createAssociation(String name, String description) async {
    try {
      _initApiService();
      final association = await _apiService.createAssociation(name, description);
      // Rafraîchir la liste des associations après la création
      await fetchAssociations();
      notifyListeners();
      return association;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<List<Association>> fetchAssociationByOwner() async {
    try {
      _initApiService();
      List<Association> ownerAssociations = await _apiService.getAssociationByOwner(userProvider.userData!['id']);
      _associations = ownerAssociations;
      notifyListeners();
      return ownerAssociations;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<Association> updateAssociation(String id, String name, String description) async {
    try {
      _initApiService();
      final association = await _apiService.updateAssociation(id, name, description);
      // Rafraîchir la liste des associations après la mise à jour
      await fetchAssociations();
      notifyListeners();
      return association;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  Future<Association> uploadAssociationImage(String id, File image) async {
    try {
      _initApiService();
      final association = await _apiService.uploadAssociationImage(id, image);
      await fetchAssociationById(id);
      notifyListeners();
      return association;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      rethrow;
    }
  }

  bool get canCreateAssociation {
    return userProvider.userData?['role'] == 'association_leader';
  }
}