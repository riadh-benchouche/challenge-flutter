import 'package:challenge_flutter/widgets/global/nav_bar_item_widget.dart';
import 'package:challenge_flutter/widgets/home/association_card_widget.dart';
import 'package:challenge_flutter/widgets/home/event_card_widget.dart';
import 'package:challenge_flutter/widgets/home/stat_card_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          decoration: BoxDecoration(
            color: theme.primaryColor,
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Hi, John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatCard(
                    title: 'Associations',
                    count: '5',
                    icon: Icons.group,
                    theme: theme,
                  ),
                  StatCard(
                    title: 'Events',
                    count: '10',
                    icon: Icons.event,
                    theme: theme,
                  ),
                  StatCard(
                    title: 'Members',
                    count: '100',
                    icon: Icons.person,
                    theme: theme,
                  ),
                ],
              ),
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
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Navigate to All Events Page
                    },
                    // text with icon
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AssociationCard(
                    associationName: 'Association 1',
                    imageSrc: 'assets/images/association-1.jpg',
                    theme: theme,
                  ),
                  AssociationCard(
                    associationName: 'Association 2',
                    imageSrc: 'assets/images/association-1.jpg',
                    theme: theme,
                  ),
                  AssociationCard(
                    associationName: 'Association 3',
                    imageSrc: 'assets/images/association-1.jpg',
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Upcoming Events
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
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Navigate to All Events Page
                    },
                    // text with icon
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              EventCard(
                  eventName: 'Event 1',
                  eventDate: 'Date: Jan 12, 2024',
                  theme: theme),
              const SizedBox(height: 10),
              EventCard(
                  eventName: 'Event 2',
                  eventDate: 'Date: Jan 5, 2024',
                  theme: theme),
              const SizedBox(height: 10),
              EventCard(
                  eventName: 'Event 3',
                  eventDate: 'Date: Jan 2, 2024',
                  theme: theme)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: theme.primaryColor,
        child: Row(
          children: [
            NavBarItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              selectedIndex: _selectedIndex,
              theme: theme,
              onItemTapped: _onItemTapped,
            ),
            NavBarItem(
              icon: Icons.event_rounded,
              label: 'Events',
              index: 1,
              selectedIndex: _selectedIndex,
              theme: theme,
              onItemTapped: _onItemTapped,
            ),
            NavBarItem(
              icon: Icons.home_work_rounded,
              label: 'Associations',
              index: 2,
              selectedIndex: _selectedIndex,
              theme: theme,
              onItemTapped: _onItemTapped,
            ),
            NavBarItem(
              icon: Icons.message_rounded,
              label: 'Messages',
              index: 3,
              selectedIndex: _selectedIndex,
              theme: theme,
              onItemTapped: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}
