import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'dart:developer' as dev;

class JobRepository {
  final _supabase = Supabase.instance.client;

  Future<List<JobModel>> getRecommendedJobs() async {
    try {
      dev.log('Fetching recommended jobs with employers...');
      final response = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .limit(5);

      dev.log('Fetched ${response.length} recommended jobs');
      return (response as List).map((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      dev.log('DEBUG: Error fetching recommended jobs: $e');
      if (e is PostgrestException) {
        dev.log(
          'PostgrestException: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}',
        );
      }
      return [];
    }
  }

  Future<List<JobModel>> getRecentJobs({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      dev.log('Fetching recent jobs (Range: $from - $to) with employers...');
      final response = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .order('j_create_at', ascending: false)
          .range(from, to);

      dev.log('Fetched ${response.length} recent jobs');
      return (response as List).map((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      dev.log('DEBUG: Error fetching recent jobs: $e');
      if (e is PostgrestException) {
        dev.log(
          'PostgrestException: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}',
        );
      }
      return [];
    }
  }

  Future<List<JobModel>> searchJobs(String query) async {
    try {
      dev.log('Searching jobs with query: $query');
      final response = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .ilike('j_title', '%$query%')
          .order('j_create_at', ascending: false)
          .limit(10);

      dev.log('Found ${response.length} results');
      return (response as List).map((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      dev.log('DEBUG: Error searching jobs: $e');
      return [];
    }
  }
}
