import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
import 'package:challenge_flutter/widgets/home/association_card_widget.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:challenge_flutter/widgets/home/stat_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedRoute = '/';

  void _onItemTapped(String route) {
    setState(() {
      _selectedRoute = route;
    });
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        theme: theme,
        userName: 'John Doe',
        pageTitle: 'Home',
        onAddPressed: () {
          // Votre logique pour le bouton d'ajout
        },
        onProfilePressed: () {
          // Votre logique pour le bouton profil
        },
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
                  StatCard(
                    title: 'Events',
                    count: '10',
                    icon: Icons.event,
                    theme: theme,
                  ),
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
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Navigate to All Events Page
                    },
                    // text with icon
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AssociationCard(
                    associationName: 'Association 1',
                    imageSrc: 'assets/images/association-1.jpg',
                    theme: theme,
                  ),
                  AssociationCard(
                    associationName: 'Association 2',
                    imageSrc: 'assets/images/association-1.jpg',
                    theme: theme,
                  ),
                  AssociationCard(
                    associationName: 'Association 3',
                    imageSrc: 'assets/images/association-1.jpg',
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Upcoming Events
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Événements à venir',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Navigate to All Events Page
                    },
                    // text with icon
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              EventCard(
                  eventName: 'Event 1',
                  eventDate: 'Date: Jan 12, 2024',
                  theme: theme),
              const SizedBox(height: 10),
              EventCard(
                  eventName: 'Event 2',
                  eventDate: 'Date: Jan 5, 2024',
                  theme: theme),
              const SizedBox(height: 10),
              EventCard(
                  eventName: 'Event 3',
                  eventDate: 'Date: Jan 2, 2024',
                  theme: theme)
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedRoute: _selectedRoute,
        theme: theme,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
