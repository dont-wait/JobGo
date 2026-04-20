import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/notification_model.dart';
import 'package:jobgo/data/repositories/notification_repository.dart';
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
  final NotificationRepository _notificationRepo = NotificationRepository();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notificationsFuture = _notificationRepo.fetchNotificationsForCurrentUser();
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
          _buildNotificationTab(_NType.all),
          _buildNotificationTab(_NType.applicant),
          _buildNotificationTab(_NType.response),
          _buildNotificationTab(_NType.system),
        ],
      ),
    );
  }

  Widget _buildNotificationTab(_NType type) {
    return FutureBuilder<List<NotificationModel>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final models = snapshot.data ?? [];
        final items = models.map(_toNotificationItem).toList();
        final filtered = type == _NType.all
            ? items
            : items.where((item) => item.type == type).toList();

        return _buildNotificationList(filtered);
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            const Text(
              'Unable to load notifications',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<_NotificationItem> items) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_off_outlined,
                        size: 64,
                        color: AppColors.textHint.withValues(alpha: 0.5)),
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
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 72, endIndent: 16),
        itemBuilder: (context, index) => _buildNotificationTile(items[index]),
      ),
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

  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = _notificationRepo.fetchNotificationsForCurrentUser();
    });
    await _notificationsFuture;
  }

  _NotificationItem _toNotificationItem(NotificationModel model) {
    final type = _mapType(model.type);
    final visual = _resolveVisual(type, model.type);
    return _NotificationItem(
      title: model.content,
      time: _formatTimeAgo(model.createdAt),
      icon: visual.icon,
      iconBg: visual.iconBg,
      iconColor: visual.iconColor,
      type: type,
      isRead: model.isRead,
    );
  }

  _NType _mapType(String rawType) {
    final normalized = rawType.toLowerCase();
    if (normalized.contains('applicant') ||
        normalized.contains('application') ||
        normalized.contains('candidate')) {
      return _NType.applicant;
    }

    if (normalized.contains('response') ||
        normalized.contains('interview') ||
        normalized.contains('accept') ||
        normalized.contains('decline')) {
      return _NType.response;
    }

    return _NType.system;
  }

  _NotificationVisual _resolveVisual(_NType type, String rawType) {
    final normalized = rawType.toLowerCase();
    switch (type) {
      case _NType.applicant:
        return const _NotificationVisual(
          icon: Icons.description_outlined,
          iconBg: Color(0xFFE3F2FD),
          iconColor: AppColors.primary,
        );
      case _NType.response:
        if (normalized.contains('decline') || normalized.contains('reject')) {
          return const _NotificationVisual(
            icon: Icons.thumb_down_outlined,
            iconBg: Color(0xFFFFEBEE),
            iconColor: AppColors.error,
          );
        }
        if (normalized.contains('accept') || normalized.contains('confirm')) {
          return const _NotificationVisual(
            icon: Icons.thumb_up_outlined,
            iconBg: Color(0xFFE8F5E9),
            iconColor: AppColors.success,
          );
        }
        return const _NotificationVisual(
          icon: Icons.schedule_outlined,
          iconBg: Color(0xFFFFF8E1),
          iconColor: AppColors.warning,
        );
      case _NType.system:
        return const _NotificationVisual(
          icon: Icons.info_outline,
          iconBg: Color(0xFFFFF8E1),
          iconColor: AppColors.warning,
        );
      case _NType.all:
        return const _NotificationVisual(
          icon: Icons.notifications_outlined,
          iconBg: Color(0xFFE3F2FD),
          iconColor: AppColors.primary,
        );
    }
  }

  String _formatTimeAgo(DateTime? createdAt) {
    if (createdAt == null) return 'Just now';

    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }
}

// ── Mock data ──

enum _NType { all, applicant, response, system }

class _NotificationVisual {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _NotificationVisual({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

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

