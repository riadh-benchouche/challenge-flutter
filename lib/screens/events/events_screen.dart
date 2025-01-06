import 'package:challenge_flutter/models/event.dart';
import 'package:challenge_flutter/providers/event_provider.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver {
  late TabController _tabController;
  late FocusNode _focusNode;
  bool _isFirstLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    debugPrint('EventScreen - initState');
    _tabController = TabController(length: 2, vsync: this);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addObserver(this);
    _loadEvents();

    _tabController.addListener(() {
      _loadEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ne charger qu'au premier appel de didChangeDependencies
    if (_isFirstLoad) {
      final eventProvider = Provider.of<EventProvider>(context);
      if (eventProvider.shouldSwitchToParticipating) {
        _tabController.animateTo(1);
        eventProvider.resetSwitchFlag();
      }
      _loadEvents();
      _isFirstLoad = false;
    }
  }

  void _loadEvents() async {
    if (!mounted) return;
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Charger en fonction de l'onglet actif
    if (_tabController.index == 0) {
      // Onglet "Les Événements"
      if (!eventProvider.isLoadingAssociations) {
        await eventProvider.fetchAssociationEvents();
      }
    } else {
      // Onglet "Mes participations"
      if (!eventProvider.isLoadingParticipations) {
        await eventProvider.fetchParticipatingEvents();
      }
    }
  }

  Widget _buildEventsList(List<Event>? events) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final isLoading = _tabController.index == 0
            ? eventProvider.isLoadingAssociations
            : eventProvider.isLoadingParticipations;

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (events == null || events.isEmpty) {
          return const Center(
            child: Text('Aucun événement trouvé'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadEvents(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
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
    super.build(context);
    final theme = Theme.of(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          debugPrint('EventScreen - Gained focus');
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
              child: Consumer<EventProvider>(
                builder: (context, eventProvider, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventsList(eventProvider.associationEvents),
                      _buildEventsList(eventProvider.participatingEvents),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: eventProvider.canCreateEvent
            ? FloatingActionButton.extended(
                heroTag: 'createEventFAB',
                // Ajout du heroTag unique
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
