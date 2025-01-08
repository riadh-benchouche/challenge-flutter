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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late TabController _tabController;
  FocusNode _focusNode = FocusNode(); // Initialisation directe

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        if (eventProvider.shouldSwitchToParticipating) {
          _tabController.animateTo(1);
          eventProvider.resetSwitchFlag();
        }
        _loadEvents();
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        _loadEvents();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    try {
      if (_tabController.index == 0) {
        await eventProvider.fetchAssociationEvents();
      } else {
        await eventProvider.fetchParticipatingEvents();
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
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