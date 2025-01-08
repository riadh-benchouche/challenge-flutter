import 'package:flutter/material.dart';

class PendingAssociationsScreen extends StatelessWidget {
  const PendingAssociationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Associations en attente'),
      ),
      body: ListView.builder(
        itemCount:
            5, // Exemple : 5 associations en attente (à remplacer par une vraie liste)
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('Association ${index + 1}'),
              subtitle: const Text('Description de l\'association'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Ajouter une logique pour activer l'association
                },
                child: const Text('Activer'),
              ),
            ),
          );
        },
      ),
    );
  }
}
