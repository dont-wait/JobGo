import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/conversation_model.dart';
import 'package:jobgo/presentation/providers/chat_provider.dart';

/// Trang chat chi tiết realtime — dùng chung cho Candidate & Employer.
/// Dùng bảng `messages` có sẵn (sender_id / receiver_id).
class ChatDetailPage extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final Color? avatarColor;

  const ChatDetailPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.avatarColor,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initUserId();
    // Mark as read when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().markAsRead(widget.otherUserId);
    });
  }

  Future<void> _initUserId() async {
    final userId = await context.read<ChatProvider>().getUserId();
    if (mounted) {
      setState(() => _currentUserId = userId);
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    try {
      await context.read<ChatProvider>().sendMessage(
            receiverId: widget.otherUserId,
            content: text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi tin: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = widget.avatarColor ?? AppColors.primary;
    final initial = widget.otherUserName.isNotEmpty
        ? widget.otherUserName.characters.first.toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, initial, avatarColor),
            Expanded(child: _buildMessageList()),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader(BuildContext context, String initial, Color avatarColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, color: AppColors.textSecondary),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Message List (Realtime) ──

  Widget _buildMessageList() {
    if (_currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<ChatMessageModel>>(
      stream: context.read<ChatProvider>().streamMessages(widget.otherUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Lỗi: ${snapshot.error}',
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.textHint.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hãy gửi lời chào để bắt đầu cuộc trò chuyện!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Auto-scroll to bottom when new messages arrive
        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.isMe(_currentUserId!);
            final showTime = index == 0 ||
                messages[index].sentAt
                        .difference(messages[index - 1].sentAt)
                        .inMinutes >
                    5;

            return Column(
              children: [
                if (showTime) _buildTimeDivider(msg.sentAt),
                _MessageBubble(message: msg, isMe: isMe),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimeDivider(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    String label;
    if (diff.inMinutes < 1) {
      label = 'Vừa xong';
    } else if (diff.inHours < 1) {
      label = '${diff.inMinutes} phút trước';
    } else if (diff.inDays < 1) {
      label =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      label = 'Hôm qua';
    } else {
      label =
          '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Composer ──

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.textSecondary),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _msgController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textHint),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0A73B7)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble Widget ──

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textHint,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == 'read'
                        ? Icons.done_all
                        : message.status == 'delivered'
                            ? Icons.done_all
                            : Icons.done,
                    size: 14,
                    color: message.status == 'read'
                        ? Colors.lightBlueAccent
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
