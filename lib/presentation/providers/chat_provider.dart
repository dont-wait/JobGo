import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/core/utils/app_logger.dart';
import 'package:jobgo/data/models/conversation_model.dart';
import 'package:jobgo/data/repositories/chat_repository.dart';

/// Provider quản lý state chat realtime.
class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  String? _error;
  int _totalUnread = 0;

  // Realtime subscriptions
  RealtimeChannel? _messageChannel;

  // ── Getters ──

  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalUnread => _totalUnread;

  int? get currentUserId => _repository.cachedUserId;

  // ── Init & Dispose ──

  /// Gọi sau khi user đăng nhập thành công.
  Future<void> initRealtimeSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load conversations ban đầu
      await loadConversations();

      // Subscribe realtime new messages
      _messageChannel = _repository.subscribeToNewMessages(
        onNewMessage: _handleNewMessage,
      );

      AppLogger.info('Chat realtime subscriptions initialized');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Error initializing chat realtime', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load/refresh danh sách conversations.
  Future<void> loadConversations() async {
    try {
      _conversations = await _repository.fetchConversations();
      _calculateTotalUnread();
      notifyListeners();
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Error loading conversations', error: e, stackTrace: st);
      notifyListeners();
    }
  }

  /// Cleanup khi sign out.
  void clearChat() {
    _messageChannel?.unsubscribe();
    _messageChannel = null;
    _conversations = [];
    _totalUnread = 0;
    _error = null;
    _repository.clearCache();
    notifyListeners();
  }

  @override
  void dispose() {
    _messageChannel?.unsubscribe();
    super.dispose();
  }

  // ── Actions ──

  /// Gửi tin nhắn đến user khác.
  Future<void> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    await _repository.sendMessage(
      receiverId: receiverId,
      content: content,
    );
  }

  /// Đánh dấu đã đọc tất cả tin nhắn từ [otherUserId].
  Future<void> markAsRead(int otherUserId) async {
    await _repository.markAsRead(otherUserId);

    // Update local state
    final index = _conversations.indexWhere((c) => c.otherUserId == otherUserId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      _calculateTotalUnread();
      notifyListeners();
    }
  }

  /// Stream messages giữa current user và [otherUserId].
  Stream<List<ChatMessageModel>> streamMessages(int otherUserId) {
    return _repository.streamMessages(otherUserId);
  }

  /// Lấy userId hiện tại.
  Future<int?> getUserId() => _repository.getCurrentUserId();

  // ── Private ──

  void _handleNewMessage(ChatMessageModel message) {
    // Refresh conversations list khi có tin nhắn mới
    loadConversations();
  }

  void _calculateTotalUnread() {
    _totalUnread = _conversations.fold(0, (sum, c) => sum + c.unreadCount);
  }
}
