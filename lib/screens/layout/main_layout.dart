import 'package:challenge_flutter/screens/associations/associations_screen.dart';
import 'package:challenge_flutter/screens/events/events_screen.dart';
import 'package:challenge_flutter/screens/home/home_screen.dart';
import 'package:challenge_flutter/screens/messages/messages_screen.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventScreen(),
    const AssociationsScreen(),
    const MessagesScreen(),
  ];

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Accueil';
      case 1:
        return 'Événements';
      case 2:
        return 'Associations';
      case 3:
        return 'Messages';
      default:
        return 'Accueil';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.userData?['name'] ?? 'Utilisateur';

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        pageTitle: _getPageTitle(_currentIndex),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
