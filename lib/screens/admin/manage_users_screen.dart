import 'package:flutter/material.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les utilisateurs'),
      ),
      body: ListView.builder(
        itemCount:
            10, // Exemple : 10 utilisateurs (à remplacer par une vraie liste)
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text('Utilisateur ${index + 1}'),
            subtitle: const Text('Email : utilisateur@example.com'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Ajouter une logique pour supprimer un utilisateur
              },
            ),
          );
        },
      ),
    );
  }
}
