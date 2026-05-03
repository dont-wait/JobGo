import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employer_model.dart';
import 'package:jobgo/core/utils/app_logger.dart';

class EmployerRepository {
  final _supabase = Supabase.instance.client;

  Future<EmployerModel?> getCurrentEmployer() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final userData = await _supabase
          .from('users')
          .select('u_id')
          .eq('auth_uid', user.id)
          .single();

      final uId = userData['u_id'] as int;

      final employerData = await _supabase
          .from('employers')
          .select('*, users(u_name)')
          .eq('u_id', uId)
          .maybeSingle();

      if (employerData == null) return null;
      return EmployerModel.fromJson(employerData);
    } catch (e, st) {
      AppLogger.error('Error fetching employer', error: e, stackTrace: st);
      return null;
    }
  }

  Future<bool> updateEmployerProfile(int eId, EmployerModel employer) async {
    try {
      await _supabase
          .from('employers')
          .update(employer.toJson())
          .eq('e_id', eId);
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Error updating employer profile',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Uploads a logo file to Supabase Storage and returns the public URL.
  Future<String?> uploadLogo(File file, String fileName) async {
    try {
      final path = 'logos/$fileName';

      // 1. Upload the file
      await _supabase.storage
          .from('logos')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // 2. Get the public URL
      final String publicUrl = _supabase.storage
          .from('logos')
          .getPublicUrl(path);
      return publicUrl;
    } catch (e, st) {
      AppLogger.error('Error uploading logo', error: e, stackTrace: st);
      return null;
    }
  }

  /// Lấy thống kê nhanh cho Dashboard của nhà tuyển dụng
  Future<Map<String, int>> getDashboardStats(int employerId) async {
    try {
      // Lấy số lượng tin đang đăng (active)
      final activeJobsResponse = await _supabase
          .from('jobs')
          .select('j_id')
          .eq('e_id', employerId)
          .eq('j_status', 'active');
          
      // Lấy số lượng hồ sơ mới nhận (pending)
      // Sử dụng inner join để lọc các application thuộc về các job của employer này
      final newApplicationsResponse = await _supabase
          .from('applications')
          .select('a_id, jobs!inner(e_id)')
          .eq('jobs.e_id', employerId)
          .eq('a_status', 'pending');

      return {
        'activeJobs': (activeJobsResponse as List).length,
        'newApplications': (newApplicationsResponse as List).length,
      };
    } catch (e, st) {
      AppLogger.error('Error fetching employer dashboard stats', error: e, stackTrace: st);
      return {
        'activeJobs': 0,
        'newApplications': 0,
      };
    }
  }
}
