import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'package:jobgo/presentation/providers/employer_provider.dart';
import 'package:jobgo/presentation/providers/chat_provider.dart';
import 'package:jobgo/presentation/providers/notification_provider.dart';

// ── Candidate pages ──
import 'package:jobgo/presentation/pages/candidate/home/home_page.dart';
import 'package:jobgo/presentation/pages/candidate/search/search_page.dart';
import 'package:jobgo/presentation/pages/candidate/applications/applications_page.dart';
import 'package:jobgo/presentation/pages/candidate/messages/messages_page.dart';
import 'package:jobgo/presentation/pages/candidate/notifications/notifications_page.dart';
import 'package:jobgo/presentation/pages/candidate/profile/profile_page.dart';
import 'package:jobgo/presentation/pages/candidate/interview_schedule/candidate_interview_page.dart';

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
import 'package:jobgo/presentation/pages/admin/profile/admin_profile_page.dart';

/// Shell chính của ứng dụng — hiển thị bottom nav + pages theo role.
/// Tab Profile cũ được thay bằng Notification. Profile hiển thị qua avatar trên AppBar.
class AppShell extends StatefulWidget {
  static final GlobalKey<_AppShellState> shellKey =
      GlobalKey<_AppShellState>();
  final UserRole role;

  const AppShell({super.key, required this.role});

  /// Chuyển đến trang Profile (ẩn) mà vẫn giữ bottom nav.
  static void goToProfile(BuildContext context) {
    final shellState = context.findAncestorStateOfType<_AppShellState>() ??
        shellKey.currentState;
    shellState?.goToProfile();
  }

  /// Chuyển đến trang Messages (tab 3 cho employer/candidate) mà vẫn giữ bottom nav.
  static bool goToMessages(BuildContext context) {
    final shellState = context.findAncestorStateOfType<_AppShellState>() ??
        shellKey.currentState;
    if (shellState == null) return false;

    shellState.goToMessages();
    return true;
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _indexInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load profile early so pages like ApplicationsPage have it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.candidate == null) {
        profileProvider.loadProfile();
      }
      
      // Khởi tạo luồng lắng nghe tin nhắn và thông báo realtime cho user hiện tại
      context.read<ChatProvider>().initRealtimeSubscriptions();
      context.read<NotificationProvider>().initRealtimeSubscriptions();

      // Tự động check profile sau khi load xong, hiện popup nếu thiếu thông tin
      _checkProfileCompleteness();
    });
  }

  /// Kiểm tra thông tin profile có đầy đủ không.
  /// Nếu thiếu phone/address/... thì hiện popup nhắc cập nhật.
  void _checkProfileCompleteness() {
    if (widget.role == UserRole.candidate) {
      final provider = context.read<ProfileProvider>();
      // Đợi profile load xong
      void listener() {
        if (!provider.isLoading && mounted) {
          provider.removeListener(listener);
          final c = provider.candidate;
          if (c != null && _isCandidateIncomplete(c)) {
            _showProfileUpdateDialog();
          }
        }
      }
      if (!provider.isLoading && provider.candidate != null) {
        if (_isCandidateIncomplete(provider.candidate!)) {
          _showProfileUpdateDialog();
        }
      } else {
        provider.addListener(listener);
      }
    } else if (widget.role == UserRole.employer) {
      final provider = context.read<EmployerProvider>();
      void listener() {
        if (!provider.isLoading && mounted) {
          provider.removeListener(listener);
          final e = provider.employer;
          if (e != null && _isEmployerIncomplete(e)) {
            _showProfileUpdateDialog();
          }
        }
      }
      if (!provider.isLoading && provider.employer != null) {
        if (_isEmployerIncomplete(provider.employer!)) {
          _showProfileUpdateDialog();
        }
      } else {
        provider.addListener(listener);
      }
    }
  }

  /// Candidate thiếu thông tin nếu chưa có phone hoặc address
  bool _isCandidateIncomplete(dynamic c) {
    final phone = c.phone as String?;
    final address = c.address as String?;
    return (phone == null || phone.isEmpty) &&
           (address == null || address.isEmpty);
  }

  /// Employer thiếu thông tin nếu chưa có phone hoặc companyName vẫn là default
  bool _isEmployerIncomplete(dynamic e) {
    final phone = e.phone as String?;
    final companyName = e.companyName as String?;
    return (phone == null || phone.isEmpty) ||
           (companyName == null || companyName.isEmpty || companyName == 'Unspecified Company');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_indexInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('initialIndex')) {
        final idx = args['initialIndex'] as int;
        if (idx >= 0 && idx < _pages.length) {
          _currentIndex = idx;
        }
      }
      _indexInitialized = true;
    }
  }

  /// Chuyển sang trang Profile (index ẩn = 5) mà vẫn giữ shell.
  void goToProfile() {
    setState(() => _currentIndex = _profileIndex);
  }

  /// Chuyển sang trang Messages (tab 3) mà vẫn giữ shell.
  void goToMessages() {
    setState(() => _currentIndex = 3); // 3 = Messages tab for both employer and candidate
  }

  /// Hiển thị dialog nhắc user cập nhật thông tin profile sau khi đăng ký bằng social login.
  void _showProfileUpdateDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline, color: AppColors.primary, size: 32),
        ),
        title: Text(
          loc.completeProfileTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          loc.completeProfileMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.later),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              goToProfile();
            },
            child: Text(loc.goToProfile),
          ),
        ],
      ),
    );
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
          AdminProfilePage(), // 4 — Profile ẩn
        ];
      case UserRole.candidate:
        return const [
          HomePage(), // 0
          SearchPage(), // 1
          ApplicationsPage(), // 2
          MessagesPage(), // 3
          NotificationsPage(), // 4 — Notification (thay Profile)
          ProfilePage(), // 5 — Profile ẩn
          CandidateInterviewPage(), // 6 — Interview ẩn
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

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;

    // Determine badge count based on tab index and role
    int badgeCount = 0;
    if (widget.role != UserRole.admin) {
      if (index == 3) {
        // Messages tab
        badgeCount = context.watch<ChatProvider>().totalUnread;
      } else if (index == 4) {
        // Notifications tab
        badgeCount = context.watch<NotificationProvider>().unreadCount;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
