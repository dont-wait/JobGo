import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employer_model.dart';

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
    } catch (e) {
      print('Error fetching employer: $e');
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
    } catch (e) {
      print('Error updating employer profile: $e');
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
    } catch (e) {
      print('Error uploading logo: $e');
      return null;
    }
  }
}
