import 'package:flutter/material.dart';
import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/association_service.dart';

import 'associations_list_content.dart';

class AllAssociationsList extends StatelessWidget {
  final String searchQuery;

  const AllAssociationsList({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Association>>(
      key: const ValueKey('all_associations'),
      future: AssociationService.getAssociations(),
      builder: (context, snapshot) {
        return AssociationsListContent(
          snapshot: snapshot,
          searchQuery: searchQuery,
          emptyMessage: 'Aucune association disponible',
          isMyList: false,
        );
      },
    );
  }
}
