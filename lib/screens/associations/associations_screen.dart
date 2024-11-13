import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
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
      'name': 'Association A',
      'imageSrc': 'assets/images/association-1.jpg',
      'userCount': 150,
      'eventCount': 10,
    },
    {
      'name': 'Association B',
      'imageSrc': 'assets/images/association-1.jpg',
      'userCount': 200,
      'eventCount': 15,
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
      appBar: const CustomAppBar(
        userName: 'John Doe',
        pageTitle: 'Associations',
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredAssociations.length,
              itemBuilder: (context, index) {
                final association = filteredAssociations[index];
                return AssociationCard(
                  associationName: association['name'] as String,
                  imageSrc: association['imageSrc'] as String,
                  userCount: association['userCount'] as int,
                  eventCount: association['eventCount'] as int,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
