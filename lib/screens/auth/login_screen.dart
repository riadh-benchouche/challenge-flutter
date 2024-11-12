import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final PageController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
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
                TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF393939),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _passController,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF393939),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                  ),
                ),
                const SizedBox(height: 25),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    width: 329,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/'),
                      style: theme.elevatedButtonTheme.style,
                      child: const Text('Connexion',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Text(
                      'Vous n\'avez pas de compte?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF837E93),
                      ),
                    ),
                    const SizedBox(width: 2.5),
                    InkWell(
                      onTap: () => context.go('/signup'),
                      child: Text(
                        'Crée en un',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  'Mot de passe oublié?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
