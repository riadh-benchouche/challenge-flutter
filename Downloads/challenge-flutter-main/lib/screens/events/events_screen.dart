import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  String _selectedRoute = '/events';

  void _onItemTapped(String route) {
    setState(() {
      _selectedRoute = route;
    });
    context.go(route);
  }

  final events = [
    {'title': 'Réunion des membres', 'date': '12/11/2024'},
    {'title': 'Atelier de programmation', 'date': '15/11/2024'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        theme: theme,
        userName: 'John Doe',
        pageTitle: 'Events',
        onAddPressed: () {
          // Votre logique pour le bouton d'ajout
        },
        onProfilePressed: () {
          // Votre logique pour le bouton profil
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: events.map((event) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: EventCard(
                        eventName: '${event['title']}',
                        eventDate: '${event['date']}',
                        theme: theme,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedRoute: _selectedRoute,
        theme: theme,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
