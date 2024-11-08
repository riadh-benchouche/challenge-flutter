import 'package:flutter/material.dart';

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ThemeData theme;
  final Function(int) onItemTapped;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.theme,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selectedIndex == index
                  ? theme.colorScheme.secondary
                  : Colors.white,
            ),
            Text(
              label,
              style: TextStyle(
                color: selectedIndex == index
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
