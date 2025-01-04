import 'package:challenge_flutter/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final response = await userProvider.authenticatedRequest('/me');

      if (response.statusCode == 200) {
        setState(() {
          _profileData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (mounted) {
        // La redirection vers /login se fera automatiquement grâce au redirect
        // du GoRouter quand isLoggedIn deviendra false
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: theme.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileData?['image_url']?.isNotEmpty == true
                  ? NetworkImage(_profileData!['image_url'])
                  : null,
              backgroundColor: Colors.grey[300],
              child: _profileData?['image_url']?.isEmpty != false
                  ? Text(
                _profileData?['name']?[0].toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _profileData?['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _profileData?['email'] ?? 'No email',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 30),
            _buildProfileOption(
              Icons.badge,
              'Role',
              _profileData?['role']?.toString().toUpperCase() ?? 'Unknown',
              theme,
            ),
            _buildProfileOption(
              Icons.calendar_today,
              'Member Since',
              _formatDate(_profileData?['created_at']),
              theme,
            ),
            _buildProfileOption(
              Icons.verified_user,
              'Account Status',
              _profileData?['is_active'] == true ? 'Active' : 'Inactive',
              theme,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Handle edit profile
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _handleLogout,
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      IconData icon,
      String label,
      String value,
      ThemeData theme,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}