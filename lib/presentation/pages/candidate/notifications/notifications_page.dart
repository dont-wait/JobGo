import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/notification_model.dart';
import 'package:jobgo/presentation/providers/notification_provider.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/presentation/providers/chat_provider.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';
import 'package:jobgo/presentation/pages/candidate/interview_schedule/candidate_interview_page.dart';

/// Candidate Notifications page — realtime qua NotificationProvider.
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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          loc.notifications,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.primary),
            tooltip: loc.markAllAsRead,
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.allMarkedAsReadMessage),
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
          tabs: [
            Tab(text: loc.allLabel),
            Tab(text: loc.jobs),
            Tab(text: loc.interviewsTabLabel),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loc.messagesTitle),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      final count = chatProvider.totalUnread;
                      if (count <= 0) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationTab(_NType.all),
          _buildNotificationTab(_NType.job),
          _buildNotificationTab(_NType.interviewSchedule),
          _buildNotificationTab(_NType.message),
        ],
      ),
    );
  }

  Widget _buildNotificationTab(_NType filterType) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.notifications.isEmpty) {
          return _buildErrorState(provider.error!);
        }

        final items = provider.notifications
            .map(_toNotificationItem)
            .toList();
        final filtered = filterType == _NType.all
            ? items
            : items.where((item) => item.type == filterType).toList();

        return _buildNotificationList(filtered, provider);
      },
    );
  }

  Widget _buildErrorState(String message) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(
              loc.unableToLoadNotifications,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<NotificationProvider>().loadNotifications(),
              child: Text(loc.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<_NotificationItem> items,
    NotificationProvider provider,
  ) {
    final loc = AppLocalizations.of(context);
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadNotifications(),
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
                    Text(
                      loc.noNotificationsMessage,
                      style: const TextStyle(
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
      onRefresh: () => provider.loadNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 72, endIndent: 16),
        itemBuilder: (context, index) =>
            _buildNotificationTile(items[index], provider),
      ),
    );
  }

  Widget _buildNotificationTile(
    _NotificationItem item,
    NotificationProvider provider,
  ) {
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
        onTap: () {
          // Mark as read
          if (!item.isRead) {
            provider.markAsRead(item.id);
          }
          // Navigate for interview notifications
          if (item.type == _NType.interviewSchedule) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CandidateInterviewPage(),
              ),
            );
          }
        },
      ),
    );
  }

  // ── Mapping helpers ──

  _NotificationItem _toNotificationItem(NotificationModel model) {
    final type = _mapType(model.type);
    final visual = _resolveVisual(type, model.type);
    return _NotificationItem(
      id: model.id,
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
    if (normalized.contains('job') ||
        normalized.contains('application') ||
        normalized.contains('shortlist')) {
      return _NType.job;
    }
    if (normalized.contains('interview') || normalized.contains('schedule')) {
      return _NType.interviewSchedule;
    }
    if (normalized.contains('message') || normalized.contains('chat')) {
      return _NType.message;
    }
    return _NType.system;
  }

  _NotificationVisual _resolveVisual(_NType type, String rawType) {
    switch (type) {
      case _NType.job:
        return const _NotificationVisual(
          icon: Icons.work_outline_rounded,
          iconBg: Color(0xFFE3F2FD),
          iconColor: AppColors.primary,
        );
      case _NType.interviewSchedule:
        return const _NotificationVisual(
          icon: Icons.calendar_today_outlined,
          iconBg: Color(0xFFF3E5F5),
          iconColor: Color(0xFF8B5CF6),
        );
      case _NType.message:
        return const _NotificationVisual(
          icon: Icons.chat_bubble_outline,
          iconBg: Color(0xFFE8F5E9),
          iconColor: AppColors.success,
        );
      case _NType.all:
        return const _NotificationVisual(
          icon: Icons.notifications_outlined,
          iconBg: Color(0xFFE3F2FD),
          iconColor: AppColors.primary,
        );
      case _NType.system:
        return const _NotificationVisual(
          icon: Icons.info_outline,
          iconBg: Color(0xFFFFF8E1),
          iconColor: AppColors.warning,
        );
    }
  }

  String _formatTimeAgo(DateTime? createdAt) {
    if (createdAt == null) return 'Just now';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }
}

// ── Data classes ──

enum _NType { all, job, message, interviewSchedule, system }

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
  final int id;
  final String title;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final _NType type;
  final bool isRead;

  const _NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.type,
    this.isRead = false,
  });
}
