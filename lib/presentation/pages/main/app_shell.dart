import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';

// ── Candidate pages ──
import 'package:jobgo/presentation/pages/candidate/home/home_page.dart';
import 'package:jobgo/presentation/pages/candidate/search/search_page.dart';
import 'package:jobgo/presentation/pages/candidate/applications/applications_page.dart';
import 'package:jobgo/presentation/pages/candidate/messages/messages_page.dart';
import 'package:jobgo/presentation/pages/candidate/profile/profile_page.dart';

// ── Employer pages ──
import 'package:jobgo/presentation/pages/employer/dashboard/dashboard_page.dart';
import 'package:jobgo/presentation/pages/employer/manage_jobs/manage_jobs_page.dart';
import 'package:jobgo/presentation/pages/employer/talent/talent_page.dart';
import 'package:jobgo/presentation/pages/employer/notification/employer_notification_page.dart';
import 'package:jobgo/presentation/pages/employer/profile/employer_profile_page.dart';

/// Shell chính của ứng dụng — hiển thị bottom nav + pages theo role.
class AppShell extends StatefulWidget {
  final UserRole role;

  const AppShell({super.key, required this.role});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  /// Trả về danh sách pages tương ứng với role
  List<Widget> get _pages {
    switch (widget.role) {
      case UserRole.employer:
        return const [
          DashboardPage(),
          ManageJobsPage(),
          TalentPage(),
          EmployerNotificationPage(),
          EmployerProfilePage(),
        ];
      case UserRole.admin:
        // TODO: Thêm admin pages khi có
        return const [
          // DashboardPage(),
          // JobPostsPage(),
          // TalentPage(),
          // EmployerMessagesPage(),
          // EmployerProfilePage(),
        ];
      case UserRole.candidate:
        return const [
          HomePage(),
          SearchPage(),
          ApplicationsPage(),
          MessagesPage(),
          ProfilePage(),
        ];
    }
  }

  /// Trả về danh sách nav items (icon) tương ứng với role
  List<IconData> get _navIcons {
    switch (widget.role) {
      case UserRole.employer:
      case UserRole.admin:
        return const [
          Icons.dashboard_rounded,
          Icons.work_outline_rounded,
          Icons.people_outline_rounded,
          Icons.notifications_active,
          Icons.person_outline,
        ];
      case UserRole.candidate:
        return const [
          Icons.home_filled,
          Icons.search,
          Icons.description_outlined,
          Icons.chat_bubble_outline,
          Icons.person_outline,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final icons = _navIcons;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
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
              children: List.generate(icons.length, (i) {
                return _buildNavItem(icons[i], i);
              }),
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
