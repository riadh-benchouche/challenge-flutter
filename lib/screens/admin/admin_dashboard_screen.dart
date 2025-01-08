import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
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
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la gestion des utilisateurs
                context.go('/admin/dashboard/users');
              },
              child: const Text('Gérer les utilisateurs'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers l'écran des associations en attente
                context.go('/admin/dashboard/pending-associations');
              },
              child: const Text('Activer les associations'),
            ),
          ],
        ),
      ),
    );
  }
}
