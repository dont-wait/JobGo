import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_theme.dart';
import 'package:jobgo/presentation/pages/main/main_shell.dart';
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
      home: const WelcomePage(),
      routes: {
        '/home': (context) => const MainShell(),
      },
    );
  }
}
