import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();
      if (context.mounted) {
        // Redirection vers la page de login après déconnexion
        context.go('/login');  // ou context.go('/') selon votre configuration
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue dans le tableau de bord admin !',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/admin/dashboard/users');
              },
              icon: const Icon(Icons.people),
              label: const Text('Gérer les utilisateurs'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/admin/dashboard/pending-associations');
              },
              icon: const Icon(Icons.verified_user),
              label: const Text('Activer les associations'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}
