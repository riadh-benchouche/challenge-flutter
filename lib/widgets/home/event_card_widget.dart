import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final String eventId;
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String eventAssociation;
  final String eventCategory;
  final ThemeData theme;

  const EventCard({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.eventAssociation,
    required this.eventCategory,
    required this.theme,
  });

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR');
      return formatter.format(date);
    } catch (e) {
      return dateString; // Retourne la chaîne originale si le parsing échoue
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(eventDate);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          context.go('/events/$eventId');
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.event, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      eventLocation,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.group, color: Colors.white70, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Association: $eventAssociation',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.category, color: Colors.white70, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Category: $eventCategory',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
