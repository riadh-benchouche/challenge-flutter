import 'package:challenge_flutter/providers/association_provider.dart';
import 'package:challenge_flutter/providers/event_provider.dart';
import 'package:challenge_flutter/providers/home_provider.dart';
import 'package:challenge_flutter/providers/message_provider.dart';
import 'package:challenge_flutter/screens/associations/associations_screen.dart';
import 'package:challenge_flutter/screens/events/events_screen.dart';
import 'package:challenge_flutter/screens/home/home_screen.dart';
import 'package:challenge_flutter/screens/messages/messages_screen.dart';
import 'package:challenge_flutter/widgets/global/custom_app_bar.dart';
import 'package:challenge_flutter/widgets/global/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challenge_flutter/providers/user_provider.dart';

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
    _loadDataForCurrentTab();
  }

  void _loadDataForCurrentTab() {
    if (!mounted) return;

    switch (_currentIndex) {
      case 0: // Home
        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        homeProvider.refreshAll();
        break;
      case 1: // Events
        final eventProvider =
            Provider.of<EventProvider>(context, listen: false);
        eventProvider.fetchAssociationEvents();
        eventProvider.fetchParticipatingEvents();
        break;
      case 2: // Associations
        final associationProvider =
            Provider.of<AssociationProvider>(context, listen: false);
        associationProvider.fetchAssociationByUser();
        associationProvider.fetchAssociations();
        break;
      case 3: // Messages
        final messageProvider =
            Provider.of<MessageProvider>(context, listen: false);
        messageProvider.loadUserAssociations();
        break;
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventScreen(),
    const AssociationsScreen(),
    MessagesScreen(),
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
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    final userName = userData?['name'] ?? 'Utilisateur';

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
          _loadDataForCurrentTab();
        },
      ),
    );
  }
}
