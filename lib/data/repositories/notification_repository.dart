import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

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
        .select('n_id, n_type, n_content, n_status, n_create_at, u_id')
        .eq('u_id', userId)
        .order('n_create_at', ascending: false);

    if (data is! List) return [];
    return data
        .map((row) => NotificationModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
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
    });
  }

  Future<int?> _getCurrentUserId() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    final userRow = await _supabase
        .from('users')
        .select('u_id')
        .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
        .maybeSingle();

    return userRow == null ? null : userRow['u_id'] as int?;
  }
}
