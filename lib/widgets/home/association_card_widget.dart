import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssociationCard extends StatelessWidget {
  final String associationId;
  final String associationName;
  final String imageSrc;
  final int userCount;
  final int eventCount;
  final String description;
  final bool isActive;

  const AssociationCard({
    super.key,
    required this.associationId,
    required this.associationName,
    required this.imageSrc,
    required this.userCount,
    required this.eventCount,
    required this.description,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias, // Pour s'assurer que rien ne dépasse
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.go('/associations/$associationId'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture
            Stack(
              children: [
                Image.network(
                  'http://10.0.2.2:3000/$imageSrc',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/association-1.jpg',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                // Badge de statut
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de l'association
                  Text(
                    associationName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(context, Icons.event, eventCount.toString()),
                      _buildStat(context, Icons.person, userCount.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
