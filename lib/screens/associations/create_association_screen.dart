import 'package:challenge_flutter/services/association_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateAssociationScreen extends StatefulWidget {
  const CreateAssociationScreen({super.key});

  @override
  State<CreateAssociationScreen> createState() => _CreateAssociationScreenState();
}

class _CreateAssociationScreenState extends State<CreateAssociationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    if (value.length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'La description est requise';
    }
    if (value.length < 10) {
      return 'La description doit contenir au moins 10 caractères';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (!AssociationService.canCreateAssociation) {
        throw Exception('Vous n\'avez pas les droits pour créer une association');
      }

      await AssociationService.createAssociation(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
      );

      if (mounted) {
        // Les données sont déjà rafraîchies dans le service
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Association créée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCreate = AssociationService.canCreateAssociation;

    if (!canCreate) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Créer une association'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Vous devez être un leader d\'association pour créer une nouvelle association.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une association'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'association',
                  hintText: 'Entrez le nom de l\'association',
                ),
                validator: _validateName,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez votre association',
                ),
                validator: _validateDescription,
                maxLines: 4,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Créer l\'association'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}