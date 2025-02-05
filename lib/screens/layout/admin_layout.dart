import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({Key? key, required this.child}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthService.logout();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la déconnexion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
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
                label: Text('Associations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category),
                label: Text('Catégories'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () => _handleLogout(context),
                    child: const Icon(Icons.logout, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
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
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/users');
        break;
      case 2:
        context.go('/admin/pending-associations');
        break;
      case 3:
        context.go('/admin/categories');
        break;
    }
  }
}
