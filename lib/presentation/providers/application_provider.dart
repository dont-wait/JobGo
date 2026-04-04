import 'package:flutter/material.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/data/repositories/job_application_repository.dart';

class ApplicationProvider extends ChangeNotifier {
  final _repository = JobApplicationRepository();

  List<JobApplicantModel> _applications = [];
  final Set<int> _appliedJobIds = {};
  bool _isLoading = false;
  String? _error;

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
    } catch (e) {
      _error = 'Lỗi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _applications = [];
    _appliedJobIds.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
