import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/data/repositories/job_application_repository.dart';

class ApplicationProvider extends ChangeNotifier {
  final _repository = JobApplicationRepository();

  List<JobApplicantModel> _applications = [];
  final Set<int> _appliedJobIds = {};
  bool _isLoading = false;
  String? _error;

  // Realtime
  RealtimeChannel? _appChannel;
  int? _subscribedCandidateId;

  List<JobApplicantModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isApplied(int jobId) => _appliedJobIds.contains(jobId);

  Future<void> fetchMyApplications(int candidateId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await _repository.fetchCandidateApplications(candidateId);
      _appliedJobIds.clear();
      for (var app in _applications) {
        _appliedJobIds.add(app.jobId);
      }

      // Đăng ký realtime nếu chưa subscribe cho candidate này
      _ensureRealtimeSubscription(candidateId);
    } catch (e) {
      _error = 'Lỗi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng ký lắng nghe realtime thay đổi trên bảng applications cho candidate.
  void _ensureRealtimeSubscription(int candidateId) {
    if (_subscribedCandidateId == candidateId && _appChannel != null) return;

    // Cleanup subscription cũ nếu có
    _appChannel?.unsubscribe();

    _subscribedCandidateId = candidateId;
    _appChannel = _repository.subscribeToApplicationChanges(
      candidateId: candidateId,
      onChanged: () => _handleRealtimeChange(candidateId),
    );
  }

  /// Khi có thay đổi realtime, refresh lại danh sách applications.
  Future<void> _handleRealtimeChange(int candidateId) async {
    try {
      _applications = await _repository.fetchCandidateApplications(candidateId);
      _appliedJobIds.clear();
      for (var app in _applications) {
        _appliedJobIds.add(app.jobId);
      }
      notifyListeners();
    } catch (e) {
      // Không set error để tránh ảnh hưởng UI, chỉ log
      debugPrint('Error refreshing applications via realtime: $e');
    }
  }

  Future<bool> applyToJob({
    required int jobId,
    required int candidateId,
    required String coverLetter,
    required String cvUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.applyJob(
        jobId: jobId,
        candidateId: candidateId,
        coverLetter: coverLetter,
        cvUrl: cvUrl,
      );

      if (success) {
        _appliedJobIds.add(jobId);
        // Refresh local history if needed
        await fetchMyApplications(candidateId);
      }
      return success;
    } catch (e) {
      _error = 'Lỗi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> withdraw(int applicationId, int candidateId) async {
    try {
      // Find the jobId to remove from cache before deleting the application record
      final appToRemove = _applications.firstWhere(
        (a) => a.applicationId == applicationId,
        orElse: () => throw Exception('Application not found'),
      );
      final jobId = appToRemove.jobId;

      final success = await _repository.withdrawApplication(applicationId);
      if (success) {
        _appliedJobIds.remove(jobId);
        _applications.removeWhere((app) => app.applicationId == applicationId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Lỗi: $e';
      return false;
    }
  }

  Future<bool> hasApplied(int jobId, int candidateId) async {
    if (_appliedJobIds.contains(jobId)) return true;
    final applied = await _repository.checkHasApplied(jobId, candidateId);
    if (applied) _appliedJobIds.add(jobId);
    return applied;
  }

  void clearApplications() {
    _appChannel?.unsubscribe();
    _appChannel = null;
    _subscribedCandidateId = null;
    _applications = [];
    _appliedJobIds.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _appChannel?.unsubscribe();
    super.dispose();
  }
}
