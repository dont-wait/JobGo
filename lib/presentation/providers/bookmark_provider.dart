import 'package:flutter/material.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/data/repositories/job_repository.dart';
import 'dart:developer' as dev;

class BookmarkProvider extends ChangeNotifier {
  final JobRepository _jobRepository = JobRepository();

  // Lưu cả ID để check nhanh và List để hiển thị ở Profile
  final Set<String> _bookmarkedJobIds = {};
  List<JobModel> _savedJobsList = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<JobModel> get savedJobs => _savedJobsList;

  bool isBookmarked(String jobId) => _bookmarkedJobIds.contains(jobId);

  Future<void> loadInitialBookmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _savedJobsList = await _jobRepository.getSavedJobs();
      _bookmarkedJobIds.clear();
      for (var job in _savedJobsList) {
        _bookmarkedJobIds.add(job.id);
      }
      dev.log('Loaded ${_savedJobsList.length} bookmarks');
    } catch (e) {
      dev.log('Error loading initial bookmarks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(String jobId, {JobModel? fullJob}) async {
    final currentlySaved = isBookmarked(jobId);

    // Optimistic UI update
    if (currentlySaved) {
      _bookmarkedJobIds.remove(jobId);
      _savedJobsList.removeWhere((j) => j.id == jobId);
    } else {
      _bookmarkedJobIds.add(jobId);
      if (fullJob != null) {
        _savedJobsList.insert(0, fullJob);
      }
    }
    notifyListeners();

    try {
      await _jobRepository.toggleSaveJob(jobId, currentlySaved);
      // Nếu là lưu mới, nên load lại danh sách để có đầy đủ data object chuẩn từ DB
      if (!currentlySaved && fullJob == null) {
        await loadInitialBookmarks();
      }
    } catch (e) {
      dev.log('Error toggling bookmark: $e');
      loadInitialBookmarks(); // Revert bằng cách load lại từ DB cho chắc
    }
  }

  void clearBookmarks() {
    _bookmarkedJobIds.clear();
    _savedJobsList.clear();
    notifyListeners();
  }
}
