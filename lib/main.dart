import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_theme.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/pages/auth/forgotpassword/forgotpassword_layout.dart';
import 'package:jobgo/presentation/pages/auth/login/login_page.dart';
import 'package:jobgo/presentation/pages/auth/register/register_role_page.dart';
import 'package:jobgo/presentation/pages/main/app_shell.dart';
import 'package:jobgo/presentation/pages/welcome/welcome_page.dart';




void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      home: const WelcomePage(),
      // Route '/main' nhận UserRole qua arguments
      // Login/Register sẽ navigate: Navigator.pushReplacementNamed(context, '/main', arguments: UserRole.candidate)
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
