import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:challenge_flutter/services/association_service.dart';
import 'all_associations_list.dart';
import 'my_associations_list.dart';

class AssociationsScreen extends StatefulWidget {
  const AssociationsScreen({super.key});

  @override
  _AssociationsScreenState createState() => _AssociationsScreenState();
}

class _AssociationsScreenState extends State<AssociationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                AllAssociationsList(searchQuery: _searchQuery),
                MyAssociationsList(searchQuery: _searchQuery),
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