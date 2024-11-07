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
                  _buildStatCard('Associations', '5', Icons.group, theme),
                  _buildStatCard('Messages', '12', Icons.message, theme),
                  _buildStatCard('Events', '3', Icons.event, theme),
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
                  _buildAssociationCard(
                      'Association 1',
                      'https://static-cse.canva.com/blob/1759875/1600w-EgmHp0rUqI4.jpg',
                      theme),
                  _buildAssociationCard(
                      'Association 2',
                      'https://static-cse.canva.com/blob/1759875/1600w-EgmHp0rUqI4.jpg',
                      theme),
                  _buildAssociationCard(
                      'Association 3',
                      'https://static-cse.canva.com/blob/1759875/1600w-EgmHp0rUqI4.jpg',
                      theme),
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
              _buildEventCard('Event 1', 'Date: Jan 12, 2024', theme),
              const SizedBox(height: 10),
              _buildEventCard('Event 2', 'Date: Feb 5, 2024', theme),
              const SizedBox(height: 10),
              _buildEventCard('Event 3', 'Date: Mar 15, 2024', theme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: theme.primaryColor,
        child: Row(
          children: [
            _buildNavBarItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              theme: theme,
            ),
            _buildNavBarItem(
              icon: Icons.event_rounded,
              label: 'Events',
              index: 1,
              theme: theme,
            ),
            _buildNavBarItem(
              icon: Icons.home_work_rounded,
              label: 'Associations',
              index: 2,
              theme: theme,
            ),
            // chat icon
            _buildNavBarItem(
              icon: Icons.message_rounded,
              label: 'Messages',
              index: 3,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create a statistic card
  Widget _buildStatCard(
      String title, String count, IconData icon, ThemeData theme) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: theme.primaryColor, size: 30),
              const SizedBox(height: 10),
              Text(
                count,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create an event card
  Widget _buildEventCard(String eventName, String eventDate, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: ListTile(
        title: Text(eventName),
        subtitle: Text(eventDate),
        trailing: Icon(Icons.arrow_forward, color: theme.primaryColor),
        onTap: () {
          // Navigate to Event Details Page
        },
      ),
    );
  }

  // Helper function to create an association card
  Widget _buildAssociationCard(
      String associationName, String imageUrl, ThemeData theme) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Utilisation de l'image à la place de l'icône
              ClipRRect(
                // border Radius for the image full
                borderRadius: BorderRadius.circular(
                  8,
                ),
                child: Image.asset(
                  'assets/images/association-1.jpg',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                associationName,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
      {required IconData icon,
      required String label,
      required int index,
      required ThemeData theme}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          _onItemTapped(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: _selectedIndex == index
                  ? theme.colorScheme.secondary
                  : Colors.white,
            ),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index
                    ? theme.colorScheme.secondary
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
