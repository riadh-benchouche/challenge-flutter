import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:challenge_flutter/providers/user_provider.dart';
import 'package:challenge_flutter/providers/home_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final PageController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!value.contains('@')) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer les providers nécessaires
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);

      // Connecter l'utilisateur
      await userProvider.login(
        _emailController.text.trim(),
        _passController.text.trim(),
      );

      if (mounted && userProvider.isLoggedIn) {
        // Précharger les données de la home page
        try {
          await homeProvider.refreshAll();
        } catch (e) {
          debugPrint('Erreur lors du chargement des données initiales: $e');
          // On continue quand même la navigation même si le chargement des données échoue
        }

        // Rediriger vers la home page
        if (mounted) {
          context.go('/');
        }
      }
    } catch (error) {
      if (mounted) {
        String errorMessage = error.toString();
        // Nettoyer le message d'erreur si nécessaire
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception:', '').trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 15),
              child: Image.asset(
                "assets/images/vector-3.png",
                width: 413,
                height: 457,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connexion',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        labelStyle: theme.inputDecorationTheme.labelStyle,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _passController,
                      validator: _validatePassword,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        labelStyle: theme.inputDecorationTheme.labelStyle,
                      ),
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text('Connexion'),
                            ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Vous n\'avez pas de compte? ',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed:
                              _isLoading ? null : () => context.go('/register'),
                          child: Text(
                            'Créer un compte',
                            style: TextStyle(
                              color: _isLoading
                                  ? theme.disabledColor
                                  : theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}