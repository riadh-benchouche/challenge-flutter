import 'package:flutter/material.dart';

class AssociationDetailScreen extends StatelessWidget {
  final String associationId;

  const AssociationDetailScreen({super.key, required this.associationId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Exemple de données d'association (à remplacer par de vraies données)
    final association = {
      'name': 'Health & Wellness Club',
      'description': 'A community focused on promoting health and well-being.',
      'isActive': true,
      'code': 'HWC2023',
      'imageUrl': 'assets/images/association-1.jpg',
      'owner': 'John Doe',
      'memberCount': 150,
      'createdAt': 'January 1, 2020',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text('Association Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
              child: Image.asset(
                association['imageUrl']! as String,
                height: 380,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        association['name']! as String,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      // Indicateur de statut actif/inactif
                      Icon(
                        association['isActive']! as bool ? Icons.check_circle : Icons.cancel,
                        color: association['isActive']! as bool ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    association['description']! as String,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // Code de l'association
                  _buildDetailRow(theme, Icons.vpn_key, 'Code: ${association['code']}'),
                  const SizedBox(height: 10),
                  // Propriétaire
                  _buildDetailRow(theme, Icons.person, 'Owner: ${association['owner']}'),
                  const SizedBox(height: 10),
                  // Nombre de membres
                  _buildDetailRow(theme, Icons.group, 'Members: ${association['memberCount']}'),
                  const SizedBox(height: 10),
                  // Date de création
                  _buildDetailRow(theme, Icons.calendar_today, 'Created At: ${association['createdAt']}'),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        onPressed: () {
                          // Action pour contacter l'association ou rejoindre
                        },
                        child: const Text(
                          'Contact',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        onPressed: () {
                          // Action pour contacter l'association ou rejoindre
                        },
                        child: const Text(
                          'Join',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ]
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
