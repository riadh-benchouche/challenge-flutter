import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/models/category_model.dart';
import 'package:challenge_flutter/providers/association_provider.dart';
import 'package:challenge_flutter/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  CategoryModel? _selectedCategory;
  Association? _selectedAssociation;
  bool _isLoading = false;
  List<CategoryModel>? _categories;
  List<Association>? _associations;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final associationProvider =
        Provider.of<AssociationProvider>(context, listen: false);

    setState(() => _isLoading = true);
    try {
      final categories = await eventProvider.fetchCategories();
      final associations = await associationProvider.fetchAssociationByOwner();

      setState(() {
        _categories = categories;
        _associations = associations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedAssociation == null) {
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
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      await eventProvider.createEvent(
        _nameController.text,
        _descriptionController.text,
        _selectedDate,
        _locationController.text,
        _selectedCategory!.id,
        _selectedAssociation!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement créé avec succès!'),
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
    final eventProvider = Provider.of<EventProvider>(context);

    if (!eventProvider.canCreateEvent) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Créer un événement'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Vous devez être un leader d\'association pour créer un événement.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Créer un événement'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _isLoading && (_categories == null || _associations == null)
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le nom est requis';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Décrivez votre événement',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La description est requise';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lieu',
                          hintText: 'Lieu de l\'événement',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le lieu est requis';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Date et heure'),
                        subtitle: Text(
                          '${DateFormat('dd/MM/yyyy').format(_selectedDate)} à ${_selectedTime.format(context)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: !_isLoading
                            ? () async {
                                await _selectDate();
                                if (mounted) await _selectTime();
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CategoryModel>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          hintText: 'Sélectionnez une catégorie',
                        ),
                        items: _categories?.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (CategoryModel? value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Association>(
                        value: _selectedAssociation,
                        decoration: const InputDecoration(
                          labelText: 'Association',
                          hintText: 'Sélectionnez une association',
                        ),
                        items: _associations?.map((association) {
                          return DropdownMenuItem(
                            value: association,
                            child: Text(association.name),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (Association? value) {
                                setState(() {
                                  _selectedAssociation = value;
                                });
                              },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Créer l\'événement'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
