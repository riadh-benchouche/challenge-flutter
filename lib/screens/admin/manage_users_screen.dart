import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await AuthService.fetchUsers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la récupération des utilisateurs : $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editUser(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    String selectedRole = user['role'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier l\'utilisateur'),
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
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: ['admin', 'user', 'association_leader']
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role[0].toUpperCase() + role.substring(1)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedRole = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Rôle'),
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
                    if (nameController.text.isEmpty || emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tous les champs doivent être remplis'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    try {
                      await AuthService.updateUser(
                        user['id'],
                        nameController.text,
                        emailController.text,
                        selectedRole,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Utilisateur modifié avec succès'),
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

  void _deleteUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AuthService.deleteUser(userId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur supprimé avec succès'),
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
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = AuthService.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les utilisateurs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('Aucun utilisateur trouvé'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              title: Text(
                user['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Email : ${user['email']}\nRôle : ${user['role']}',
                style: const TextStyle(height: 1.5),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editUser(context, user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(context, user['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

