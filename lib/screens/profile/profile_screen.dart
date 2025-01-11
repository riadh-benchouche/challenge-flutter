import 'package:cached_network_image/cached_network_image.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    AuthService.refreshUserData();
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) context.go('/');
  }

  Widget _buildProfileImage(String? imageUrl, String? name) {
    final String baseUrl = AuthService.baseUrl;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: '$baseUrl/$imageUrl',
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => _buildInitials(name),
              )
            : _buildInitials(name),
      ),
    );
  }

  Widget _buildInitials(String? name) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Text(
          name?.isNotEmpty == true ? name![0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = AuthService.userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: AuthService.refreshUserData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
                child: _buildProfileImage(
                    userData?['image_url'], userData?['name'])),
            const SizedBox(height: 20),
            Center(
              child: Text(
                userData?['name'] ?? 'Utilisateur',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                userData?['email'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 2,
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.person,
                    title: 'Role',
                    value: (userData?['role'] ?? '').toString().toUpperCase(),
                    iconColor: Colors.green,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.calendar_today,
                    title: 'Membre depuis',
                    value: _formatDate(userData?['created_at']),
                    iconColor: Colors.orange,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.verified_user,
                    title: 'Statut',
                    value: userData?['is_active'] == true ? 'Actif' : 'Inactif',
                    iconColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () => context.go('/edit-profile'),
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'Date inconnue';
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return 'Date invalide';
    }
  }
}
