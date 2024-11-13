import 'package:flutter/material.dart';

class AssociationDetailScreen extends StatelessWidget {
  final String associationId;
  const AssociationDetailScreen({super.key, required this.associationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Association Details')),
      body: Center(
        child: Text('Details for Association ID: $associationId'),
      ),
    );
  }
}
