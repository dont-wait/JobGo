import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

/// Employer Notifications page — thông báo tuyển dụng, ứng viên, phản hồi, hệ thống.
class EmployerNotificationsPage extends StatefulWidget {
  const EmployerNotificationsPage({super.key});

  @override
  State<EmployerNotificationsPage> createState() =>
      _EmployerNotificationsPageState();
}

class _EmployerNotificationsPageState extends State<EmployerNotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        actions: const [
          ProfileAvatar(role: UserRole.employer),
          SizedBox(width: 4),
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
            Tab(text: 'Applicants'),
            Tab(text: 'Responses'),
            Tab(text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(_allNotifications),
          _buildNotificationList(
            _allNotifications.where((n) => n.type == _NType.applicant).toList(),
          ),
          _buildNotificationList(
            _allNotifications.where((n) => n.type == _NType.response).toList(),
          ),
          _buildNotificationList(
            _allNotifications.where((n) => n.type == _NType.system).toList(),
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
      itemBuilder: (context, index) => _buildNotificationTile(items[index]),
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
            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
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
        onTap: () {},
      ),
    );
  }
}

// ── Mock data ──

enum _NType { applicant, response, system }

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
    title: 'Sarah Jenkins accepted your interview invitation',
    time: '30 min ago',
    icon: Icons.check_circle_outline,
    iconBg: Color(0xFFE8F5E9),
    iconColor: AppColors.success,
    type: _NType.applicant,
  ),
  const _NotificationItem(
    title: 'New application received for Senior UI Designer',
    time: '2 hours ago',
    icon: Icons.description_outlined,
    iconBg: Color(0xFFE3F2FD),
    iconColor: AppColors.primary,
    type: _NType.applicant,
  ),
  // ── Responses (gộp từ CandidateResponses) ──
  const _NotificationItem(
    title: 'Sarah Jenkins: "Tôi xác nhận sẽ tham gia phỏng vấn ngày 7/3"',
    time: '3 hours ago',
    icon: Icons.thumb_up_outlined,
    iconBg: Color(0xFFE8F5E9),
    iconColor: AppColors.success,
    type: _NType.response,
  ),
  const _NotificationItem(
    title: 'Michael Brown: "Xin lỗi, tôi không thể tham gia lịch hẹn này"',
    time: '4 hours ago',
    icon: Icons.thumb_down_outlined,
    iconBg: Color(0xFFFFEBEE),
    iconColor: AppColors.error,
    type: _NType.response,
  ),
  const _NotificationItem(
    title: 'Emily Davis: "Có thể đổi lịch sang ngày khác không?"',
    time: '5 hours ago',
    icon: Icons.schedule_outlined,
    iconBg: Color(0xFFFFF8E1),
    iconColor: AppColors.warning,
    type: _NType.response,
  ),
  // ── System ──
  const _NotificationItem(
    title: 'Your job post "Flutter Developer" is expiring in 3 days',
    time: '5 hours ago',
    icon: Icons.timer_outlined,
    iconBg: Color(0xFFFFF8E1),
    iconColor: AppColors.warning,
    type: _NType.system,
  ),
  const _NotificationItem(
    title: 'David Chen declined interview for Product Manager',
    time: '1 day ago',
    icon: Icons.cancel_outlined,
    iconBg: Color(0xFFFFEBEE),
    iconColor: AppColors.error,
    type: _NType.applicant,
    isRead: true,
  ),
  const _NotificationItem(
    title: 'Monthly hiring report is ready to download',
    time: '2 days ago',
    icon: Icons.assessment_outlined,
    iconBg: Color(0xFFF3E5F5),
    iconColor: Color(0xFF8B5CF6),
    type: _NType.system,
    isRead: true,
  ),
];
