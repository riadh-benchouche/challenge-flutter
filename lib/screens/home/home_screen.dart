import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/models/event.dart';
import 'package:challenge_flutter/models/statistics.dart';
import 'package:challenge_flutter/services/home_service.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:challenge_flutter/widgets/home/stat_card_widget.dart';
import 'package:challenge_flutter/widgets/home/top_association_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
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
      await HomeService.refreshAll();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStatistics(BuildContext context, Statistics? stats) {
    if (stats == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatCard(
          title: 'Associations',
          count: stats.totalAssociations.toString(),
          icon: Icons.group,
          theme: theme,
        ),
        // expanded widget to take the remaining space
        const Padding(padding: EdgeInsets.all(4)),
        StatCard(
          title: 'Événements',
          count: stats.totalEvents.toString(),
          icon: Icons.event,
          theme: theme,
        ),
        const Padding(padding: EdgeInsets.all(4)),
        StatCard(
          title: 'Membres',
          count: stats.totalUsers.toString(),
          icon: Icons.person,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildTopAssociations(
      BuildContext context, List<Association>? associations) {
    if (associations == null || associations.isEmpty) {
      return const Center(child: Text('Aucune association trouvée'));
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: associations.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final association = associations[index];
          return TopAssociationCard(
            name: association.name,
            imageSrc: association.imageUrl,
            userCount: 0,
          );
        },
      ),
    );
  }

  Widget _buildEvents(BuildContext context, List<Event>? events) {
    if (events == null || events.isEmpty) {
      return const Center(child: Text('Aucun événement à venir'));
    }

    return Column(
      children: events.map((event) {
        return EventCard(
          eventId: event.id,
          theme: Theme.of(context),
          eventName: event.name,
          eventDate: DateFormat('dd/MM/yyyy HH:mm').format(event.date),
          eventLocation: event.location,
          eventAssociation: event.associationName,
          eventCategory: event.categoryName,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistiques',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              _buildStatistics(context, HomeService.statistics),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Associations',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/associations'),
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
              _buildTopAssociations(context, HomeService.topAssociations),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Événements à venir',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/events'),
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
              _buildEvents(context, HomeService.recentEvents),
            ],
          ),
        ),
      ),
    );
  }
}
