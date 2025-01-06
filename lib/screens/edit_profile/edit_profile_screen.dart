import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _name;
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    // Récupérer les données utilisateur depuis UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.userData?['id'] ?? '';
    final token = userProvider.token;

    if (currentUserId.isEmpty || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : utilisateur non authentifié.')),
      );
      return;
    }

    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000', // URL de base
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ));

    try {
      // Envoyer la requête PUT pour mettre à jour le profil
      final response = await dio.put(
        '/users/$currentUserId',
        data: {
          'name': _name,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil mis à jour avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la mise à jour du profil.')),
        );
      }

      // Si une image est sélectionnée, envoyer une requête multipart pour l'image
      if (_image != null) {
        final uploadResponse = await _uploadImage(currentUserId, token);
        if (uploadResponse) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image mise à jour avec succès !')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de la mise à jour de l\'image.')),
          );
        }
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur : ${e.response?.data['message'] ?? e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue : $e')),
      );
    }
  }

  Future<bool> _uploadImage(String userId, String token) async {
    try {
      final url = Uri.parse('http://localhost:3000/users/$userId/upload-image');
      final request = http.MultipartRequest('POST', url);

      if (kIsWeb) {
        // Pour Flutter Web
        final bytes = await _image!.readAsBytes(); // Lire les octets du fichier
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _image!.path.split('/').last,
        ));
      } else {
        // Pour Mobile (Android/iOS)
        request.files.add(http.MultipartFile(
          'image',
          _image!.openRead(),
          await _image!.length(),
          filename: _image!.path.split('/').last,
        ));
      }

      // Ajouter les en-têtes d'autorisation
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Vérifier la réponse
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Erreur: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'upload: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.userData;
    const String baseUrl = 'http://localhost:3000/';

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_image != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: FileImage(_image!),
                )
              else if (currentUser?['image_url'] != null)
                CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        NetworkImage('$baseUrl${currentUser!['image_url']}'))
              else
                CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.person, size: 60),
                ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Change Image'),
              ),
              TextFormField(
                initialValue: currentUser?['name'] ?? '',
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name.';
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
