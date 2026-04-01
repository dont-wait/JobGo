import 'dart:developer' as dev;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/candidate_supabase_model.dart';

class CandidateRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int?> getCandidateIdByAuthUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    final userRow = await _supabase
        .from('users')
        .select('u_id')
        .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
        .maybeSingle();

    if (userRow == null) return null;
    final uId = userRow['u_id'] as int;

    final candidateRow = await _supabase
        .from('candidates')
        .select('c_id')
        .eq('u_id', uId)
        .maybeSingle();

    return candidateRow?['c_id'] as int?;
  }

   Future<List<Map<String, dynamic>>> loadCandidateSchedules(int cId) async {
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
          candidates (c_full_name),
          jobs (j_title)
        ''')
        .eq('c_id', cId)
        .order('i_interview_date');

    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<CandidateSupabaseModel>> fetchCandidates() async {
    try {
      final response = await _supabase
          .from('candidates')
          .select('*, users(u_email, u_role, u_name, u_phone)')
          .order('c_updated_at', ascending: false);

      final rows = response as List<dynamic>;
      return rows
          .map(
            (row) => CandidateSupabaseModel.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();
    } catch (e) {
      dev.log('Error fetching candidates: $e');
      return [];
    }
  }

  Future<CandidateSupabaseModel?> fetchCandidateById(int candidateId) async {
    try {
      final response = await _supabase
          .from('candidates')
          .select('*, users(u_email, u_role, u_name, u_phone)')
          .eq('c_id', candidateId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return CandidateSupabaseModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      dev.log('Error fetching candidate by id: $e');
      return null;
    }
  }

  Future<CandidateSupabaseModel?> getCurrentCandidate() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;

      final userRow = await _supabase
          .from('users')
          .select('u_id')
          .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
          .maybeSingle();

      final userId = _toInt(userRow?['u_id']);
      if (userId == null) return null;

      final candidateRow = await _supabase
          .from('candidates')
          .select('*, users(u_email, u_role, u_name, u_phone)')
          .eq('u_id', userId)
          .maybeSingle();

      if (candidateRow == null) return null;

      return CandidateSupabaseModel.fromJson(
        Map<String, dynamic>.from(candidateRow as Map),
      );
    } catch (e) {
      dev.log('Error fetching current candidate: $e');
      return null;
    }
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

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
