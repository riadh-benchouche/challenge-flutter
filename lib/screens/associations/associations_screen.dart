import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/association_service.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:challenge_flutter/widgets/home/association_card_widget.dart';

class AssociationsScreen extends StatefulWidget {
  const AssociationsScreen({super.key});

  @override
  _AssociationsScreenState createState() => _AssociationsScreenState();
}

class _AssociationsScreenState extends State<AssociationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<Association>? _myAssociations;
  List<Association>? _allAssociations;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssociations();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadAssociations();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssociations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = AuthService.userData?['id'];
      if (userId == null) {
        context.go('/login');
        throw Exception('Utilisateur non connecté');
      }

      // Utilisation de try-catch pour chaque appel de service
      List<Association>? userAssociations;
      List<Association>? allAssociations;

      try {
        userAssociations =
            await AssociationService.getAssociationsByUser(userId);
      } catch (e) {
        debugPrint(
            'Erreur lors du chargement des associations de l\'utilisateur: $e');
        userAssociations = [];
      }

      try {
        allAssociations = await AssociationService.getAssociations();
      } catch (e) {
        debugPrint('Erreur lors du chargement de toutes les associations: $e');
        allAssociations = [];
      }

      if (mounted) {
        setState(() {
          _myAssociations = userAssociations ?? [];
          _allAssociations = allAssociations ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _myAssociations = [];
          _allAssociations = [];
        });
      }
    }
  }

  List<Association> _filterAssociations(
      List<Association>? associations, String query) {
    if (associations == null) return [];
    if (query.isEmpty) return associations;

    return associations.where((association) {
      return association.name.toLowerCase().contains(query.toLowerCase()) ||
          association.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune association trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erreur: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAssociations,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement des associations...',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationsList(List<Association>? associations) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    final filteredAssociations =
        _filterAssociations(associations, _searchQuery);

    if (filteredAssociations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAssociations,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredAssociations.length,
        itemBuilder: (context, index) {
          final association = filteredAssociations[index];
          return AssociationCard(
            associationId: association.id,
            associationName: association.name,
            imageSrc: association.imageUrl,
            userCount: 12,
            eventCount: 13,
            description: association.description,
            isActive: association.isActive,
            isOwner: association.ownerId == AuthService.userData?['id'],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCreate = AssociationService.canCreateAssociation;

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.secondary,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Toutes les Associations'),
                Tab(text: 'Mes Associations'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher des associations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssociationsList(_allAssociations),
                _buildAssociationsList(_myAssociations),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              heroTag: 'createAssociationFAB',
              onPressed: () => context.go('/associations/create-association'),
              backgroundColor: theme.primaryColor,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle association'),
            )
          : null,
    );
  }
}
