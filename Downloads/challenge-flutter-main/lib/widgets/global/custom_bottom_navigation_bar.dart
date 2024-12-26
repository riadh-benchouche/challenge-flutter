import 'package:flutter/material.dart';
import 'nav_bar_item_widget.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String selectedRoute;
  final ThemeData theme;
  final Function(String) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedRoute,
    required this.theme,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: theme.primaryColor,
      child: Row(
        children: [
          NavBarItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selectedRoute: selectedRoute,
            theme: theme,
            route: '/',
            onItemTapped: onItemTapped,
          ),
          NavBarItem(
            icon: Icons.event_rounded,
            label: 'Events',
            selectedRoute: selectedRoute,
            route: '/events',
            theme: theme,
            onItemTapped: onItemTapped,
          ),
          NavBarItem(
            icon: Icons.home_work_rounded,
            label: 'Associations',
            selectedRoute: selectedRoute,
            theme: theme,
            route: '/associations',
            onItemTapped: onItemTapped,
          ),
          NavBarItem(
            icon: Icons.message_rounded,
            label: 'Messages',
            selectedRoute: selectedRoute,
            theme: theme,
            route: '/messages',
            onItemTapped: onItemTapped,
          ),
        ],
      ),
    );
  }
}
