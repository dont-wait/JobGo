import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

/// Admin Notifications page — system alerts, reports & moderation updates.
class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.primary),
            tooltip: 'Mark all as read',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const ProfileAvatar(role: UserRole.admin),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'System'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(_allNotifications),
          _buildNotificationList(
            _allNotifications.where((n) => n.type == _NType.system).toList(),
          ),
          _buildNotificationList(
            _allNotifications.where((n) => n.type == _NType.report).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<_NotificationItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 72, endIndent: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildNotificationTile(item);
      },
    );
  }

  Widget _buildNotificationTile(_NotificationItem item) {
    return Container(
      color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.iconColor, size: 22),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.time,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
        ),
        trailing: item.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          // TODO: Navigate to detail
        },
      ),
    );
  }
}

// ── Mock data ──

enum _NType { system, report, moderation }

class _NotificationItem {
  final String title;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final _NType type;
  final bool isRead;

  const _NotificationItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.type,
    this.isRead = false,
  });
}

final List<_NotificationItem> _allNotifications = [
  const _NotificationItem(
    title: 'New user registration spike detected — 124 signups in 1 hour',
    time: '30 min ago',
    icon: Icons.trending_up_rounded,
    iconBg: Color(0xFFE3F2FD),
    iconColor: AppColors.primary,
    type: _NType.system,
  ),
  const _NotificationItem(
    title: 'Job post reported: "Senior Dev at XYZ Corp" — possible spam',
    time: '1 hour ago',
    icon: Icons.flag_outlined,
    iconBg: Color(0xFFFFEBEE),
    iconColor: AppColors.error,
    type: _NType.report,
  ),
  const _NotificationItem(
    title: '3 job posts pending moderation review',
    time: '2 hours ago',
    icon: Icons.pending_actions_rounded,
    iconBg: Color(0xFFFFF8E1),
    iconColor: AppColors.warning,
    type: _NType.moderation,
  ),
  const _NotificationItem(
    title: 'Monthly system report generated — January 2025',
    time: '5 hours ago',
    icon: Icons.assessment_outlined,
    iconBg: Color(0xFFF3E5F5),
    iconColor: Color(0xFF8B5CF6),
    type: _NType.report,
    isRead: true,
  ),
  const _NotificationItem(
    title: 'Server maintenance scheduled for tonight at 02:00 AM',
    time: '1 day ago',
    icon: Icons.build_circle_outlined,
    iconBg: Color(0xFFE8F5E9),
    iconColor: AppColors.success,
    type: _NType.system,
    isRead: true,
  ),
  const _NotificationItem(
    title: 'User "john_doe" reported employer profile as fraudulent',
    time: '2 days ago',
    icon: Icons.report_problem_outlined,
    iconBg: Color(0xFFFFEBEE),
    iconColor: AppColors.error,
    type: _NType.report,
    isRead: true,
  ),
];
