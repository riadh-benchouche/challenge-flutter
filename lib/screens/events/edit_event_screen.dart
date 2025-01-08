import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/providers/association_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:challenge_flutter/providers/event_provider.dart';
import 'package:challenge_flutter/models/category_model.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategoryId;
  String? _selectedAssociationId;
  bool _isLoading = false;
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadEventData();
  }

  Future<void> _loadEventData() async {
    final provider = Provider.of<EventProvider>(context, listen: false);
    final event = await provider.fetchEventById(widget.eventId);
    await provider.fetchCategories(); // Charger les catégories

    _nameController.text = event.name;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _selectedDate = event.date;
    _selectedCategoryId = event.categoryId;
    _selectedAssociationId = event.associationId;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le lieu est requis';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedAssociationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une association'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<EventProvider>(context, listen: false);

      await provider.updateEvent(
          widget.eventId,
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          _selectedDate!,
          _locationController.text.trim(),
          _selectedCategoryId!,
          _selectedAssociationId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement mis à jour avec succès !'),
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
        title: const Text('Modifier l\'événement'),
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'événement',
                      hintText: 'Entrez le nom de l\'événement',
                    ),
                    validator: _validateName,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Décrivez votre événement',
                    ),
                    validator: _validateDescription,
                    maxLines: 4,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Lieu',
                      hintText: 'Lieu de l\'événement',
                    ),
                    validator: _validateLocation,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: !_isLoading ? () => _selectDate(context) : null,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date et heure',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(_selectedDate!)
                            : 'Sélectionnez une date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<EventProvider>(
                    builder: (context, provider, _) {
                      final categories = provider.categories ?? [];
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategoryId,
                        items: categories.map((CategoryModel category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: !_isLoading
                            ? (String? value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              }
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<AssociationProvider>(
                    builder: (context, provider, _) {
                      final associations = provider.associations ?? [];
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Association',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedAssociationId,
                        items: associations.map((Association association) {
                          return DropdownMenuItem<String>(
                            value: association.id,
                            child: Text(association.name),
                          );
                        }).toList(),
                        onChanged: !_isLoading
                            ? (String? value) {
                                setState(() {
                                  _selectedAssociationId = value;
                                });
                              }
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 50,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleSubmit,
                            child: const Text('Mettre à jour l\'événement'),
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
