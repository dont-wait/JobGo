import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/conversation_model.dart';
import 'package:jobgo/core/utils/app_logger.dart';

/// Repository xử lý chat realtime — dùng bảng `messages` có sẵn.
///
/// Schema bảng messages:
///   m_id (int PK), sender_id (int FK), receiver_id (int FK),
///   m_content (text), m_status (varchar), m_sent_at (timestamp),
///   u_id (int FK), i_id (int FK)
class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  int? _cachedUserId;

  /// Public getter cho cached user ID.
  int? get cachedUserId => _cachedUserId;

  // ── Lấy u_id hiện tại ──

  Future<int?> getCurrentUserId() async {
    if (_cachedUserId != null) return _cachedUserId;

    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    final userRow = await _supabase
        .from('users')
        .select('u_id')
        .eq('auth_uid', authUser.id)
        .maybeSingle();

    if (userRow == null) return null;
    _cachedUserId = _toInt(userRow['u_id']);
    return _cachedUserId;
  }

  void clearCache() => _cachedUserId = null;

  // ── Conversations (derived từ bảng messages) ──

  /// Lấy danh sách conversations bằng cách nhóm messages theo cặp sender/receiver.
  Future<List<ConversationModel>> fetchConversations() async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    // Lấy tất cả messages liên quan đến user hiện tại
    final rows = await _supabase
        .from('messages')
        .select('m_id, sender_id, receiver_id, m_content, m_status, m_sent_at')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('m_sent_at', ascending: false);

    if ((rows as List).isEmpty) return [];

    // Nhóm theo otherUserId
    final Map<int, List<ChatMessageModel>> grouped = {};
    for (final row in rows) {
      final msg = ChatMessageModel.fromJson(Map<String, dynamic>.from(row));
      final otherId = msg.otherUserId(userId);
      grouped.putIfAbsent(otherId, () => []);
      grouped[otherId]!.add(msg);
    }

    // Lấy thông tin user cho tất cả otherUserIds
    final otherIds = grouped.keys.toList();
    final userRows = await _supabase
        .from('users')
        .select('u_id, u_name, u_email, u_role, candidates(c_full_name), employers(e_company_name)')
        .inFilter('u_id', otherIds);

    final userMap = <int, Map<String, dynamic>>{};
    for (final u in (userRows as List)) {
      final uid = _toInt(u['u_id']);
      if (uid != null) userMap[uid] = Map<String, dynamic>.from(u);
    }

    // Tạo ConversationModel cho mỗi nhóm
    final conversations = <ConversationModel>[];
    for (final entry in grouped.entries) {
      final otherId = entry.key;
      final messages = entry.value;
      final userData = userMap[otherId];

      final unreadCount = messages
          .where((m) => m.receiverId == userId && m.status != 'read')
          .length;

      String? displayName;
      
      // Ưu tiên lấy c_full_name nếu là candidate
      if (userData != null && userData['candidates'] != null) {
        final cData = userData['candidates'];
        if (cData is List && cData.isNotEmpty) {
          displayName = cData.first['c_full_name'] as String?;
        } else if (cData is Map) {
          displayName = cData['c_full_name'] as String?;
        }
      }
      
      // Hoặc lấy e_company_name nếu là employer
      if (displayName == null && userData != null && userData['employers'] != null) {
        final eData = userData['employers'];
        if (eData is List && eData.isNotEmpty) {
          displayName = eData.first['e_company_name'] as String?;
        } else if (eData is Map) {
          displayName = eData['e_company_name'] as String?;
        }
      }

      conversations.add(ConversationModel(
        otherUserId: otherId,
        otherUserName: displayName ??
            userData?['u_name'] as String? ??
            userData?['u_email'] as String? ??
            'User #$otherId',
        otherUserRole: userData?['u_role'] as String?,
        lastMessage: messages.first, // đã sort DESC
        unreadCount: unreadCount,
      ));
    }

    // Sort theo last message time
    conversations.sort((a, b) {
      final ta = a.lastMessage?.sentAt ?? DateTime(2000);
      final tb = b.lastMessage?.sentAt ?? DateTime(2000);
      return tb.compareTo(ta);
    });

    return conversations;
  }

  // ── Messages ──

  /// Stream realtime messages giữa current user và [otherUserId].
  Stream<List<ChatMessageModel>> streamMessages(int otherUserId) {
    final userId = _cachedUserId;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('messages')
        .stream(primaryKey: ['m_id'])
        .order('m_sent_at', ascending: true)
        .map((rows) => rows
            .map((r) => ChatMessageModel.fromJson(Map<String, dynamic>.from(r)))
            .where((m) =>
                (m.senderId == userId && m.receiverId == otherUserId) ||
                (m.senderId == otherUserId && m.receiverId == userId))
            .toList());
  }

  /// Gửi tin nhắn.
  Future<void> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('messages').insert({
      'sender_id': userId,
      'receiver_id': receiverId,
      'm_content': content,
      'm_status': 'sent',
      'u_id': userId,
    });
  }

  /// Đánh dấu tất cả tin nhắn từ [otherUserId] là đã đọc.
  Future<void> markAsRead(int otherUserId) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    try {
      await _supabase
          .from('messages')
          .update({'m_status': 'read'})
          .eq('sender_id', otherUserId)
          .eq('receiver_id', userId)
          .neq('m_status', 'read');
    } catch (e) {
      AppLogger.error('Error marking messages as read', error: e);
    }
  }

  // ── Realtime channel subscription ──

  /// Subscribe to new messages across all conversations.
  RealtimeChannel subscribeToNewMessages({
    required void Function(ChatMessageModel message) onNewMessage,
  }) {
    final channel = _supabase.channel('messages-global');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final message = ChatMessageModel.fromJson(payload.newRecord);
              onNewMessage(message);
            } catch (e) {
              AppLogger.error('Error parsing new message', error: e);
            }
          },
        )
        .subscribe();

    return channel;
  }

  // ── Helpers ──

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
