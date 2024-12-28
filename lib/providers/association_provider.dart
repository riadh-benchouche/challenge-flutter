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

  Future<List<Association>> fetchAssociations() async {
    try {
      // Réinitialiser le service API pour avoir le dernier token
      _initApiService();

      print('Fetching associations...');
      print('Token: ${userProvider.token}');

      _associations = await _apiService.getAssociations();
      notifyListeners();
      return _associations!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        // Déconnexion de l'utilisateur
        await userProvider.logout();
      }
      throw error;
    }
  }

  Future<Association> fetchAssociationById(String id) async {
    try {
      _initApiService();

      // _currentAssociation = await _apiService.getAssociationById(id);
      notifyListeners();
      return _currentAssociation!;
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      throw error;
    }
  }

  Future<void> joinAssociation(String code) async {
    try {
      _initApiService();

      // await _apiService.joinAssociation(code);
      await fetchAssociations(); // Rafraîchir la liste
    } catch (error) {
      if (error.toString().contains('Session expirée')) {
        await userProvider.logout();
      }
      throw error;
    }
  }
}