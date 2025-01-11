import 'package:challenge_flutter/models/category_model.dart';
import 'package:challenge_flutter/services/category_service.dart';
import 'package:flutter/material.dart';

import 'category_form_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  bool _isLoading = false;
  List<CategoryModel> _categories = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await CategoryService.fetchCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    if (!mounted) return;

    try {
      await CategoryService.deleteCategory(category.id);
      await _fetchCategories();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catégorie supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $_error'),
            ElevatedButton(
              onPressed: _fetchCategories,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les catégories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCategories,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const CategoryFormScreen(),
                    ),
                  )
                  .then((_) => _fetchCategories());
            },
          ),
        ],
      ),
      body: _categories.isEmpty
          ? const Center(child: Text('Aucune catégorie trouvée'))
          : RefreshIndicator(
              onRefresh: _fetchCategories,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(category.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => CategoryFormScreen(
                                        category: category,
                                      ),
                                    ),
                                  )
                                  .then((_) => _fetchCategories());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmation'),
                                  content: const Text(
                                      'Voulez-vous vraiment supprimer cette catégorie ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _deleteCategory(category);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                            },
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
