// lib/screens/associations/associations_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/association.dart';
import '../../services/association_service.dart';

class AssociationsListScreen extends StatefulWidget {
  const AssociationsListScreen({Key? key}) : super(key: key);

  @override
  State<AssociationsListScreen> createState() => _AssociationsListScreenState();
}

class _AssociationsListScreenState extends State<AssociationsListScreen> {
  final AssociationService _service = AssociationService();
  List<Association> associations = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssociations();
  }

  Future<void> _loadAssociations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _service.getAssociations();
      final List<dynamic> rows = result['rows'] ?? [];

      setState(() {
        associations = rows.map((json) => Association.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Associations'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text('Erreur: $errorMessage'))
          : associations.isEmpty
          ? const Center(child: Text('Aucune association'))
          : ListView.builder(
        itemCount: associations.length,
        itemBuilder: (context, index) {
          final association = associations[index];
          return ListTile(
            title: Text(association.name),
            subtitle: Text(association.description),
            trailing: Icon(
              association.isActive
                  ? Icons.check_circle
                  : Icons.pending,
              color: association.isActive
                  ? Colors.green
                  : Colors.orange,
            ),
          );
        },
      ),
    );
  }
}