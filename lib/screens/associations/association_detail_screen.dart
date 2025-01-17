import 'package:challenge_flutter/models/association.dart';
import 'package:challenge_flutter/services/association_service.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AssociationDetailScreen extends StatefulWidget {
  final String associationId;

  const AssociationDetailScreen({super.key, required this.associationId});

  @override
  _AssociationDetailScreenState createState() =>
      _AssociationDetailScreenState();
}

class _AssociationDetailScreenState extends State<AssociationDetailScreen> {
  Association? _association;
  bool _isLoading = true;
  bool _isMember = false;
  bool _isJoining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssociation();
  }

  Future<void> _loadAssociation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        AssociationService.getAssociationById(widget.associationId),
        AssociationService.checkAssociationMembership(widget.associationId),
      ]);

      if (mounted) {
        setState(() {
          _association = results[0] as Association;
          _isMember = results[1] as bool;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _joinAssociation() async {
    if (!mounted) return;

    setState(() => _isJoining = true);

    try {
      await AssociationService.joinAssociation(_association!.code);
      final isMember = await AssociationService.checkAssociationMembership(
          widget.associationId);

      if (!mounted) return;
      setState(() => _isMember = isMember);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vous avez rejoint l\'association avec succès !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _leaveAssociation() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter l\'association'),
        content:
            const Text('Êtes-vous sûr de vouloir quitter cette association ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isJoining = true);

    try {
      await AssociationService.leaveAssociation(widget.associationId);

      if (!mounted) return;
      setState(() => _isMember = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vous avez quitté l\'association'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: const Text('Erreur', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAssociation,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_association == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title:
              const Text('Non trouvé', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('Association non trouvée'),
        ),
      );
    }

    final association = _association!;
    final isOwner = association.ownerId == AuthService.userData?['id'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text('Détails de l\'association',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () =>
                  context.go('/edit-association/${association.id}'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(0)),
              child: Image.network(
                'https://invooce.online/${association.imageUrl}',
                height: 380,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/association-1.jpg',
                    height: 380,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        association.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      Icon(
                        association.isActive
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: association.isActive ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    association.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  _buildCodeSection(theme),
                  const SizedBox(height: 10),
                  _buildDateSection(theme),
                  const SizedBox(height: 30),
                  Center(child: _buildJoinButton(theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () => _copyToClipboard(_association!.code),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(Icons.vpn_key, color: theme.primaryColor, size: 28),
          title: Text(
            'Code d\'accès',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          subtitle: Text(
            _association!.code,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            color: theme.primaryColor,
            onPressed: () => _copyToClipboard(_association!.code),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copié dans le presse-papiers'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDateSection(ThemeData theme) {
    final dateCreation = DateFormat('dd MMMM yyyy', 'fr_FR')
        .format(_association!.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: theme.primaryColor),
          const SizedBox(width: 12),
          Text(
            'Créée le $dateCreation',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton(ThemeData theme) {
    if (_isJoining) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final isOwner = _association?.ownerId == AuthService.userData?['id'];

    if (isOwner) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.star, color: Colors.white),
        label: const Text(
          'Propriétaire',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: null,
      );
    }

    if (_isMember) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.exit_to_app, color: Colors.white),
        label: const Text(
          'Quitter',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _leaveAssociation,
      );
    }

    return ElevatedButton.icon(
      icon: const Icon(Icons.group_add, color: Colors.white),
      label: const Text(
        'Rejoindre',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: _joinAssociation,
    );
  }
}
