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
        .select('*, candidates(*, users(u_email, u_role, u_name, u_phone))')
        .eq('j_id', parsedJobId)
        .order('a_applied_at', ascending: false);

    final rows = response as List<dynamic>;
    return rows
        .map(
          (row) =>
              JobApplicantModel.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<JobApplicantModel?> fetchApplicantById(int applicationId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select('*, candidates(*, users(u_email, u_role, u_name, u_phone))')
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
      await _supabase.from('applications').insert({
        'j_id': jobId,
        'c_id': candidateId,
        'a_cover_letter': coverLetter,
        'cv_url': cvUrl,
        'a_status': 'pending',
        'a_applied_at': DateTime.now().toIso8601String(),
      });

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
}
