import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/conversation_model.dart';
import 'package:jobgo/presentation/providers/chat_provider.dart';
import 'package:jobgo/presentation/pages/common/chat_detail_page.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

/// Candidate Messages page — realtime qua ChatProvider.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatProvider.error != null &&
                    chatProvider.conversations.isEmpty) {
                  return _buildError(chatProvider.error!, loc);
                }

                final conversations = _filteredConversations(
                  chatProvider.conversations,
                );

                return RefreshIndicator(
                  onRefresh: () => chatProvider.loadConversations(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(loc)),
                      SliverToBoxAdapter(child: _buildSearch(loc)),
                      if (conversations.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _buildSectionHeader(
                              loc.messagesTitle, conversations.length),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _ConversationTile(
                              conversation: conversations[i],
                              currentUserId:
                                  chatProvider.currentUserId ?? 0,
                            ),
                            childCount: conversations.length,
                          ),
                        ),
                      ],
                      if (conversations.isEmpty)
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

  List<ConversationModel> _filteredConversations(
      List<ConversationModel> conversations) {
    if (_searchQuery.isEmpty) return conversations;
    final query = _searchQuery.toLowerCase();
    return conversations.where((c) {
      final name = c.displayName.toLowerCase();
      return name.contains(query);
    }).toList();
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

  Widget _buildHeader(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.messagesTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.fromRecruiters,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const _CircleIconButton(icon: Icons.tune),
          const SizedBox(width: 12),
          const ProfileAvatar(role: UserRole.candidate),
        ],
      ),
    );
  }

  Widget _buildSearch(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textHint),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: loc.searchMessagesHint,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: AppColors.textHint),
                ),
              ),
            ),
            const Icon(Icons.mic_none, color: AppColors.textHint),
          ],
        ),
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

  Widget _buildError(String message, AppLocalizations loc) {
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
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<ChatProvider>().loadConversations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS
// ══════════════════════════════════════════════════════════════

/// Tile hiển thị 1 conversation.
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
  });

  final ConversationModel conversation;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    final name = conversation.displayName;
    final lastMsg = conversation.lastMessage;
    final color = _colorFromName(name);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(
              otherUserId: conversation.otherUserId,
              otherUserName: name,
              avatarColor: color,
            ),
          ),
        );
      },
      child: Padding(
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
              _AvatarBadge(name: name, color: color),
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
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (lastMsg != null)
                          Text(
                            _formatTime(lastMsg.sentAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Last message + unread badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMsg?.content ?? 'Chưa có tin nhắn',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: conversation.unreadCount > 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return labels[dateTime.weekday - 1];
    }
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
  }

  Color _colorFromName(String name) {
    final seed = name.isEmpty ? 1 : name.codeUnits.reduce((a, b) => a + b);
    final random = Random(seed);
    return Color.fromARGB(
      255,
      80 + random.nextInt(140),
      80 + random.nextInt(140),
      80 + random.nextInt(140),
    );
  }
}

// ── Small shared widgets ──

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.characters.first : '?';
    return CircleAvatar(
      radius: 24,
      backgroundColor: color,
      child: Text(
        initial.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}