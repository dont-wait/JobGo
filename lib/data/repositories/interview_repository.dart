import 'package:supabase_flutter/supabase_flutter.dart';

class InterviewRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createSchedule({
    required DateTime date,
    required String type,
    required String location,
    required String contactPerson,
    required String note,
    required int cId,
    required int jId,
  }) async {
    await _supabase.from('interview_schedule').insert({
      'i_interview_date': date.toIso8601String(),
      'i_interview_type': type,
      'i_location': location,
      'i_contact_person': contactPerson,
      'i_note': note,
      'c_id': cId,
      'j_id': jId,
      'i_status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> loadSchedules() async {
    final data = await _supabase
        .from('interview_schedule')
        .select('''
          i_id,
          i_interview_date,
          i_interview_type,
          i_location,
          i_contact_person,
          i_note,
          i_status,
          i_requested_date,
          candidates (c_full_name),
          jobs (j_title)
        ''')
        .order('i_interview_date');

    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<String> getJobTitle(int jId) async {
    final jobRow = await _supabase
        .from('jobs')
        .select('j_title')
        .eq('j_id', jId)
        .maybeSingle();
    return jobRow?['j_title'] ?? 'một vị trí';
  }
}
