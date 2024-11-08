import 'package:flutter/material.dart';

// String eventName, String eventDate, ThemeData theme
class EventCard extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final ThemeData theme;

  const EventCard({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: ListTile(
        title: Text(eventName),
        subtitle: Text(eventDate),
        trailing: Icon(Icons.arrow_forward, color: theme.primaryColor),
        onTap: () {
          // Navigate to Event Details Page
        },
      ),
    );
  }
}
