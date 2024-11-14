import 'package:challenge_flutter/screens/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/associations/association_detail_screen.dart';
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
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const MaterialPage(
        child: MainLayout(initialIndex: 0),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              MaterialPage(
            child: LoginScreen(controller: PageController()),
          ),
        ),
        GoRoute(
          path: 'register',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              MaterialPage(
            child: SignupScreen(controller: PageController()),
          ),
        ),
        GoRoute(
          path: 'events',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const MaterialPage(
            child: MainLayout(initialIndex: 1),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: ':eventId',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                child: EventDetailScreen(
                    eventId: state.pathParameters['eventId']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'associations',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const MaterialPage(
            child: MainLayout(initialIndex: 2),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: ':associationId',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                child: AssociationDetailScreen(
                    associationId: state.pathParameters['associationId']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'messages',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const MaterialPage(
            child: MainLayout(initialIndex: 3),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: ':roomId',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                child: MessageDetailScreen(
                    roomId: state.pathParameters['roomId']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const MaterialPage(
            child: ProfileScreen(),
          ),
        ),
        GoRoute(
          path: 'join-association',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const MaterialPage(
            child: JoinAssociationScreen(),
          ),
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
