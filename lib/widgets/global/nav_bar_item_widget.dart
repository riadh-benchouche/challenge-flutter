import 'package:flutter/material.dart';

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String selectedRoute;
  final ThemeData theme;
  final String route;
  final Function(String) onItemTapped;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selectedRoute,
    required this.theme,
    required this.route,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selectedRoute == route
                  ? theme.colorScheme.secondary
                  : Colors.white,
            ),
            Text(
              label,
              style: TextStyle(
                color: selectedRoute == route
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
