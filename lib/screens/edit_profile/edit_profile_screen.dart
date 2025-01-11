import 'dart:io';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _name;
  File? _image;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        setState(() => _image = imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection : $e')),
      );
    }
  }

  Future<bool> _uploadImage(String userId, String token) async {
    try {
      final url =
          Uri.parse('${AuthService.baseUrl}/users/$userId/upload-image');
      final request = http.MultipartRequest('POST', url);

      if (kIsWeb) {
        final bytes = await _image!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'profile_image.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }

      request.headers['Authorization'] = 'Bearer $token';
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final updatedUserData = {
          ...(AuthService.userData ?? {}),
          ...(responseData as Map<String, dynamic>)
        };
        // Mise à jour avec les nouveaux paramètres
        await AuthService.updateUserData(updatedUserData);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'upload: $e');
      return false;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final currentUserId = AuthService.userData?['id'];
    final token = AuthService.token;

    if (currentUserId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : utilisateur non authentifié.')),
      );
      return;
    }

    try {
      // Mettre à jour le profil avec la nouvelle méthode updateUser
      await AuthService.updateUser(
        currentUserId,
        _name!,
        AuthService.userData?['email'] ?? '',
        AuthService.userData?['role'] ?? 'user',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès !')),
      );

      // Si une image est sélectionnée, l'uploader
      if (_image != null) {
        final bool success = await _uploadImage(currentUserId, token);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image mise à jour avec succès !')),
          );
        }
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.userData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Modifier le profil',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_image != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: FileImage(_image!),
                )
              else if (currentUser?['image_url'] != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    '${AuthService.baseUrl}/${currentUser!['image_url']}',
                  ),
                )
              else
                const CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.person, size: 60),
                ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Changer l\'image'),
              ),
              TextFormField(
                initialValue: currentUser?['name'] ?? '',
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
                onSaved: (value) => _name = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: currentUser?['email'] ?? '',
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _updateProfile,
                  child: const Text('Enregistrer les modifications'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
