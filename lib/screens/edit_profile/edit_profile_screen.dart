import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
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
          imageQuality: 85
      );

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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.userData?['id'];
    final token = userProvider.token;

    if (currentUserId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : utilisateur non authentifié.')),
      );
      return;
    }

    try {
      // Mettre à jour le profil
      final response = await http.put(
        Uri.parse('${userProvider.baseUrl}/users/$currentUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _name,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final updatedUserData = {
          ...(userProvider.userData ?? {}),
          ...(responseData as Map<String, dynamic>)
        };
        userProvider.updateUserData(updatedUserData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès !')),
        );

        // Si une image est sélectionnée, l'uploader
        if (_image != null) {
          final bool success = await _uploadImage(currentUserId, token);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image mise à jour avec succès !')),
            );
          }
        }

        if (mounted) Navigator.of(context).pop();
      } else {
        throw Exception('Échec de la mise à jour du profil');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  Future<bool> _uploadImage(String userId, String token) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final url =
          Uri.parse('${userProvider.baseUrl}/users/$userId/upload-image');
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
          ...(userProvider.userData ?? {}),
          ...(responseData as Map<String, dynamic>)
        };
        userProvider.updateUserData(updatedUserData);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'upload: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.userData;

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
                    '${userProvider.baseUrl}/${currentUser!['image_url']}',
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
