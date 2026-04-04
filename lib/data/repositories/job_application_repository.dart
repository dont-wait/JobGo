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
}
