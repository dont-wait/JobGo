import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_theme.dart';
import 'package:jobgo/presentation/pages/auth/forgotpassword/forgotpassword_layout.dart';
import 'package:jobgo/presentation/pages/auth/login/login_page.dart';
import 'package:jobgo/presentation/pages/auth/register/register_role_page.dart';
import 'package:jobgo/presentation/pages/candidate/main/main_shell.dart';
import 'package:jobgo/presentation/pages/welcome/welcome_page.dart';
import 'package:jobgo/presentation/pages/employer/dashboard/dashboard_page.dart';


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
          PointerDeviceKind.mouse, // Enable scrolling with mouse as well btw: i test in web :((
        },
      ),
      home: const WelcomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/register': (context) => const RegisterRolePage(),
        '/home': (context) => const MainShell(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
