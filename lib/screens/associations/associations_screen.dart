import 'package:challenge_flutter/models/association.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challenge_flutter/providers/association_provider.dart';
import 'package:challenge_flutter/widgets/home/association_card_widget.dart';

class AssociationsScreen extends StatefulWidget {
  const AssociationsScreen({super.key});

  @override
  _AssociationsScreenState createState() => _AssociationsScreenState();
}

class _AssociationsScreenState extends State<AssociationsScreen> {
  String _searchQuery = '';
  late Future<List<Association>> _associationsFuture;

  @override
  void initState() {
    super.initState();
    _loadAssociations();
  }

  void _loadAssociations() {
    final associationProvider = Provider.of<AssociationProvider>(context, listen: false);
    _associationsFuture = associationProvider.fetchAssociations();
  }

  List<Association> _filterAssociations(List<Association> associations, String query) {
    if (query.isEmpty) return associations;
    return associations.where((association) {
      return association.name.toLowerCase().contains(query.toLowerCase()) ||
          association.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Rechercher des associations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Association>>(
              future: _associationsFuture,
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
                              _loadAssociations();
                            });
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Aucune association trouvée'),
                  );
                }

                final filteredAssociations = _filterAssociations(snapshot.data!, _searchQuery);

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadAssociations();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                    ),
                    itemCount: filteredAssociations.length,
                    itemBuilder: (context, index) {
                      final association = filteredAssociations[index];
                      return AssociationCard(
                        associationId: association.id,
                        associationName: association.name,
                        imageSrc: association.imageUrl == ''
                            ? 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png'
                            : association.imageUrl,
                        userCount: 12,
                        eventCount: 13,
                        description: association.description,
                        isActive: association.isActive,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}