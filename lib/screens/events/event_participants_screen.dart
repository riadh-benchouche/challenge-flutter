import 'package:challenge_flutter/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:challenge_flutter/models/participation.dart';

class EventParticipantsScreen extends StatefulWidget {
  final String eventId;

  const EventParticipantsScreen({super.key, required this.eventId});

  @override
  State<EventParticipantsScreen> createState() =>
      _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  bool _isLoading = false;
  bool _isLoadingConfirmation = false;
  List<Participation> _participants = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  // Charger les participants pour cet événement
  Future<void> _loadParticipants() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final participants =
          await EventService.getEventParticipations(widget.eventId);

      if (mounted) {
        setState(() {
          _participants =
              participants.map((json) => Participation.fromJson(json)).toList();
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

  // Confirmer la présence d'un participant
  Future<void> _confirmParticipation(String participationId) async {
    if (_isLoadingConfirmation) return;

    setState(() => _isLoadingConfirmation = true);

    try {
      await EventService.confirmParticipation(participationId);
      await _loadParticipants();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Présence confirmée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingConfirmation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si on charge les participants, afficher un indicateur de chargement
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si une erreur survient, l'afficher et proposer de réessayer
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $_error'),
              ElevatedButton(
                onPressed: _loadParticipants,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    // Si aucun participant n'est présent, afficher un message
    if (_participants.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Participants'),
        ),
        body: const Center(
          child: Text(
            'Aucun participant pour cet événement.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // Afficher la liste des participants
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParticipants,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _participants.length,
        itemBuilder: (context, index) {
          final participant = _participants[index];
          return ListTile(
            title: Text(participant.user?.name ?? 'Utilisateur inconnu'),
            subtitle: Text('Statut: ${participant.status}'),
            trailing: IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _confirmParticipation(participant.id),
            ),
          );
        },
      ),
    );
  }
}
