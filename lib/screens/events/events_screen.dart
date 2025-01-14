import 'package:challenge_flutter/models/event.dart';
import 'package:challenge_flutter/services/event_service.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final FocusNode _focusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _loadEvents();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {}); // Force le rebuild du FutureBuilder
  }

  Widget _buildEventsList(List<Event>? events, bool isLoading) {
    return FutureBuilder<List<Event>>(
      future: _tabController.index == 0
          ? EventService.getAssociationEvents()
          : EventService.getParticipatingEvents(),
      builder: (context, snapshot) {
        // Gestion du chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des événements...'),
              ],
            ),
          );
        }

        // Gestion des erreurs
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Une erreur est survenue:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      // Force le rebuild du FutureBuilder
                      _loadEvents();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        // Gestion de l'absence de données
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.event_busy,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _tabController.index == 0
                      ? 'Aucun événement disponible'
                      : 'Vous ne participez à aucun événement',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Affichage des événements
        return RefreshIndicator(
          onRefresh: _loadEvents,
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
                isOwner: event.association?['owner_id'] ==
                    AuthService.userData?['id'],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final canCreateEvent = EventService.canCreateEvent;

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _loadEvents();
        }
      },
      child: Scaffold(
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
                  _buildEventsList(null, false),
                  _buildEventsList(null, false),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: canCreateEvent
            ? FloatingActionButton.extended(
                heroTag: 'createEventFAB',
                onPressed: () => context.go('/events/create-event'),
                backgroundColor: theme.primaryColor,
                icon: const Icon(Icons.add),
                label: const Text('Nouvel événement'),
              )
            : null,
      ),
    );
  }
}
