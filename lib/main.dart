import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Association Manager',
        theme: ThemeData(
          primaryColor: const Color(0xFF001B40),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFF00EAFF),
          ),
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              color: Color(0xFF393939),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF837E93),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(
              color: Color(0xFF001B40),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFF837E93),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFF001B40),
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001B40),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Poppins-Bold',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/': (context) => const HomeScreen(),
          '/login': (context) => LoginScreen(controller: PageController()),
          '/signup': (context) => SignupScreen(controller: PageController()),
        },
      ),
    );
  }
}
