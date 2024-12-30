import 'package:challenge_flutter/models/event.dart';
import 'package:challenge_flutter/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<Event> _eventFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  void _loadEvent() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    _eventFuture = eventProvider.fetchEventById(widget.eventId);
  }

  Future<void> _toggleParticipation(Event event) async {
    if (_isLoading) return;

    if (event.isParticipating) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Quitter l\'événement'),
          content: const Text('Voulez-vous vraiment quitter cet événement ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Quitter'),
            ),
          ],
        ),
      );

      if (shouldLeave != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.toggleParticipation(event.id, !event.isParticipating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              event.isParticipating
                  ? 'Vous avez quitté l\'événement'
                  : 'Vous participez maintenant à l\'événement',
            ),
            backgroundColor:
                event.isParticipating ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text(
          'Détails de l\'événement',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Event>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _loadEvent()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Événement non trouvé'),
            );
          }

          final event = snapshot.data!;
          final formattedDate =
              DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(event.date);

          return RefreshIndicator(
            onRefresh: () async => _loadEvent(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: theme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.event,
                      size: 80,
                      color: theme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDetailRow(
                            theme, Icons.calendar_today, formattedDate),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                            theme, Icons.location_on, event.location),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          theme,
                          Icons.category,
                          'Catégorie: ${event.categoryName}',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          theme,
                          Icons.group,
                          'Association: ${event.associationName}',
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: event.isParticipating
                                  ? Colors.red.shade400
                                  : theme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () => _toggleParticipation(event),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        event.isParticipating
                                            ? Icons.exit_to_app
                                            : Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        event.isParticipating
                                            ? 'Ne plus participer'
                                            : 'Participer',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
        },
      ),
    );
  }
}
