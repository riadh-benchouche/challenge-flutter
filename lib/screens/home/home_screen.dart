import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/models/event.dart';
import 'package:challenge_flutter/models/statistics.dart';
import 'package:challenge_flutter/providers/home_provider.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:challenge_flutter/widgets/home/stat_card_widget.dart';
import 'package:challenge_flutter/widgets/home/top_association_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadAllData();
  }

  Future<void> _loadAllData() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    try {
      await homeProvider.refreshAll();
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
      rethrow;
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

  Widget _buildTopAssociations(BuildContext context, List<Association>? associations) {
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

    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
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
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadDataFuture = _loadAllData();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return RefreshIndicator(
                onRefresh: _loadAllData,
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
                        _buildStatistics(context, homeProvider.statistics),
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
                        _buildTopAssociations(
                            context, homeProvider.topAssociations),
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
                        _buildEvents(context, homeProvider.recentEvents),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
