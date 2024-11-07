import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.controller});

  final PageController controller;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Image.asset(
              "assets/images/vector-2.png",
              width: 428,
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
                  'Inscription',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 56,
                  child: TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF393939),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle:
                          theme.inputDecorationTheme.labelStyle?.copyWith(
                        color: theme.primaryColor,
                      ),
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder:
                          theme.inputDecorationTheme.focusedBorder?.copyWith(
                        borderSide:
                            BorderSide(color: theme.colorScheme.secondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  height: 56,
                  child: TextField(
                    controller: _passController,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF393939),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle:
                          theme.inputDecorationTheme.labelStyle?.copyWith(
                        color: theme.primaryColor,
                      ),
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder:
                          theme.inputDecorationTheme.focusedBorder?.copyWith(
                        borderSide:
                            BorderSide(color: theme.colorScheme.secondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  height: 56,
                  child: TextField(
                    controller: _repassController,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF393939),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Confirmation Mot de passe',
                      labelStyle:
                          theme.inputDecorationTheme.labelStyle?.copyWith(
                        color: theme.primaryColor,
                      ),
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder:
                          theme.inputDecorationTheme.focusedBorder?.copyWith(
                        borderSide:
                            BorderSide(color: theme.colorScheme.secondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    width: 329,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      style: theme.elevatedButtonTheme.style,
                      child: const Text('Créer un compte',
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
                      'Vous avez déjà un compte?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF837E93),
                      ),
                    ),
                    const SizedBox(width: 2.5),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Connectez-vous',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
