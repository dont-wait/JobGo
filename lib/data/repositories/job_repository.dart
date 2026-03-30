import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'dart:developer' as dev;

class JobRepository {
  final _supabase = Supabase.instance.client;

  Future<List<JobModel>> getRecommendedJobs() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // 1. Fetch recommended jobs - Luôn ưu tiên lấy được jobs trước
      final jobsResponse = await _supabase
          .from('jobs')
          .select('''
            *,
            employers(*)
          ''')
          .limit(5);

      // 2. Fetch bookmarks an toàn
      Set<dynamic> savedJobIds = {};
      if (userId != null) {
        try {
          final savedResponse = await _supabase
              .from('saved_jobs')
              .select('j_id')
              .eq('u_id', userId);
          savedJobIds = (savedResponse as List).map((s) => s['j_id']).toSet();
        } catch (e) {
          dev.log('DEBUG: Error fetching bookmark IDs: $e');
        }
      }

      return (jobsResponse as List).map((json) {
        final isBookmarked = savedJobIds.contains(json['j_id']);
        return JobModel.fromJson({...json, 'j_is_bookmarked': isBookmarked});
      }).toList();
    } catch (e) {
      dev.log('DEBUG: CRITICAL Error in getRecommendedJobs: $e');
      return [];
    }
  }

  Future<List<JobModel>> getRecentJobs({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final from = page * pageSize;
      final to = from + pageSize - 1;

      // 1. Fetch recent jobs
      final jobsResponse = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .order('j_create_at', ascending: false)
          .range(from, to);

      // 2. Fetch bookmarks an toàn
      Set<dynamic> savedJobIds = {};
      if (userId != null) {
        try {
          final savedResponse = await _supabase
              .from('saved_jobs')
              .select('j_id')
              .eq('u_id', userId);
          savedJobIds = (savedResponse as List).map((s) => s['j_id']).toSet();
        } catch (e) {
          dev.log('DEBUG: Error fetching bookmark IDs: $e');
        }
      }

      return (jobsResponse as List).map((json) {
        final isBookmarked = savedJobIds.contains(json['j_id']);
        return JobModel.fromJson({...json, 'j_is_bookmarked': isBookmarked});
      }).toList();
    } catch (e) {
      dev.log('DEBUG: CRITICAL Error in getRecentJobs: $e');
      return [];
    }
  }

  Future<void> toggleSaveJob(String jobId, bool isCurrentlySaved) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Ép kiểu ID về int nếu cần thiết cho Supabase
      dynamic targetJobId = jobId;
      if (int.tryParse(jobId) != null) {
        targetJobId = int.parse(jobId);
      }

      if (isCurrentlySaved) {
        await _supabase.from('saved_jobs').delete().match({
          'u_id': user.id,
          'j_id': targetJobId,
        });
        dev.log('Unsaved job $jobId');
      } else {
        await _supabase.from('saved_jobs').insert({
          'u_id': user.id,
          'j_id': targetJobId,
          's_save_at': DateTime.now().toIso8601String(),
        });
        dev.log('Saved job $jobId');
      }
    } catch (e) {
      dev.log('Error toggling save job: $e');
    }
  }

  Future<List<JobModel>> searchJobs(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final jobsResponse = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .ilike('j_title', '%$query%')
          .order('j_create_at', ascending: false)
          .limit(10);

      Set<dynamic> savedJobIds = {};
      if (userId != null) {
        try {
          final savedResponse = await _supabase
              .from('saved_jobs')
              .select('j_id')
              .eq('u_id', userId);
          savedJobIds = (savedResponse as List).map((s) => s['j_id']).toSet();
        } catch (e) {
          dev.log('DEBUG: Error fetching bookmark IDs: $e');
        }
      }

      return (jobsResponse as List).map((json) {
        final isBookmarked = savedJobIds.contains(json['j_id']);
        return JobModel.fromJson({...json, 'j_is_bookmarked': isBookmarked});
      }).toList();
    } catch (e) {
      dev.log('DEBUG: Error searching jobs: $e');
      return [];
    }
  }

  Future<List<JobModel>> getSavedJobs() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Dùng inner join để lọc ra đúng những việc đã lưu
      final response = await _supabase
          .from('jobs')
          .select('*, employers(*), saved_jobs!inner(*)')
          .eq('saved_jobs.u_id', userId);

      return (response as List).map((json) {
        return JobModel.fromJson({...json, 'j_is_bookmarked': true});
      }).toList();
    } catch (e) {
      dev.log('DEBUG: Error fetching saved jobs: $e');
      return [];
    }
  }
}
