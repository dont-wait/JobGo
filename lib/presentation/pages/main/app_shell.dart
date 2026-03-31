import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';

// ── Candidate pages ──
import 'package:jobgo/presentation/pages/candidate/home/home_page.dart';
import 'package:jobgo/presentation/pages/candidate/search/search_page.dart';
import 'package:jobgo/presentation/pages/candidate/applications/applications_page.dart';
import 'package:jobgo/presentation/pages/candidate/messages/messages_page.dart';
import 'package:jobgo/presentation/pages/candidate/notifications/notifications_page.dart';
import 'package:jobgo/presentation/pages/candidate/profile/profile_page.dart';

// ── Employer pages ──
import 'package:jobgo/presentation/pages/employer/dashboard/dashboard_page.dart';
import 'package:jobgo/presentation/pages/employer/manage_jobs/manage_jobs_page.dart';
import 'package:jobgo/presentation/pages/employer/talent/talent_page.dart';
import 'package:jobgo/presentation/pages/employer/messages/employer_messages_page.dart';
import 'package:jobgo/presentation/pages/employer/notifications/employer_notifications_page.dart';
import 'package:jobgo/presentation/pages/employer/profile/employer_profile_page.dart';

// ── Admin pages ──
import 'package:jobgo/presentation/pages/admin/dashboard/admin_dashboard_page.dart';
import 'package:jobgo/presentation/pages/admin/search/admin_search_page.dart';
import 'package:jobgo/presentation/pages/admin/users/user_management_page.dart';
import 'package:jobgo/presentation/pages/admin/moderation/job_moderation_page.dart';
import 'package:jobgo/presentation/pages/admin/notifications/admin_notification_page.dart';
import 'package:jobgo/presentation/pages/admin/profile/admin_profile_page.dart';

/// Shell chính của ứng dụng — hiển thị bottom nav + pages theo role.
/// Tab Profile cũ được thay bằng Notification. Profile hiển thị qua avatar trên AppBar.
class AppShell extends StatefulWidget {
  final UserRole role;

  const AppShell({super.key, required this.role});

  /// Chuyển đến trang Profile (ẩn) mà vẫn giữ bottom nav.
  static void goToProfile(BuildContext context) {
    context.findAncestorStateOfType<_AppShellState>()?.goToProfile();
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  /// Chuyển sang trang Profile (index ẩn = 5) mà vẫn giữ shell.
  void goToProfile() {
    setState(() => _currentIndex = _profileIndex);
  }

  /// Index ẩn dành cho Profile (không có icon trên nav bar).
  int get _profileIndex => _navIcons.length; // = 5

  // ── 5 tab chính + 1 Profile ẩn (index 5) ──

  List<Widget> get _pages {
    switch (widget.role) {
      case UserRole.employer:
        return const [
          DashboardPage(), // 0
          ManageJobsPage(), // 1
          TalentPage(), // 2
          EmployerMessagesPage(), // 3 — Tin nhắn
          EmployerNotificationsPage(), // 4 — Notification
          EmployerProfilePage(), // 5 — Profile ẩn
        ];
      case UserRole.admin:
        return const [
          AdminDashboardPage(), // 0
          AdminSearchPage(), // 1
          UserManagementPage(), // 2
          JobModerationPage(), // 3
          AdminNotificationPage(), // 4 — Notification (thay Profile)
          AdminProfilePage(), // 5 — Profile ẩn
        ];
      case UserRole.candidate:
        return const [
          HomePage(), // 0
          SearchPage(), // 1
          ApplicationsPage(), // 2
          MessagesPage(), // 3
          NotificationsPage(), // 4 — Notification (thay Profile)
          ProfilePage(), // 5 — Profile ẩn
        ];
    }
  }

  // ── 5 nav icons (Profile không có icon, nằm ẩn) ──

  List<IconData> get _navIcons {
    switch (widget.role) {
      case UserRole.employer:
        return const [
          Icons.dashboard_rounded,
          Icons.work_outline_rounded,
          Icons.people_outline_rounded,
          Icons.chat_bubble_outline,
          Icons.notifications_outlined,
        ];
      case UserRole.admin:
        return const [
          Icons.dashboard_rounded,
          Icons.search,
          Icons.people_outline_rounded,
          Icons.work_outline_rounded,
          Icons.notifications_outlined,
        ];
      case UserRole.candidate:
        return const [
          Icons.home_filled,
          Icons.search,
          Icons.description_outlined,
          Icons.chat_bubble_outline,
          Icons.notifications_outlined,
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

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
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
