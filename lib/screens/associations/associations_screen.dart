import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
import 'package:challenge_flutter/widgets/home/association_card_widget.dart';
import 'package:flutter/material.dart';

class AssociationsScreen extends StatelessWidget {
  const AssociationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> associations = [
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

    return Scaffold(
      appBar: const CustomAppBar(
        userName: 'John Doe',
        pageTitle: 'Associations',
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: associations.length,
        itemBuilder: (context, index) {
          final association = associations[index];
          return AssociationCard(
            associationName: association['name'] as String,
            imageSrc: association['imageSrc'] as String,
            userCount: association['userCount'] as int,
            eventCount: association['eventCount'] as int,
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
