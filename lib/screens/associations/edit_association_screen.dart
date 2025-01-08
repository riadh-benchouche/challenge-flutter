import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:challenge_flutter/providers/association_provider.dart';

class EditAssociationScreen extends StatefulWidget {
  final String associationId;

  const EditAssociationScreen({super.key, required this.associationId});

  @override
  State<EditAssociationScreen> createState() => _EditAssociationScreenState();
}

class _EditAssociationScreenState extends State<EditAssociationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _image;
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadAssociationData();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85
      );

      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection : $e')),
      );
    }
  }

  Future<void> _loadAssociationData() async {
    final provider = Provider.of<AssociationProvider>(context, listen: false);
    final association = await provider.fetchAssociationById(widget.associationId);

    _nameController.text = association.name;
    _descriptionController.text = association.description;
  }

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
      final provider = Provider.of<AssociationProvider>(context, listen: false);

      // Mise à jour des infos de base
      await provider.updateAssociation(
        widget.associationId,
        _nameController.text.trim(),
        _descriptionController.text.trim(),
      );

      // Si une nouvelle image a été sélectionnée
      if (_image != null) {
        await provider.uploadAssociationImage(widget.associationId, _image!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Association mise à jour avec succès !'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'association'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        if (_image != null)
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(_image!),
                          )
                        else
                          Consumer<AssociationProvider>(
                            builder: (context, provider, _) {
                              final association = provider.currentAssociation;
                              return CircleAvatar(
                                radius: 60,
                                backgroundImage: association?.imageUrl != null
                                    ? NetworkImage('${provider.userProvider.baseUrl}/${association!.imageUrl}')
                                    : null,
                                child: association?.imageUrl == null
                                    ? const Icon(Icons.group, size: 60)
                                    : null,
                              );
                            },
                          ),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Changer l\'image'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      child: const Text('Mettre à jour l\'association'),
                    ),
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