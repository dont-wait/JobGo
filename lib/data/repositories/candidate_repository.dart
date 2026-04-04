import 'dart:developer' as dev;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/candidate_supabase_model.dart';

class CandidateRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CandidateSupabaseModel>> fetchCandidates() async {
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

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
