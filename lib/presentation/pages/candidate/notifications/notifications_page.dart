import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

/// Candidate Notifications page — hiển thị danh sách thông báo.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
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
          const ProfileAvatar(role: UserRole.candidate),
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
            Tab(text: 'Jobs'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(_allNotifications),
          _buildNotificationList(
            _allNotifications.where((n) => n.type == _NType.job).toList(),
          ),
          _buildNotificationList(
            _allNotifications.where((n) => n.type == _NType.message).toList(),
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

enum _NType { job, message, system }

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
    title: 'Your application for Senior UI Designer was viewed',
    time: '2 hours ago',
    icon: Icons.visibility_outlined,
    iconBg: Color(0xFFE3F2FD),
    iconColor: AppColors.primary,
    type: _NType.job,
  ),
  const _NotificationItem(
    title: 'New message from Anh Khoa at VietFin Bank',
    time: '3 hours ago',
    icon: Icons.chat_bubble_outline,
    iconBg: Color(0xFFE8F5E9),
    iconColor: AppColors.success,
    type: _NType.message,
  ),
  const _NotificationItem(
    title: 'Interview scheduled for Product Manager position',
    time: '5 hours ago',
    icon: Icons.calendar_today_outlined,
    iconBg: Color(0xFFF3E5F5),
    iconColor: Color(0xFF8B5CF6),
    type: _NType.job,
  ),
  const _NotificationItem(
    title: 'Congratulations! You were shortlisted for Flutter Developer',
    time: '1 day ago',
    icon: Icons.star_outline_rounded,
    iconBg: Color(0xFFFFF8E1),
    iconColor: AppColors.warning,
    type: _NType.job,
    isRead: true,
  ),
  const _NotificationItem(
    title: 'Chi Hanh sent you a file attachment',
    time: '1 day ago',
    icon: Icons.attach_file_rounded,
    iconBg: Color(0xFFE8F5E9),
    iconColor: AppColors.success,
    type: _NType.message,
    isRead: true,
  ),
  const _NotificationItem(
    title: 'Your profile was viewed 12 times this week',
    time: '2 days ago',
    icon: Icons.trending_up_rounded,
    iconBg: Color(0xFFE3F2FD),
    iconColor: AppColors.primary,
    type: _NType.system,
    isRead: true,
  ),
  const _NotificationItem(
    title: 'New job matching your skills: React Native Developer',
    time: '3 days ago',
    icon: Icons.work_outline_rounded,
    iconBg: Color(0xFFFFF3E0),
    iconColor: AppColors.orange,
    type: _NType.job,
    isRead: true,
  ),
];
