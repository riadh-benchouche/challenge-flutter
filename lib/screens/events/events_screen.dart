import 'package:challenge_flutter/models/event.dart';
import 'package:challenge_flutter/providers/event_provider.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Event>> _associationEventsFuture;
  late Future<List<Event>> _participatingEventsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final eventProvider = Provider.of<EventProvider>(context);
    if (eventProvider.shouldSwitchToParticipating) {
      _tabController.animateTo(1); // Switch to the participating tab
      eventProvider.resetSwitchFlag(); // Reset the flag
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    _associationEventsFuture = eventProvider.fetchAssociationEvents();
    _participatingEventsFuture = eventProvider.fetchParticipatingEvents();
  }

  Widget _buildEventsList(Future<List<Event>> future) {
    return FutureBuilder<List<Event>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
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
                ElevatedButton(
                  onPressed: () => setState(() => _loadEvents()),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Aucun événement trouvé'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadEvents(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];
              return EventCard(
                eventId: event.id,
                eventName: event.name,
                eventDate: event.date.toString(),
                eventLocation: event.location,
                eventAssociation: event.associationName,
                eventCategory: event.categoryName,
                theme: Theme.of(context),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.secondary,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Les Événements'),
                Tab(text: 'Mes participations'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsList(_associationEventsFuture),
                _buildEventsList(_participatingEventsFuture),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
