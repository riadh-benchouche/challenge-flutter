import 'package:challenge_flutter/models/association.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challenge_flutter/providers/association_provider.dart';

class AssociationDetailScreen extends StatefulWidget {
  final String associationId;

  const AssociationDetailScreen({super.key, required this.associationId});

  @override
  _AssociationDetailScreenState createState() =>
      _AssociationDetailScreenState();
}

class _AssociationDetailScreenState extends State<AssociationDetailScreen> {
  late Future<Association> _associationFuture;

  @override
  void initState() {
    super.initState();
    _loadAssociation();
  }

  void _loadAssociation() {
    final associationProvider =
        Provider.of<AssociationProvider>(context, listen: false);
    _associationFuture =
        associationProvider.fetchAssociationById(widget.associationId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text('Détails de l\'association',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Association>(
        future: _associationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadAssociation();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Association non trouvée'),
            );
          }

          final association = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(0)),
                  child: Image.network(
                    association.imageUrl == ''
                        ? 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png'
                        : association.imageUrl,
                    height: 380,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/association-1.jpg',
                        height: 380,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
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
                            association.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          Icon(
                            association.isActive
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: association.isActive
                                ? Colors.green
                                : Colors.red,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        association.description,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      if (association.code != null)
                        _buildDetailRow(
                            theme, Icons.vpn_key, 'Code: ${association.code}'),
                      const SizedBox(height: 10),
                      _buildDetailRow(theme, Icons.group,
                          'Membres: 11'),
                      const SizedBox(height: 10),
                      _buildDetailRow(theme, Icons.event,
                          'Événements: 12'),
                      const SizedBox(height: 10),
                      _buildDetailRow(theme, Icons.calendar_today,
                          'Créée le: ${association.createdAt.toLocal().toString().split(' ')[0]}'),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                            ),
                            onPressed: () {
                              // Implémenter la fonctionnalité de contact
                            },
                            child: const Text(
                              'Contacter',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                            ),
                            onPressed: () {
                              // Implémenter la fonctionnalité pour rejoindre
                            },
                            child: const Text(
                              'Rejoindre',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
