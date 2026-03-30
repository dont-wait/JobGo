import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employer_model.dart';

class EmployerRepository {
  final _supabase = Supabase.instance.client;

  Future<EmployerModel?> getCurrentEmployer() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      // 1. Get internal u_id from users table
      final userData = await _supabase
          .from('users')
          .select('u_id')
          .eq('auth_uid', user.id)
          .single();

      final uId = userData['u_id'] as int;

      // 2. Get employer data with a JOIN to users table to get the recruiter name (u_name)
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
}
