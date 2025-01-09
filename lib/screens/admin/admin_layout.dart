import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminLayout extends StatelessWidget {
  final Widget child; // Contenu de la page actuelle
  const AdminLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menu latéral
          NavigationRail(
            selectedIndex: _getSelectedIndex(context),
            onDestinationSelected: (index) {
              _onMenuItemSelected(index, context);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Tableau de bord'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Utilisateurs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_user),
                label: Text('Validation Associations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category),
                label: Text('CRUD Catégories'),
              ),
            ],
          ),
          // Contenu principal
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final String location =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    if (location == '/admin') return 0;
    if (location.startsWith('/admin/users')) return 1;
    if (location.startsWith('/admin/pending-associations')) return 2;
    if (location.startsWith('/admin/categories')) return 3;
    return 0;
  }

  void _onMenuItemSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin'); // Tableau de bord
        break;
      case 1:
        context.go('/admin/users'); // Utilisateurs
        break;
      case 2:
        context.go('/admin/pending-associations'); // Validation Associations
        break;
      case 3:
        context.go('/admin/categories'); // CRUD Catégories
        break;
    }
  }
}
