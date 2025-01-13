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
  bool _isLoadingAssoc = false;
  bool _isLoadingParticipating = false;
  List<Event>? _associationEvents;
  List<Event>? _participatingEvents;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (EventService.shouldSwitchToParticipating) {
          _tabController.animateTo(1);
          EventService.resetSwitchFlag();
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
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;

    setState(() {
      _error = null;
      if (_tabController.index == 0) {
        _isLoadingAssoc = true;
      } else {
        _isLoadingParticipating = true;
      }
    });

    try {
      if (_tabController.index == 0) {
        _associationEvents = await EventService.getAssociationEvents();
      } else {
        _participatingEvents = await EventService.getParticipatingEvents();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAssoc = false;
          _isLoadingParticipating = false;
        });
      }
    }
  }

  Widget _buildEventsList(List<Event>? events, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEvents,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (events == null || events.isEmpty) {
      return const Center(
        child: Text('Aucun événement trouvé'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
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
            isOwner:
                event.association?['owner_id'] == AuthService.userData?['id'],
          );
        },
      ),
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
                  _buildEventsList(_associationEvents, _isLoadingAssoc),
                  _buildEventsList(
                      _participatingEvents, _isLoadingParticipating),
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
