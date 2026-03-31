import 'dart:ui';
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_theme.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/pages/auth/forgotpassword/forgotpassword_layout.dart';
import 'package:jobgo/presentation/pages/auth/login/login_page.dart';
import 'package:jobgo/presentation/pages/auth/register/register_role_page.dart';
import 'package:jobgo/presentation/pages/main/app_shell.dart';
import 'package:jobgo/presentation/pages/welcome/welcome_page.dart';

import 'package:provider/provider.dart';
import 'package:jobgo/presentation/providers/bookmark_provider.dart';

import 'package:jobgo/presentation/providers/employer_provider.dart';

// Flag để biết đang ở flow register
bool isInRegisterFlow = false;
bool isInForgotPasswordFlow = false;

/// Helper: parse role string from database to UserRole enum
UserRole parseUserRole(String? roleStr) {
  if (roleStr == null) return UserRole.candidate;
  final role = roleStr.trim().toLowerCase();
  if (role == 'employer') return UserRole.employer;
  if (role == 'admin') return UserRole.admin;
  return UserRole.candidate;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    try {
      Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (e) {
      print('Error processing auth link: $e');
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookmarkProvider()..loadInitialBookmarks(),
        ),
        ChangeNotifierProvider(create: (_) => EmployerProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen(
          (data) {
            final event = data.event;

            if (event == AuthChangeEvent.signedIn) {
              if (isInRegisterFlow) return;
              if (isInForgotPasswordFlow) return;

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final context = navigatorKey.currentContext;
                if (context == null) return;

                // ── Tự động nhận diện Role khi Login ──
                try {
                  final userId = data.session?.user.id;
                  if (userId == null) return;

                  final userData = await Supabase.instance.client
                      .from('users')
                      .select('u_role')
                      .eq('auth_uid', userId)
                      .maybeSingle();

                  if (userData != null) {
                    final role = parseUserRole(userData['u_role'] as String?);

                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      '/main',
                      (route) => false,
                      arguments: role,
                    );
                  }
                } catch (e) {
                  print('Error navigating after sign-in: $e');
                  Supabase.instance.client.auth.signOut();
                }
              });
            } else if (event == AuthChangeEvent.signedOut) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final context = navigatorKey.currentContext;
                if (context == null) return;

                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              });
            }
          },
          onError: (error) {
            print('Auth state error: $error');
          },
        );
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'JobGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Giữ scrollBehavior từ file gốc
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final role = settings.arguments as UserRole? ?? UserRole.candidate;
          return MaterialPageRoute(builder: (_) => AppShell(role: role));
        }
        return null;
      },
      routes: {
        '/login': (context) => const LoginPage(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/register': (context) => const RegisterRolePage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<Map<String, dynamic>?>? _roleFuture;
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      _roleFuture = null;
      _lastUserId = null;
      return const WelcomePage();
    }

    // Refresh future only if user changed (or first time)
    if (_roleFuture == null || _lastUserId != session.user.id) {
      _lastUserId = session.user.id;
      _roleFuture = Supabase.instance.client
          .from('users')
          .select('u_role')
          .eq('auth_uid', session.user.id)
          .maybeSingle();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _roleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          // If error or user not found in table, logout and go to welcome
          Supabase.instance.client.auth.signOut();
          return const WelcomePage();
        }

        final roleStr = snapshot.data!['u_role'] as String?;
        final role = parseUserRole(roleStr);
        return AppShell(role: role);
      },
    );
  }
}
