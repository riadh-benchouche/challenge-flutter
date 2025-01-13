import 'package:flutter/material.dart';
import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:challenge_flutter/widgets/home/association_card_widget.dart';

class AssociationsListContent extends StatelessWidget {
  final AsyncSnapshot<List<Association>> snapshot;
  final String searchQuery;
  final String emptyMessage;
  final bool isMyList;

  const AssociationsListContent({
    super.key,
    required this.snapshot,
    required this.searchQuery,
    required this.emptyMessage,
    required this.isMyList,
  });

  List<Association> _filterAssociations(List<Association> associations, String query) {
    if (query.isEmpty) return associations;
    return associations.where((association) {
      return association.name.toLowerCase().contains(query.toLowerCase()) ||
          association.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Gestion du chargement
    if (snapshot.connectionState == ConnectionState.waiting) {
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
                  fontSize: 16
              ),
            ),
          ],
        ),
      );
    }

    // Gestion des erreurs
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue:\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => (context as Element).markNeedsBuild(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // Filtrer les associations selon la recherche
    final associations = snapshot.data ?? [];
    final filteredAssociations = _filterAssociations(associations, searchQuery);

    // Gestion liste vide
    if (filteredAssociations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? emptyMessage
                  : 'Aucune association trouvée pour "$searchQuery"',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier vos critères de recherche',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    // Affichage des associations
    return RefreshIndicator(
      onRefresh: () async => (context as Element).markNeedsBuild(),
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
}