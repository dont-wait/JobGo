import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/core/utils/app_logger.dart';
import 'package:jobgo/data/models/notification_model.dart';
import 'package:jobgo/data/repositories/notification_repository.dart';

/// Provider quản lý state thông báo realtime.
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Realtime
  RealtimeChannel? _notifChannel;
  StreamSubscription? _streamSub;
  int? _userId;

  // ── Getters ──

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // ── Init & Dispose ──

  /// Gọi sau khi user đăng nhập thành công.
  Future<void> initRealtimeSubscriptions() async {
    if (_notifChannel != null) {
      await loadNotifications();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load notifications ban đầu
      await loadNotifications();

      // Lấy userId để subscribe
      if (_notifications.isNotEmpty) {
        _userId = _notifications.first.userId;
      } else {
        // Fetch userId riêng nếu chưa có notifications
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser != null) {
          final row = await Supabase.instance.client
              .from('users')
              .select('u_id')
              .eq('auth_uid', authUser.id)
              .maybeSingle();
          _userId = _toInt(row?['u_id']);
        }
      }

      if (_userId != null) {
        _notifChannel = _repository.subscribeToNewNotifications(
          userId: _userId!,
          onNewNotification: _handleNewNotification,
        );
      }

      AppLogger.info('Notification realtime subscriptions initialized');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error(
        'Error initializing notification realtime',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load/refresh notifications.
  Future<void> loadNotifications() async {
    try {
      _notifications = await _repository.fetchNotificationsForCurrentUser();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Error loading notifications', error: e, stackTrace: st);
      notifyListeners();
    }
  }

  /// Đánh dấu 1 notification đã đọc.
  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Tạo bản sao với status 'read'
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          type: old.type,
          content: old.content,
          status: 'read',
          createdAt: old.createdAt,
          userId: old.userId,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error marking notification as read', error: e);
    }
  }

  /// Đánh dấu tất cả đã đọc.
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          type: n.type,
          content: n.content,
          status: 'read',
          createdAt: n.createdAt,
          userId: n.userId,
        );
      }).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error marking all notifications as read', error: e);
    }
  }

  /// Cleanup khi sign out.
  void clearNotifications() {
    _notifChannel?.unsubscribe();
    _streamSub?.cancel();
    _notifChannel = null;
    _streamSub = null;
    _notifications = [];
    _unreadCount = 0;
    _error = null;
    _userId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _notifChannel?.unsubscribe();
    _streamSub?.cancel();
    super.dispose();
  }

  // ── Private ──

  void _handleNewNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) _unreadCount++;
    notifyListeners();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
