import 'dart:io';

import 'package:challenge_flutter/screens/admin/manage_users_screen.dart';
import 'package:challenge_flutter/screens/admin/pending_associations_screen.dart';
import 'package:challenge_flutter/screens/associations/create_association_screen.dart';
import 'package:challenge_flutter/screens/associations/edit_association_screen.dart';
import 'package:challenge_flutter/screens/edit_profile/edit_profile_screen.dart';
import 'package:challenge_flutter/screens/events/create_event_screen.dart';
import 'package:challenge_flutter/screens/events/edit_event_screen.dart';
import 'package:challenge_flutter/screens/layout/admin_layout.dart';
import 'package:challenge_flutter/screens/layout/main_layout.dart';
import 'package:challenge_flutter/screens/messages/message_detail_screen.dart';
import 'package:challenge_flutter/screens/profile/profile_screen.dart';
import 'package:challenge_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/associations/association_detail_screen.dart';
import 'screens/associations/join_association_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_categories_screen.dart';
import 'screens/events/event_participants_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await initializeDateFormatting('fr_FR', null);
  await AuthService.initializeApp();

  if (AuthService.token == null || AuthService.userData?['id'] == null) {
    await AuthService.logout();
  }
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final GoRouter _router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    if (!AuthService.initialized) return null;

    final isLoggedIn = AuthService.isLoggedIn &&
        AuthService.token != null &&
        AuthService.userData?['id'] != null;

    final isAdmin = AuthService.isAdmin;

    final isPublicRoute =
        state.uri.toString() == '/login' || state.uri.toString() == '/register';

    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    if (isAdmin && state.uri.toString() == '/') {
      return '/admin';
    }

    if (isLoggedIn && isPublicRoute) {
      return '/';
    }

    if (state.uri.toString().startsWith('/admin') && !isAdmin) {
      return '/';
    }

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(
        child: MainLayout(initialIndex: 0),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              NoTransitionPage(
            child: LoginScreen(controller: PageController()),
          ),
        ),
        GoRoute(
          path: 'register',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              NoTransitionPage(
            child: SignupScreen(controller: PageController()),
          ),
        ),
        GoRoute(
          path: '/admin',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(
            child: AdminLayout(
              child: AdminDashboardScreen(),
            ),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: 'users',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage(
                child: AdminLayout(
                  child: ManageUsersScreen(),
                ),
              ),
            ),
            GoRoute(
              path: 'pending-associations',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage(
                child: AdminLayout(
                  child: PendingAssociationsScreen(),
                ),
              ),
            ),
            GoRoute(
              path: 'categories',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage(
                child: AdminLayout(
                  child: ManageCategoriesScreen(),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'events',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(
            child: MainLayout(initialIndex: 1),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: 'create-event',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage(
                child: CreateEventScreen(),
              ),
            ),
            GoRoute(
              path: ':eventId',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage(
                child: EventDetailScreen(
                    eventId: state.pathParameters['eventId']!),
              ),
            ),
            GoRoute(
              path: ':eventId/participants',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage(
                child: EventParticipantsScreen(
                  eventId: state.pathParameters['eventId']!,
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/edit-association/:id',
          builder: (context, state) => EditAssociationScreen(
            associationId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/edit-event/:id',
          builder: (context, state) => EditEventScreen(
            eventId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'join-association',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(
            child: JoinAssociationScreen(),
          ),
        ),
        GoRoute(
          path: 'associations',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(
            child: MainLayout(initialIndex: 2),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: 'create-association',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage(
                child: CreateAssociationScreen(),
              ),
            ),
            GoRoute(
              path: ':associationId',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage(
                child: AssociationDetailScreen(
                    associationId: state.pathParameters['associationId']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'messages',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(
            child: MainLayout(initialIndex: 3),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: ':roomId',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage(
                child: MessageDetailScreen(
                  roomId: state.pathParameters['roomId']!,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Association Manager',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      theme: ThemeData(
        useMaterial3: true,
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
    );
  }
}
