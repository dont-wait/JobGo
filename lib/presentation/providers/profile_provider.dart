import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';

class ProfileProvider extends ChangeNotifier {
  CandidateSupabaseModel? _candidate;
  bool _isLoading = false;
  String? _error;

  CandidateSupabaseModel? get candidate => _candidate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        _error = 'Chưa đăng nhập';
        return;
      }

      final userRow = await supabase
          .from('users')
          .select('u_id')
          .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
          .maybeSingle();

      if (userRow == null) {
        _error = 'Không tìm thấy user';
        return;
      }

      final uId = userRow['u_id'] as int;

      final data = await supabase
          .from('candidates')
          .select('*, users(u_email, u_role)')
          .eq('u_id', uId)
          .maybeSingle();

      _candidate = data != null ? CandidateSupabaseModel.fromJson(data) : null;
    } catch (e) {
      _error = 'Lỗi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadProfile() async => await loadProfile();

  void clearProfile() {
    _candidate = null;
    _error = null;
    notifyListeners();
  }

  Future<void> addResume(String url) async {
    if (_candidate != null) {
      final currentResumes = _candidate!.resumes ?? [];
      // Chèn lên đầu mảng để làm default mới nhất
      final newResumes = [url, ...currentResumes];

      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('candidates')
            .update({'c_resume': newResumes})
            .eq('c_id', _candidate!.cId);

        _candidate = _candidate!.copyWith(resumes: newResumes);
        notifyListeners();
      } catch (e) {
        debugPrint('Error adding resume: $e');
      }
    }
  }

  Future<void> setDefaultResume(String url) async {
    if (_candidate != null) {
      final currentResumes = _candidate!.resumes ?? [];
      final newResumes = [url, ...currentResumes.where((e) => e != url)];

      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('candidates')
            .update({'c_resume': newResumes})
            .eq('c_id', _candidate!.cId);

        _candidate = _candidate!.copyWith(resumes: newResumes);
        notifyListeners();
      } catch (e) {
        debugPrint('Error setting default resume: $e');
      }
    }
  }

  Future<void> removeResume(String url) async {
    if (_candidate != null) {
      final currentResumes = _candidate!.resumes ?? [];
      final newResumes = currentResumes.where((e) => e != url).toList();

      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('candidates')
            .update({'c_resume': newResumes})
            .eq('c_id', _candidate!.cId);

        _candidate = _candidate!.copyWith(resumes: newResumes);
        notifyListeners();
      } catch (e) {
        debugPrint('Error removing resume: $e');
      }
    }
  }
}
