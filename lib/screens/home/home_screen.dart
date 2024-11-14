import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:challenge_flutter/widgets/home/stat_card_widget.dart';
import 'package:challenge_flutter/widgets/home/top_association_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> topAssociations = [
      {
        'name': 'Association A',
        'imageSrc': 'assets/images/association-1.jpg',
        'userCount': 150,
      },
      {
        'name': 'Association B',
        'imageSrc': 'assets/images/association-1.jpg',
        'userCount': 200,
      },
      {
        'name': 'Association C',
        'imageSrc': 'assets/images/association-1.jpg',
        'userCount': 180,
      },
      {
        'name': 'Association D',
        'imageSrc': 'assets/images/association-1.jpg',
        'userCount': 120,
      },
      {
        'name': 'Association E',
        'imageSrc': 'assets/images/association-1.jpg',
        'userCount': 100,
      }
    ];

    final List<Map<String, String>> events = [
      {
        'eventName': 'Charity Run',
        'eventDate': 'April 25, 2024',
        'eventLocation': 'Central Park, NY',
        'eventAssociation': 'Health & Wellness Club',
        'eventCategory': 'Sports',
      },
      {
        'eventName': 'Music Festival',
        'eventDate': 'June 10, 2024',
        'eventLocation': 'Downtown Arena',
        'eventAssociation': 'Youth Music Group',
        'eventCategory': 'Music',
      },
      {
        'eventName': 'Tech Conference',
        'eventDate': 'May 15, 2024',
        'eventLocation': 'Convention Center',
        'eventAssociation': 'Tech Enthusiasts',
        'eventCategory': 'Technology',
      },
    ];

    return Scaffold(
      appBar: const CustomAppBar(
        userName: 'John Doe',
        pageTitle: 'Home',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatCard(
                    title: 'Associations',
                    count: '5',
                    icon: Icons.group,
                    theme: theme,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    title: 'Events',
                    count: '10',
                    icon: Icons.event,
                    theme: theme,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    title: 'Members',
                    count: '100',
                    icon: Icons.person,
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Associations',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/associations');
                    },
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: topAssociations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final association = topAssociations[index];
                    return TopAssociationCard(
                      name: association['name'],
                      imageSrc: association['imageSrc'],
                      userCount: association['userCount'],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Événements à venir',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: events.map((event) {
                  return EventCard(
                    theme: theme,
                    eventName: event['eventName']!,
                    eventDate: event['eventDate']!,
                    eventLocation: event['eventLocation']!,
                    eventAssociation: event['eventAssociation']!,
                    eventCategory: event['eventCategory']!,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
