import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/employer_job_model.dart';

class EmployerJobRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> _requireEmployerId() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      throw StateError('Bạn cần đăng nhập để quản lý tin tuyển dụng.');
    }

    final userRow = await _supabase
        .from('users')
        .select('u_id')
        .eq('auth_uid', authUser.id)
        .maybeSingle();

    final userId = _toInt(userRow?['u_id']);
    if (userId == null) {
      throw StateError(
        'Không tìm thấy tài khoản nội bộ cho người dùng hiện tại.',
      );
    }

    final employerRow = await _supabase
        .from('employers')
        .select('e_id')
        .eq('u_id', userId)
        .maybeSingle();

    final employerId = _toInt(employerRow?['e_id']);
    if (employerId == null) {
      throw StateError('Tài khoản hiện tại chưa có hồ sơ doanh nghiệp.');
    }

    return employerId;
  }

  Future<List<EmployerJobModel>> fetchMyJobs() async {
    final employerId = await _requireEmployerId();

    final response = await _supabase
        .from('jobs')
        .select('*, employers(*)')
        .eq('e_id', employerId)
        .order('j_update_at', ascending: false);

    final rows = response as List<dynamic>;
    return rows
        .map(
          (row) =>
              EmployerJobModel.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<EmployerJobModel?> fetchJobById(int jobId) async {
    final employerId = await _requireEmployerId();

    final response = await _supabase
        .from('jobs')
        .select('*, employers(*)')
        .eq('j_id', jobId)
        .eq('e_id', employerId)
        .maybeSingle();

    if (response == null) return null;
    return EmployerJobModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<EmployerJobModel> saveJob(
    EmployerJobModel job, {
    required bool publish,
  }) async {
    final employerId = await _requireEmployerId();
    final persistedJob = job.copyWith(
      status: publish ? 'active' : 'draft',
      moderationStatus: publish ? 'pending' : 'draft',
      createdAt: job.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      employerId: job.employerId ?? employerId,
    );

    if (persistedJob.id == null) {
      final response = await _supabase
          .from('jobs')
          .insert(persistedJob.toSupabasePayload(employerId: employerId))
          .select('*, employers(*)')
          .single();

      return EmployerJobModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    }

    final response = await _supabase
        .from('jobs')
        .update(persistedJob.toUpdatePayload())
        .eq('j_id', persistedJob.id!)
        .eq('e_id', employerId)
        .select('*, employers(*)')
        .single();

    return EmployerJobModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<EmployerJobModel> reopenJob(int jobId) async {
    final employerId = await _requireEmployerId();

    final response = await _supabase
        .from('jobs')
        .update({
          'j_status': 'active',
          'j_moderation_status': 'pending',
          'j_update_at': DateTime.now().toIso8601String(),
        })
        .eq('j_id', jobId)
        .eq('e_id', employerId)
        .select('*, employers(*)')
        .single();

    return EmployerJobModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<void> deleteJob(int jobId) async {
    final employerId = await _requireEmployerId();
    await _supabase
        .from('jobs')
        .delete()
        .eq('j_id', jobId)
        .eq('e_id', employerId);
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
