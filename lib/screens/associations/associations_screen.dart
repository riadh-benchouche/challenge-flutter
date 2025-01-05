import 'package:challenge_flutter/models/association.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:challenge_flutter/providers/association_provider.dart';
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
  Future<List<Association>>? _myAssociationsFuture;
  Future<List<Association>>? _allAssociationsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssociations();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Recharger les données quand on change d'onglet
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
    final associationProvider =
        Provider.of<AssociationProvider>(context, listen: false);
    setState(() {
      _myAssociationsFuture = associationProvider.fetchAssociationByUser();
      _allAssociationsFuture = associationProvider.fetchAssociations();
    });
  }

  List<Association> _filterAssociations(
      List<Association> associations, String query) {
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
          Icon(
            Icons.group_off,
            size: 64,
            color: Colors.grey[400],
          ),
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
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur: ${error.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationsList(Future<List<Association>>? future) {
    if (future == null) {
      return _buildEmptyState();
    }

    return FutureBuilder<List<Association>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(
            snapshot.error!,
            () => setState(() => _loadAssociations()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final filteredAssociations =
            _filterAssociations(snapshot.data!, _searchQuery);

        if (filteredAssociations.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadAssociations,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 1,
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
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final associationProvider =
        Provider.of<AssociationProvider>(context); // Ajout de cette ligne

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
                Tab(text: 'Mes Associations'),
                Tab(text: 'Toutes les Associations'),
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
                _buildAssociationsList(_myAssociationsFuture),
                _buildAssociationsList(_allAssociationsFuture),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: associationProvider.canCreateAssociation
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
