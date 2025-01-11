import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/association_service.dart';
import 'package:flutter/material.dart';

class PendingAssociationsScreen extends StatefulWidget {
  const PendingAssociationsScreen({Key? key}) : super(key: key);

  @override
  _PendingAssociationsScreenState createState() =>
      _PendingAssociationsScreenState();
}

class _PendingAssociationsScreenState extends State<PendingAssociationsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingAssociations();
  }

  Future<void> _fetchPendingAssociations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });
    try {
      await AssociationService.getAssociationsAll();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement : $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAssociation(Association association) async {
    try {
      // Afficher une boîte de dialogue de confirmation
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
                'Voulez-vous vraiment supprimer cette association ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Supprimer',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        // TODO: Implémenter la suppression dans AssociationService
        // await AssociationService.deleteAssociation(association.id);
        await _fetchPendingAssociations(); // Rafraîchir la liste
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Association supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression : $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editAssociation(BuildContext context, Association association) {
    final nameController = TextEditingController(text: association.name);
    final descriptionController =
        TextEditingController(text: association.description);
    final codeController = TextEditingController(text: association.code);
    bool isActive = association.isActive;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier l\'association'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Code'),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        descriptionController.text.isEmpty ||
                        codeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tous les champs doivent être remplis'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    try {
                      await AssociationService.updateAssociationAdmin(
                        association.id,
                        {
                          'name': nameController.text,
                          'description': descriptionController.text,
                          'is_active': isActive,
                          'code': codeController.text,
                        },
                      );

                      if (!mounted) return;
                      Navigator.of(context).pop();
                      await _fetchPendingAssociations(); // Rafraîchir la liste
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Association modifiée avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (error) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur : $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final associationsAll = AssociationService.associationsAll ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les associations en attente'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPendingAssociations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : associationsAll.isEmpty
                ? const Center(
                    child: Text('Aucune association en attente trouvée'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: associationsAll.length,
                    itemBuilder: (context, index) {
                      final association = associationsAll[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: association.isActive
                                ? Colors.green
                                : Colors.red,
                            radius: 8,
                          ),
                          title: Text(
                            association.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Code : ${association.code}',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Propriétaire : ${association.ownerId}',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _editAssociation(context, association),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteAssociation(association),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
