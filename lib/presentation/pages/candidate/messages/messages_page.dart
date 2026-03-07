import 'package:flutter/material.dart';

import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static const List<_MessageThread> _threads = [
    _MessageThread(
      name: 'Anh Khoa',
      company: 'VietFin Bank',
      role: 'Senior Flutter Dev',
      lastMessage: 'Anh đã xem CV. Em có thể phỏng vấn thứ 6?',
      time: '09:12',
      unreadCount: 2,
      isPinned: true,
      isOnline: true,
      hasAttachment: true,
      avatarColor: Color(0xFF0A73B7),
    ),
    _MessageThread(
      name: 'Chi Hanh',
      company: 'Sunrise Studio',
      role: 'UI/UX Designer',
      lastMessage: 'Gửi giúp portfolio dạng PDF nhé.',
      time: '08:41',
      unreadCount: 0,
      isPinned: true,
      isOnline: false,
      hasAttachment: false,
      avatarColor: Color(0xFF10B981),
    ),
    _MessageThread(
      name: 'Mr. Toan',
      company: 'Aster Tech',
      role: 'Mobile Engineer',
      lastMessage: 'Lịch phỏng vấn: Thứ 5, 2:00 PM',
      time: 'Yesterday',
      unreadCount: 1,
      isPinned: false,
      isOnline: true,
      hasAttachment: false,
      avatarColor: Color(0xFFF59E0B),
    ),
    _MessageThread(
      name: 'Ms. Linh',
      company: 'Blue Ocean',
      role: 'QA Engineer',
      lastMessage: 'Cảm ơn bạn! Chúng tôi sẽ phản hồi sớm.',
      time: 'Tue',
      unreadCount: 0,
      isPinned: false,
      isOnline: false,
      hasAttachment: false,
      avatarColor: Color(0xFF6366F1),
    ),
    _MessageThread(
      name: 'Recruitment',
      company: 'NovaWorks',
      role: 'Product Intern',
      lastMessage: 'Bạn có thể bắt đầu tuần tới không?',
      time: 'Mon',
      unreadCount: 3,
      isPinned: false,
      isOnline: true,
      hasAttachment: true,
      avatarColor: Color(0xFFEF4444),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pinned =
        _threads.where((thread) => thread.isPinned).toList(growable: false);
    final others =
        _threads.where((thread) => !thread.isPinned).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildSearch()),
                SliverToBoxAdapter(child: _buildFilters()),
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Ghim', pinned.length),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _MessageTile(thread: pinned[index]),
                    childCount: pinned.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Tất cả', others.length),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _MessageTile(thread: others[index]),
                    childCount: others.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFF), AppColors.lightBackground],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -80,
            right: -40,
            child: _GlowCircle(size: 180, color: Color(0x334DA3E0)),
          ),
          Positioned(
            top: 140,
            left: -60,
            child: _GlowCircle(size: 140, color: Color(0x220A73B7)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tin nhắn',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Từ nhà tuyển dụng',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _CircleIconButton(icon: Icons.tune),
          const SizedBox(width: 12),
          const ProfileAvatar(role: UserRole.candidate),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.textHint),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tìm kiếm tin nhắn, công ty... ',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
            Icon(Icons.mic_none, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          _FilterChip(label: 'Chưa đọc', isActive: true),
          _FilterChip(label: 'Tuyển gấp', isActive: false),
          _FilterChip(label: 'Đã phỏng vấn', isActive: false),
          _FilterChip(label: 'Đã lưu', isActive: false),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.thread});

  final _MessageThread thread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AvatarBadge(
              name: thread.name,
              color: thread.avatarColor,
              isOnline: thread.isOnline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        thread.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${thread.company} • ${thread.role}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (thread.hasAttachment)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.attach_file,
                            size: 16,
                            color: AppColors.textHint,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          thread.lastMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: thread.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (thread.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (thread.isPinned)
                        const _Tag(label: 'Ghim', color: Color(0xFFEFF6FF)),
                      const _Tag(
                        label: 'Phản hồi trong 24h',
                        color: Color(0xFFEFFAF3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.name,
    required this.color,
    required this.isOnline,
  });

  final String name;
  final Color color;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.characters.first : '?';
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Text(
            initial.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : AppColors.textHint,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 20),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MessageThread {
  const _MessageThread({
    required this.name,
    required this.company,
    required this.role,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isPinned,
    required this.isOnline,
    required this.hasAttachment,
    required this.avatarColor,
  });

  final String name;
  final String company;
  final String role;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isPinned;
  final bool isOnline;
  final bool hasAttachment;
  final Color avatarColor;
}
