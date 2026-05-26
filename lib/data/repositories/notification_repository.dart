import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/notification_model.dart';
import 'package:jobgo/core/utils/app_logger.dart';

class NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Fetch (REST) ──

  Future<List<NotificationModel>> fetchNotificationsForCurrentUser() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return [];
    return fetchNotificationsForUser(userId: userId);
  }

  Future<List<NotificationModel>> fetchNotificationsForUser({
    required int userId,
  }) async {
    final data = await _supabase
        .from('notifications')
        .select('n_id, n_type, n_content, n_status, n_create_at, u_id, related_id, related_type')
        .eq('u_id', userId)
        .order('n_create_at', ascending: false);

    return data
        .map((row) => NotificationModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  // ── Realtime Stream ──

  /// Stream realtime notifications cho current user.
  Stream<List<NotificationModel>> streamNotifications(int userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['n_id'])
        .eq('u_id', userId)
        .order('n_create_at', ascending: false)
        .map((rows) => rows
            .map((r) => NotificationModel.fromJson(Map<String, dynamic>.from(r)))
            .toList());
  }

  /// Subscribe to new notifications via Postgres Changes.
  RealtimeChannel subscribeToNewNotifications({
    required int userId,
    required void Function(NotificationModel notification) onNewNotification,
  }) {
    final channel = _supabase.channel('notifications-$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'u_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final notification =
                  NotificationModel.fromJson(payload.newRecord);
              onNewNotification(notification);
            } catch (e) {
              AppLogger.error('Error parsing notification', error: e);
            }
          },
        )
        .subscribe();

    return channel;
  }

  // ── Mutations ──

  Future<void> markAsRead(int notificationId) async {
    await _supabase
        .from('notifications')
        .update({'n_status': 'read'})
        .eq('n_id', notificationId);
  }

  Future<void> markAllAsRead() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;

    await _supabase
        .from('notifications')
        .update({'n_status': 'read'})
        .eq('u_id', userId)
        .eq('n_status', 'unread');
  }

  Future<int> getUnreadCount() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return 0;

    final data = await _supabase
        .from('notifications')
        .select('n_id')
        .eq('u_id', userId)
        .eq('n_status', 'unread');

    return (data as List).length;
  }

  Future<void> sendInterviewNotification({
    required int candidateId,
    required String jobTitle,
  }) async {
    final candidateRow = await _supabase
        .from('candidates')
        .select('u_id')
        .eq('c_id', candidateId)
        .maybeSingle();

    if (candidateRow == null) return;
    final uId = candidateRow['u_id'] as int;

    await _supabase.from('notifications').insert({
      'n_type': 'interview',
      'n_content': 'Bạn có lịch phỏng vấn mới cho vị trí $jobTitle',
      'n_status': 'unread',
      'u_id': uId,
      'related_type': 'interview',
    });
  }

  // ── Helpers ──

  Future<int?> _getCurrentUserId() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    final userRow = await _supabase
        .from('users')
        .select('u_id')
        .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
        .maybeSingle();

    if (userRow == null) return null;

    final rawUserId = userRow['u_id'];
    if (rawUserId is int) return rawUserId;
    if (rawUserId is num) return rawUserId.toInt();
    if (rawUserId is String) return int.tryParse(rawUserId);
    return null;
  }
}
