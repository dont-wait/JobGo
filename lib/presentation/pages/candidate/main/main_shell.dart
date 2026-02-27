import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/pages/candidate/home/home_page.dart';
import 'package:jobgo/presentation/pages/candidate/search/search_page.dart';
import 'package:jobgo/presentation/pages/applications/applications_page.dart';
import 'package:jobgo/presentation/pages/candidate/messages/messages_page.dart';
import 'package:jobgo/presentation/pages/candidate/profile/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Giữ state của từng tab bằng IndexedStack
  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    ApplicationsPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_filled, 0),
                _buildNavItem(Icons.search, 1),
                _buildNavItem(Icons.description_outlined, 2),
                _buildNavItem(Icons.chat_bubble_outline, 3),
                _buildNavItem(Icons.person_outline, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
