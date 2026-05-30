import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/employer_job_model.dart';

class EmployerJobRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const int _maxTitleLength = 120;
  static const int _maxLocationLength = 120;
  static const int _maxPositions = 1000;

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
    final jobs = rows
        .map(
          (row) =>
              EmployerJobModel.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();

    return _attachRealApplicationCounts(jobs);
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
    return _withRealApplicationCount(
      EmployerJobModel.fromJson(Map<String, dynamic>.from(response as Map)),
    );
  }

  Future<EmployerJobModel> saveJob(
    EmployerJobModel job, {
    required bool publish,
  }) async {
    _validateJobBeforeSave(job, publish: publish);

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

      return _withRealApplicationCount(
        EmployerJobModel.fromJson(Map<String, dynamic>.from(response as Map)),
      );
    }

    final response = await _supabase
        .from('jobs')
        .update(persistedJob.toUpdatePayload())
        .eq('j_id', persistedJob.id!)
        .eq('e_id', employerId)
        .select('*, employers(*)')
        .single();

    return _withRealApplicationCount(
      EmployerJobModel.fromJson(Map<String, dynamic>.from(response as Map)),
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

    return _withRealApplicationCount(
      EmployerJobModel.fromJson(Map<String, dynamic>.from(response as Map)),
    );
  }

  Future<EmployerJobModel> closeJob(int jobId) async {
    final employerId = await _requireEmployerId();

    final response = await _supabase
        .from('jobs')
        .update({
          'j_status': 'closed',
          'j_update_at': DateTime.now().toIso8601String(),
        })
        .eq('j_id', jobId)
        .eq('e_id', employerId)
        .select('*, employers(*)')
        .single();

    return _withRealApplicationCount(
      EmployerJobModel.fromJson(Map<String, dynamic>.from(response as Map)),
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

  Future<List<EmployerJobModel>> _attachRealApplicationCounts(
    List<EmployerJobModel> jobs,
  ) async {
    final jobIds = jobs.map((job) => job.id).whereType<int>().toList();
    if (jobIds.isEmpty) {
      return jobs;
    }

    final countsByJobId = await _fetchApplicationCounts(jobIds);
    return jobs
        .map(
          (job) => job.copyWith(applicationCount: countsByJobId[job.id] ?? 0),
        )
        .toList();
  }

  Future<Map<int, int>> _fetchApplicationCounts(List<int> jobIds) async {
    final response = await _supabase
        .from('applications')
        .select('j_id')
        .inFilter('j_id', jobIds);

    final countsByJobId = <int, int>{};
    for (final row in response as List<dynamic>) {
      final jobId = _toInt((row as Map)['j_id']);
      if (jobId == null) continue;
      countsByJobId[jobId] = (countsByJobId[jobId] ?? 0) + 1;
    }

    return countsByJobId;
  }

  Future<int> _fetchApplicationCount(int jobId) async {
    final countsByJobId = await _fetchApplicationCounts([jobId]);
    return countsByJobId[jobId] ?? 0;
  }

  Future<EmployerJobModel> _withRealApplicationCount(
    EmployerJobModel job,
  ) async {
    final jobId = job.id;
    if (jobId == null) {
      return job;
    }

    final realCount = await _fetchApplicationCount(jobId);
    return job.copyWith(applicationCount: realCount);
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  void _validateJobBeforeSave(EmployerJobModel job, {required bool publish}) {
    final title = job.title.trim();
    if (title.isEmpty) {
      throw StateError('Job title is required.');
    }
    if (title.length > _maxTitleLength) {
      throw StateError('Job title cannot exceed $_maxTitleLength characters.');
    }

    final location = job.location.trim();
    if (location.length > _maxLocationLength) {
      throw StateError(
        'Location cannot exceed $_maxLocationLength characters.',
      );
    }

    if (job.positions <= 0) {
      throw StateError('Open positions must be greater than 0.');
    }
    if (job.positions > _maxPositions) {
      throw StateError('Open positions cannot exceed $_maxPositions.');
    }

    final minSalary = job.salaryMin;
    final maxSalary = job.salaryMax;
    if (minSalary != null && minSalary <= 0) {
      throw StateError('Minimum salary must be greater than 0.');
    }
    if (maxSalary != null && maxSalary <= 0) {
      throw StateError('Maximum salary must be greater than 0.');
    }
    if (minSalary != null && maxSalary != null && minSalary > maxSalary) {
      throw StateError('Minimum salary cannot be greater than maximum salary.');
    }

    if (job.deadline != null && _isPastDate(job.deadline!)) {
      throw StateError('Application deadline cannot be in the past.');
    }

    if (!publish) {
      return;
    }

    if (job.category.trim().isEmpty) {
      throw StateError('Please choose a category.');
    }
    if (location.isEmpty) {
      throw StateError('Location is required.');
    }
    if (job.description.trim().isEmpty) {
      throw StateError('Job description is required.');
    }
    if (job.requirementsText.trim().isEmpty) {
      throw StateError('Job requirements are required.');
    }
    if (job.employmentType.trim().isEmpty) {
      throw StateError('Employment type is required.');
    }
    if (job.deadline == null) {
      throw StateError('Please choose an application deadline.');
    }
    if (minSalary == null && maxSalary == null) {
      throw StateError('Please add a salary range.');
    }

    final hasSkill = job.tags.any((item) => item.trim().isNotEmpty);
    if (!hasSkill) {
      throw StateError('Please choose at least one skill.');
    }

    final hasBenefit = job.benefits.any((item) => item.trim().isNotEmpty);
    if (!hasBenefit) {
      throw StateError('Please choose at least one benefit.');
    }
  }

  bool _isPastDate(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(value.year, value.month, value.day);
    return selected.isBefore(today);
  }
}
