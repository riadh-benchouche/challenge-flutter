import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/user_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/events/events_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/associations/associations_screen.dart';
import 'screens/associations/association_detail_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/messages/message_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/associations/join_association_screen.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          builder: (BuildContext context, GoRouterState state) =>
              LoginScreen(controller: PageController()),
        ),
        GoRoute(
          path: 'register',
          builder: (BuildContext context, GoRouterState state) =>
              SignupScreen(controller: PageController()),
        ),
        GoRoute(
          path: 'events',
          builder: (BuildContext context, GoRouterState state) =>
              const EventScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: ':eventId',
              builder: (BuildContext context, GoRouterState state) =>
                  EventDetailScreen(eventId: state.pathParameters['eventId']!),
            ),
          ],
        ),
        GoRoute(
          path: 'associations',
          builder: (BuildContext context, GoRouterState state) =>
              const AssociationsScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: ':associationId',
              builder: (BuildContext context, GoRouterState state) =>
                  AssociationDetailScreen(
                      associationId: state.pathParameters['associationId']!),
            ),
          ],
        ),
        GoRoute(
          path: 'messages',
          builder: (BuildContext context, GoRouterState state) =>
              MessagesScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: ':roomId',
              builder: (BuildContext context, GoRouterState state) =>
                  MessageDetailScreen(roomId: state.pathParameters['roomId']!),
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) =>
              const ProfileScreen(),
        ),
        GoRoute(
          path: 'join-association',
          builder: (BuildContext context, GoRouterState state) =>
              const JoinAssociationScreen(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp.router(
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
        routerConfig: _router,
      ),
    );
  }
}
