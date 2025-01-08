import 'package:flutter/material.dart';

class TopAssociationCard extends StatelessWidget {
  final String name;
  final String imageSrc;
  final int userCount;

  const TopAssociationCard({
    super.key,
    required this.name,
    required this.imageSrc,
    required this.userCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180, // Largeur fixe
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageSrc == ''
                      ? Image.asset(
                    'assets/images/association-1.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    'https://invooce.online/$imageSrc',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/association-1.jpg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$userCount membres',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
