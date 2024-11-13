import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = {
      'name': 'Charity Run',
      'description': 'Join us for a charity run to raise funds for local schools.',
      'date': 'April 25, 2024',
      'location': 'Central Park, New York',
      'category': 'Sports',
      'association': 'Health & Wellness Club',
      'imageUrl': 'assets/images/event-1.jpg',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text('Event Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture de l'événement
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
              child: Image.asset(
                event['imageUrl']!,
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
                  Text(
                    event['name']!,
                    style: TextStyle(
                      fontSize: 28,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event['description']!,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // Détails de l'événement
                  _buildDetailRow(theme, Icons.calendar_today, event['date']!),
                  const SizedBox(height: 10),
                  _buildDetailRow(theme, Icons.location_on, event['location']!),
                  const SizedBox(height: 10),
                  _buildDetailRow(theme, Icons.category, 'Category: ${event['category']}'),
                  const SizedBox(height: 10),
                  _buildDetailRow(theme, Icons.group, 'Association: ${event['association']}'),
                  const SizedBox(height: 30),
                  // Bouton pour rejoindre l'événement
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      onPressed: () {
                        // Action pour rejoindre l'événement
                      },
                      child: const Text(
                        'Join Event',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
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
