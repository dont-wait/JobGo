import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/employer_message_thread.dart';
import 'package:jobgo/data/repositories/message_repository.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

/// Trang nhắn tin của Employer — phân loại theo Employer, Candidate, Admin.
class EmployerMessagesPage extends StatefulWidget {
  const EmployerMessagesPage({super.key});

  @override
  State<EmployerMessagesPage> createState() => _EmployerMessagesPageState();
}

class _EmployerMessagesPageState extends State<EmployerMessagesPage> {
  ChatUserRole? _selectedFilter;
  final MessageRepository _repository = MessageRepository();
  late Future<List<EmployerMessageThread>> _threadsFuture;
  List<EmployerMessageThread> _threads = [];

  @override
  void initState() {
    super.initState();
    _threadsFuture = _loadThreads();
  }

  Future<List<EmployerMessageThread>> _loadThreads() async {
    final threads = await _repository.fetchEmployerThreads();
    if (mounted) {
      setState(() => _threads = threads);
    }
    return threads;
  }

  List<EmployerMessageThread> get _filteredThreads {
    if (_selectedFilter == null) return _threads;
    return _threads.where((t) => t.userRole == _selectedFilter).toList();
  }

  List<EmployerMessageThread> get _pinned =>
      _filteredThreads.where((t) => t.isPinned).toList();

  List<EmployerMessageThread> get _others =>
      _filteredThreads.where((t) => !t.isPinned).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: FutureBuilder<List<EmployerMessageThread>>(
              future: _threadsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _threadsFuture = _loadThreads();
                    });
                    await _threadsFuture;
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(child: _buildSearch()),
                      SliverToBoxAdapter(child: _buildFilters()),
                      if (_pinned.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _buildSectionHeader('Pinned', _pinned.length),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _MessageTile(thread: _pinned[i]),
                            childCount: _pinned.length,
                          ),
                        ),
                      ],
                      if (_others.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _buildSectionHeader('All', _others.length),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _MessageTile(thread: _others[i]),
                            childCount: _others.length,
                          ),
                        ),
                      ],
                      if (_filteredThreads.isEmpty)
                        SliverFillRemaining(child: _buildEmpty()),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──

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
                  'Messages',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Chat with candidates & partners',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _CircleIconButton(
            icon: Icons.edit_outlined,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          const ProfileAvatar(role: UserRole.employer),
        ],
      ),
    );
  }

  // ── Search ──

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
                'Search messages, users...',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
            Icon(Icons.mic_none, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  // ── Filters (phân loại role) ──

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _RoleFilterChip(
            label: 'All',
            isActive: _selectedFilter == null,
            onTap: () => setState(() => _selectedFilter = null),
          ),
          _RoleFilterChip(
            label: 'Candidates',
            icon: Icons.person_outline,
            isActive: _selectedFilter == ChatUserRole.candidate,
            onTap: () =>
                setState(() => _selectedFilter = ChatUserRole.candidate),
          ),
          _RoleFilterChip(
            label: 'Employers',
            icon: Icons.business_outlined,
            isActive: _selectedFilter == ChatUserRole.employer,
            onTap: () =>
                setState(() => _selectedFilter = ChatUserRole.employer),
          ),
          _RoleFilterChip(
            label: 'Admin',
            icon: Icons.admin_panel_settings_outlined,
            isActive: _selectedFilter == ChatUserRole.admin,
            onTap: () => setState(() => _selectedFilter = ChatUserRole.admin),
          ),
        ],
      ),
    );
  }

  // ── Section header ──

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

  // ── Empty state ──

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          const Text(
            'No messages yet',
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

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            const Text(
              'Unable to load messages',
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
              onPressed: () {
                setState(() {
                  _threadsFuture = _loadThreads();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background ──

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFF), AppColors.lightBackground],
        ),
      ),
      child: const Stack(
        children: [
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
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS
// ══════════════════════════════════════════════════════════════

/// Chip filter theo role.
class _RoleFilterChip extends StatelessWidget {
  const _RoleFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile hiển thị 1 cuộc trò chuyện.
class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.thread});

  final EmployerMessageThread thread;

  Color get _roleBadgeColor {
    switch (thread.userRole) {
      case ChatUserRole.candidate:
        return AppColors.primary;
      case ChatUserRole.employer:
        return AppColors.orange;
      case ChatUserRole.admin:
        return const Color(0xFFEF4444);
    }
  }

  String get _roleLabel {
    switch (thread.userRole) {
      case ChatUserRole.candidate:
        return 'Candidate';
      case ChatUserRole.employer:
        return 'Employer';
      case ChatUserRole.admin:
        return 'Admin';
    }
  }

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
                  // Name + time
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
                  // Subtitle
                  Text(
                    thread.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Last message + unread
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
                              horizontal: 8, vertical: 4),
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
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (thread.isPinned)
                        const _Tag(
                            label: 'Pinned', color: Color(0xFFEFF6FF)),
                      _Tag(
                        label: _roleLabel,
                        color: _roleBadgeColor.withValues(alpha: 0.1),
                        textColor: _roleBadgeColor,
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

// ── Shared small widgets ──

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

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    this.textColor,
  });

  final String label;
  final Color color;
  final Color? textColor;

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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
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