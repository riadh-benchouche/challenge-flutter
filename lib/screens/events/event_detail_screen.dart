import 'package:challenge_flutter/models/event.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:challenge_flutter/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  bool _isParticipating = false;
  bool _isLoading = false;
  bool _isLoadingParticipation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final event = await EventService.getEventById(widget.eventId);
      final isParticipating =
          await EventService.checkEventParticipation(widget.eventId);

      if (mounted) {
        setState(() {
          _event = event;
          _isParticipating = isParticipating;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleParticipation() async {
    if (_isLoadingParticipation) return;

    if (_isParticipating) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Se désinscrire'),
          content: const Text(
              'Voulez-vous vraiment vous désinscrire de cet événement ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Me désinscrire'),
            ),
          ],
        ),
      );

      if (shouldLeave != true) return;
    }

    setState(() => _isLoadingParticipation = true);

    try {
      await EventService.toggleEventParticipation(
          widget.eventId, !_isParticipating);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !_isParticipating
                  ? 'Vous vous êtes désinscrit de l\'événement'
                  : 'Vous participez maintenant à l\'événement',
            ),
            backgroundColor: _isParticipating ? Colors.orange : Colors.green,
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
        setState(() => _isLoadingParticipation = false);
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

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: const Text('Erreur', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $_error'),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_event == null) {
      return const Scaffold(
        body: Center(child: Text('Événement non trouvé')),
      );
    }

    final event = _event!;
    final isOwner =
        event.association?['owner_id'] == AuthService.userData?['id'];
    final formattedDate =
        DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(event.date);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text('Détails de l\'événement',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => context.go('/edit-event/${event.id}'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
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
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 24,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
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
                    _buildDetailRow(theme, Icons.calendar_today, formattedDate),
                    const SizedBox(height: 12),
                    _buildDetailRow(theme, Icons.location_on, event.location),
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
                          backgroundColor: _isParticipating
                              ? Colors.red.shade400
                              : theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: _isLoadingParticipation
                            ? null
                            : _toggleParticipation,
                        child: _isLoadingParticipation
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
                                    _isParticipating
                                        ? Icons.exit_to_app
                                        : Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isParticipating
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
                    if (isOwner) // Si c'est l'admin/propriétaire
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              // Ouvrir la page des participants
                              context.go('/events/${event.id}/participants');
                            },
                            child: const Text(
                              'Voir les participants',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
