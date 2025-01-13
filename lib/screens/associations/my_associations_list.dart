import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/association_service.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'associations_list_content.dart';

class MyAssociationsList extends StatelessWidget {
  final String searchQuery;

  const MyAssociationsList({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.userData?['id'];
    if (userId == null) {
      context.go('/login');
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Association>>(
      key: const ValueKey('my_associations'),
      future: AssociationService.getAssociationsByUser(userId),
      builder: (context, snapshot) {
        return AssociationsListContent(
          snapshot: snapshot,
          searchQuery: searchQuery,
          emptyMessage: 'Vous n\'êtes membre d\'aucune association',
          isMyList: true,
        );
      },
    );
  }
}