import 'package:challenge_flutter/widgets/home/association_card_widget.dart';
import 'package:flutter/material.dart';

class AssociationsScreen extends StatefulWidget {
  const AssociationsScreen({super.key});

  @override
  _AssociationsScreenState createState() => _AssociationsScreenState();
}

class _AssociationsScreenState extends State<AssociationsScreen> {
  List<Map<String, dynamic>> associations = [
    {
      'id': '1',
      'name': 'Association A',
      'imageSrc': 'assets/images/association-1.jpg',
      'userCount': 150,
      'eventCount': 10,
      'description': 'A great community for health and wellness.',
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Association B',
      'imageSrc': 'assets/images/association-1.jpg',
      'userCount': 200,
      'eventCount': 15,
      'description': 'Fostering youth through music and art.',
      'isActive': false,
    },
  ];

  List<Map<String, dynamic>> filteredAssociations = [];

  @override
  void initState() {
    super.initState();
    filteredAssociations = associations;
  }

  void _filterAssociations(String query) {
    final results = associations.where((association) {
      final name = association['name'] as String;
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredAssociations = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: _filterAssociations,
              decoration: InputDecoration(
                hintText: 'Search associations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemCount: filteredAssociations.length,
              itemBuilder: (context, index) {
                final association = filteredAssociations[index];
                return AssociationCard(
                  associationId: association['id'] as String,
                  associationName: association['name'] as String,
                  imageSrc: association['imageSrc'] as String,
                  userCount: association['userCount'] as int,
                  eventCount: association['eventCount'] as int,
                  description: association['description'] as String,
                  isActive: association['isActive'] as bool,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
