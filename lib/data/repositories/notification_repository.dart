import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

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
}
