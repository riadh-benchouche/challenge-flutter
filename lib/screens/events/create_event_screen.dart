import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/models/category_model.dart';
import 'package:challenge_flutter/services/association_service.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:challenge_flutter/services/category_service.dart';
import 'package:challenge_flutter/services/event_service.dart';
import 'package:flutter/material.dart';
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
  CategoryModel? _selectedCategory;
  Association? _selectedAssociation;
  bool _isLoading = false;
  List<CategoryModel>? _categories;
  List<Association>? _associations;
  final List<String> _locations = ['Nation 01', 'Nation 02', 'Errard'];
  String? _selectedLocation;

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
    setState(() => _isLoading = true);
    try {
      final categories = await CategoryService.fetchCategories();
      final associations = await AssociationService.getAssociationsByUser(
          AuthService.userData!['id']);

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('fr', 'FR'), // Ajouter la locale française
    );

    if (picked != null) {
      // Conserver l'heure actuelle ou utiliser l'heure actuelle si pas de date sélectionnée
      final currentTime = _selectedDate;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentTime),
      );

      if (pickedTime != null) {
        setState(() {
          // Créer une nouvelle date en combinant la date sélectionnée avec l'heure sélectionnée
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
      await EventService.createEvent(
        name: _nameController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        location: _locationController.text,
        categoryId: _selectedCategory!.id,
        associationId: _selectedAssociation!.id,
      );

      // Rafraîchir la liste des événements
      await Future.wait([
        EventService.getAssociationEvents(),
        EventService.getParticipatingEvents(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement créé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/events');
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
    if (!EventService.canCreateEvent) {
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Lieu',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _locations.map((location) {
                              final isSelected = _selectedLocation == location;
                              return InkWell(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                  setState(() {
                                    _selectedLocation = location;
                                    _locationController.text = location;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? theme.primaryColor : Colors.white,
                                    border: Border.all(
                                      color: isSelected ? theme.primaryColor : Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if (_formKey.currentState?.validate() == false &&
                              _selectedLocation == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Le lieu est requis',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      InkWell(
                        onTap: !_isLoading ? () => _selectDate(context) : null,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date et heure',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(DateFormat('dd/MM/yyyy HH:mm')
                              .format(_selectedDate),
                          ),
                        ),
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
