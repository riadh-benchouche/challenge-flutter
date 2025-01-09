import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/api_service.dart';
import 'package:challenge_flutter/providers/user_provider.dart';

class AssociationProvider with ChangeNotifier {
  final UserProvider userProvider;
  late ApiService _apiService;
  List<Association>? _associations;
  List<Association>? _associationsAll;
  Association? _currentAssociation;

  AssociationProvider({required this.userProvider}) {
    initApiService();
  }

  void initApiService() {
    _apiService = ApiService(
      baseUrl: userProvider.baseUrl,
      token: userProvider.token,
    );
  }

  List<Association>? get associations => _associations;
  Association? get currentAssociation => _currentAssociation;
  List<Association>? get associationsAll => _associationsAll;

  Future<List<Association>> fetchAssociationByUser() async {
    try {
      initApiService();
      _associations = (await _apiService.getAssociationsByUser(
          userProvider.userData!['id'])) as List<Association>?;
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
      initApiService();
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

  Future<List<Association>> fetchAssociationsAll() async {
    try {
      // Réinitialiser le service API pour avoir le dernier token
      initApiService();
      _associationsAll = await _apiService.getAssociationsAll();
      notifyListeners();
      return _associationsAll!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      throw error;
    }
  }

  Future<Association> fetchAssociationById(String id) async {
    try {
      initApiService();
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
      initApiService();
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
      initApiService();
      final association =
          await _apiService.createAssociation(name, description);
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

  Future<void> updateAssociationAdmin(
      String id, Map<String, dynamic> associationData) async {
    try {
      final response = await userProvider.authenticatedRequest(
        '/associations/$id',
        method: 'PUT',
        body: associationData,
      );

      if (response.statusCode == 200) {
        await fetchAssociationsAll();
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'association');
      }
    } catch (error) {
      debugPrint('Erreur updateAssociation : $error');
      rethrow;
    }
  }

  Future<List<Association>> fetchAssociationByOwner() async {
    try {
      initApiService();
      List<Association> ownerAssociations =
          await _apiService.getAssociationByOwner(userProvider.userData!['id']);
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

  Future<Association> updateAssociation(
      String id, String name, String description) async {
    try {
      initApiService();
      final association =
          await _apiService.updateAssociation(id, name, description);
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
      initApiService();
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
