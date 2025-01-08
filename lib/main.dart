import 'package:challenge_flutter/providers/event_provider.dart';
import 'package:challenge_flutter/providers/home_provider.dart';
import 'package:challenge_flutter/providers/message_provider.dart';
import 'package:challenge_flutter/providers/category_provider.dart';
import 'package:challenge_flutter/screens/associations/create_association_screen.dart';
import 'package:challenge_flutter/screens/associations/edit_association_screen.dart';
import 'package:challenge_flutter/screens/events/create_event_screen.dart';
import 'package:challenge_flutter/screens/events/edit_event_screen.dart';
import 'package:challenge_flutter/screens/layout/admin_layout.dart';
import 'package:challenge_flutter/screens/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/association_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/associations/association_detail_screen.dart';
import 'screens/messages/message_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/edit_profile/edit_profile_screen.dart';
import 'screens/associations/join_association_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/pending_associations_screen.dart';
import 'screens/admin/manage_categories_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  final userProvider = UserProvider();
  await userProvider.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),

        // Ajout du CategoryProvider
        ChangeNotifierProxyProvider<UserProvider, CategoryProvider>(
          create: (context) => CategoryProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, previous) => updateProvider(context,
              userProvider, (u) => CategoryProvider(userProvider: u), previous),
        ),

        ChangeNotifierProxyProvider<UserProvider, AssociationProvider>(
            create: (context) => AssociationProvider(
                  userProvider:
                      Provider.of<UserProvider>(context, listen: false),
                ),
            update: (context, userProvider, previous) {
              final provider =
                  previous ?? AssociationProvider(userProvider: userProvider);
              if (previous == null) provider.initApiService();
              return provider;
            }),

        ChangeNotifierProxyProvider<UserProvider, EventProvider>(
          create: (context) => EventProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, previous) {
            final provider =
                previous ?? EventProvider(userProvider: userProvider);
            if (previous == null) provider.initEventService();
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<UserProvider, HomeProvider>(
          create: (context) => HomeProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, previous) {
            final provider =
                previous ?? HomeProvider(userProvider: userProvider);
            if (previous == null) {
              provider.initHomeService();
            }
            return provider;
          },
        ),

        ChangeNotifierProxyProvider<UserProvider, MessageProvider>(
          create: (context) => MessageProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, previous) {
            final provider =
                previous ?? MessageProvider(userProvider: userProvider);
            if (previous == null) {
              provider.initWebSocket();
            }
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

T updateProvider<T extends ChangeNotifier>(
  BuildContext context,
  UserProvider userProvider,
  T Function(UserProvider) createProvider,
  T? previous,
) {
  return userProvider.token != null && userProvider.userData != null
      ? createProvider(userProvider)
      : previous ?? createProvider(userProvider);
}

final GoRouter _router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    // Accès au UserProvider pour vérifier si l'utilisateur est connecté
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.initialized) return null;

    final isLoggedIn = userProvider.isLoggedIn;
    final isAdmin = userProvider.isAdmin;

    final isPublicRoute =
        state.uri.toString() == '/login' || state.uri.toString() == '/register';

    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    if (isAdmin && state.uri.toString() == '/') {
      return '/admin';
    }

    if (isAdmin && state.uri.toString().startsWith('/admin')) {
      return null;
    }

    if (isLoggedIn && isPublicRoute) {
      return '/';
    }

    if (state.uri.toString().startsWith('/admin') && !isAdmin) {
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
