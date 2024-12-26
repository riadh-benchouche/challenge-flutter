import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final String userName;
  final String pageTitle;
  final VoidCallback onAddPressed;
  final VoidCallback onProfilePressed;

  const CustomAppBar({
    super.key,
    required this.theme,
    required this.userName,
    required this.pageTitle,
    required this.onAddPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi, $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pageTitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: onAddPressed,
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: onProfilePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}
