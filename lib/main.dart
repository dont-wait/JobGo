
import 'dart:ui';
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_theme.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/pages/auth/forgotpassword/forgotpassword_layout.dart';
import 'package:jobgo/presentation/pages/auth/login/login_page.dart';
import 'package:jobgo/presentation/pages/auth/register/register_role_page.dart';
import 'package:jobgo/presentation/pages/main/app_shell.dart';
import 'package:jobgo/presentation/pages/welcome/welcome_page.dart';

// ✅ Flag để biết đang ở flow register
bool isInRegisterFlow = false;

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

  runApp(const MainApp());
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
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        // Không navigate nếu đang ở flow register/verify
        if (isInRegisterFlow) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;
          if (context == null) return;

          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/main',
            (route) => false,
            arguments: UserRole.candidate,
          );
        });
      }
    }, onError: (error) {
      print('Auth state error: $error');
    });
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
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      home: const WelcomePage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final role = settings.arguments as UserRole? ?? UserRole.candidate;
          return MaterialPageRoute(
            builder: (_) => AppShell(role: role),
          );
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