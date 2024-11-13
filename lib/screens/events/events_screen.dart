import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, String>> events = [
      {
        'eventName': 'Charity Run',
        'eventDate': '2024-04-25',
        'eventLocation': 'Central Park, NY',
        'eventAssociation': 'Health & Wellness Club',
        'eventCategory': 'Sports',
      },
      {
        'eventName': 'Music Festival',
        'eventDate': '2024-06-10',
        'eventLocation': 'Downtown Arena',
        'eventAssociation': 'Youth Music Group',
        'eventCategory': 'Music',
      },
    ];

    return Scaffold(
      appBar: const CustomAppBar(
        userName: 'John Doe',
        pageTitle: 'Events',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
