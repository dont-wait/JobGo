import 'dart:developer' as dev;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/job_applicant_model.dart';

class JobApplicationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<JobApplicantModel>> fetchJobApplicants(String jobId) async {
    final parsedJobId = int.tryParse(jobId.trim());
    if (parsedJobId == null) return [];

    final response = await _supabase
        .from('applications')
        .select(
          '*, candidates(*, users(u_email, u_role, u_name, u_phone)), jobs(*, employers(*))',
        )
        .eq('j_id', parsedJobId)
        .order('a_applied_at', ascending: false);

    final rows = response as List<dynamic>;
    return rows
        .map(
          (row) =>
              JobApplicantModel.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .where(
          (application) => application.status != ApplicationStatus.withdrawn,
        )
        .toList();
  }

  Future<JobApplicantModel?> fetchApplicantById(int applicationId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select(
            '*, candidates(*, users(u_email, u_role, u_name, u_phone)), jobs(*, employers(*))',
          )
          .eq('a_id', applicationId)
          .maybeSingle();

      if (response == null) return null;

      return JobApplicantModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      dev.log('Error fetching applicant by id: $e');
      return null;
    }
  }

  Future<bool> applyJob({
    required int jobId,
    required int candidateId,
    required String coverLetter,
    required String cvUrl,
  }) async {
    try {
      // 1. Create application
      final insertedApplication = await _supabase
          .from('applications')
          .insert({
            'j_id': jobId,
            'c_id': candidateId,
            'a_cover_letter': coverLetter,
            'cv_url': cvUrl,
            'a_status': 'pending',
            'a_applied_at': DateTime.now().toIso8601String(),
          })
          .select('a_id')
          .maybeSingle();
      final applicationId = _toInt(insertedApplication?['a_id']);

      // 2. Increment application count in job document (optional, but requested in UC-008)
      // Note: In Supabase, we should use RPC or a trigger for consistency,
      // but here we follow the instruction literally if possible.
      // Fetch current count first
      final jobData = await _supabase
          .from('jobs')
          .select('j_application_count')
          .eq('j_id', jobId)
          .maybeSingle();
      if (jobData != null) {
        final currentCount = (jobData['j_application_count'] as int?) ?? 0;
        await _supabase
            .from('jobs')
            .update({'j_application_count': currentCount + 1})
            .eq('j_id', jobId);
      }

      // 3. Notify employer about the new applicant.
      await _notifyEmployerNewApplication(
        jobId: jobId,
        candidateId: candidateId,
        applicationId: applicationId,
      );

      return true;
    } catch (e) {
      dev.log('Error applying for job: $e');
      return false;
    }
  }

  Future<List<JobApplicantModel>> fetchCandidateApplications(
    int candidateId,
  ) async {
    try {
      // Fetch applications including job and company details
      // The current JobApplicantModel.fromJson expects candidates in 'candidates' key.
      // We might need to adjust or create a CandidateApplicationModel if the structure is different.
      // However, for UC-009, we need job details (title, company, logo).
      // Let's assume we can join jobs and employers.
      final response = await _supabase
          .from('applications')
          .select('*, jobs(*, employers(*)), candidates(*, users(*))')
          .eq('c_id', candidateId)
          .order('a_applied_at', ascending: false);

      final rows = response as List<dynamic>;
      // We'll need to update JobApplicantModel or handle the mapping here.
      // For now, let's just return the objects.
      return rows
          .map(
            (row) => JobApplicantModel.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();
    } catch (e) {
      dev.log('Error fetching candidate applications: $e');
      return [];
    }
  }

  Future<bool> checkHasApplied(int jobId, int candidateId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select('a_id')
          .eq('j_id', jobId)
          .eq('c_id', candidateId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      dev.log('Error checking application status: $e');
      return false;
    }
  }

  Future<bool> withdrawApplication(int applicationId) async {
    try {
      await _supabase.from('applications').delete().eq('a_id', applicationId);
      return true;
    } catch (e) {
      dev.log('Error withdrawing application: $e');
      return false;
    }
  }

  Future<bool> rejectApplication(int applicationId) async {
    try {
      await _supabase
          .from('applications')
          .update({'a_status': 'rejected'})
          .eq('a_id', applicationId);
      return true;
    } catch (e) {
      dev.log('Error rejecting application: $e');
      return false;
    }
  }

  Future<bool> shortlistApplication(int applicationId) async {
    try {
      await _supabase
          .from('applications')
          .update({'a_status': 'shortlisted'})
          .eq('a_id', applicationId);
      return true;
    } catch (e) {
      dev.log('Error shortlisting application: $e');
      return false;
    }
  }

  Future<void> _notifyEmployerNewApplication({
    required int jobId,
    required int candidateId,
    int? applicationId,
  }) async {
    try {
      final jobRow = await _supabase
          .from('jobs')
          .select('j_title, employers(u_id)')
          .eq('j_id', jobId)
          .maybeSingle();

      final employerUserId = _extractNestedInt(jobRow?['employers'], 'u_id');
      if (employerUserId == null) return;

      final candidateRow = await _supabase
          .from('candidates')
          .select('c_full_name, users(u_name)')
          .eq('c_id', candidateId)
          .maybeSingle();

      final candidateName = _extractCandidateName(candidateRow, candidateId);
      final jobTitle = _safeString(
        jobRow?['j_title'],
        fallback: 'vị trí tuyển dụng',
      );

      await _supabase.from('notifications').insert({
        'n_type': 'application',
        'n_content': '$candidateName vừa ứng tuyển vào vị trí $jobTitle',
        'n_status': 'unread',
        'u_id': employerUserId,
        'related_id': applicationId ?? jobId,
        'related_type': 'application',
      });
    } catch (e) {
      dev.log('Error creating employer application notification: $e');
    }
  }

  /// Subscribe to realtime changes on applications for a specific candidate.
  /// Listens for INSERT, UPDATE, DELETE events.
  RealtimeChannel subscribeToApplicationChanges({
    required int candidateId,
    required void Function() onChanged,
  }) {
    final channel = _supabase.channel('applications-c$candidateId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'applications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'c_id',
            value: candidateId,
          ),
          callback: (payload) {
            dev.log('Application realtime event: ${payload.eventType}');
            onChanged();
          },
        )
        .subscribe();

    return channel;
  }

  String _extractCandidateName(dynamic candidateRow, int candidateId) {
    final map = _asMap(candidateRow);
    if (map == null) return 'Ứng viên #$candidateId';

    final fullName = _safeString(map['c_full_name']);
    if (fullName.isNotEmpty) return fullName;

    final usersRaw = map['users'];
    final usersMap = usersRaw is List && usersRaw.isNotEmpty
        ? _asMap(usersRaw.first)
        : _asMap(usersRaw);
    final userName = _safeString(usersMap?['u_name']);
    if (userName.isNotEmpty) return userName;

    return 'Ứng viên #$candidateId';
  }

  int? _extractNestedInt(dynamic value, String key) {
    final nested = value is List && value.isNotEmpty ? value.first : value;
    final map = _asMap(nested);
    if (map == null) return null;
    return _toInt(map[key]);
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String _safeString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return fallback;
    return str;
  }
}
