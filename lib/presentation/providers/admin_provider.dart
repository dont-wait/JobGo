import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:jobgo/data/models/admin_user_model.dart';
import 'package:jobgo/data/models/job_moderation_model.dart';
import 'package:jobgo/data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  List<AdminUserModel> _users = [];
  bool _isLoadingUsers = false;
  String _selectedUserFilter = 'Candidates';
  int _currentUserPage = 0;
  final int _userPageSize = 20;
  String _userSearchQuery = '';
  String? _userLoadError;

  List<AdminUserModel> get users => _filteredUsers;
  bool get isLoadingUsers => _isLoadingUsers;
  String get selectedUserFilter => _selectedUserFilter;
  String get userSearchQuery => _userSearchQuery;
  String? get userLoadError => _userLoadError;

  List<AdminUserModel> _deletedUsers = [];
  bool _isLoadingDeleted = false;
  List<AdminUserModel> get deletedUsers => _deletedUsers;
  bool get isLoadingDeleted => _isLoadingDeleted;

  List<AdminUserModel> get _filteredUsers {
    var filtered = _users;

    if (_selectedUserFilter == 'Candidates') {
      filtered = filtered.where((u) => u.role == 'candidate').toList();
    } else if (_selectedUserFilter == 'Employers') {
      filtered = filtered.where((u) => u.role == 'employer').toList();
    }

    if (_userSearchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (u) =>
                u.name.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
                u.email.toLowerCase().contains(_userSearchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  List<JobModerationItem> _jobs = [];
  bool _isLoadingJobs = false;
  String _selectedJobFilter = 'Pending';
  int _currentJobPage = 0;
  final int _jobPageSize = 20;

  List<JobModerationItem> get jobs => _filteredJobs;
  bool get isLoadingJobs => _isLoadingJobs;
  String get selectedJobFilter => _selectedJobFilter;

  List<JobModerationItem> get _filteredJobs {
    return _jobs.where((j) {
      if (_selectedJobFilter == 'Pending') return j.status == 'pending';
      if (_selectedJobFilter == 'Approved') return j.status == 'approved';
      if (_selectedJobFilter == 'Rejected') return j.status == 'rejected';
      if (_selectedJobFilter == 'Expired') return j.status == 'expired' || j.status == 'closed';
      return true;
    }).toList();
  }

  bool _isLoadingStats = false;
  int _totalUsers = 0;
  int _pendingJobs = 0;
  int _activeJobs = 0;
  int _totalEmployers = 0;

  bool get isLoadingStats => _isLoadingStats;
  int get totalUsers => _totalUsers;
  int get pendingJobs => _pendingJobs;
  int get activeJobs => _activeJobs;
  int get totalEmployers => _totalEmployers;

  List<Map<String, dynamic>> _supportTickets = [];
  bool _isLoadingTickets = false;
  int _unresolvedTicketsCount = 0;
  String _selectedSupportFilter = 'all';

  List<Map<String, dynamic>> get supportTickets => _filteredSupportTickets;
  bool get isLoadingTickets => _isLoadingTickets;
  int get unresolvedTicketsCount => _unresolvedTicketsCount;
  String get selectedSupportFilter => _selectedSupportFilter;

  List<Map<String, dynamic>> get _filteredSupportTickets {
    if (_selectedSupportFilter == 'all') return _supportTickets;
    return _supportTickets
        .where(
          (t) =>
              (t['status']?.toString().toLowerCase() ?? '') ==
              _selectedSupportFilter,
        )
        .toList();
  }

  Future<void> loadUsers({String? roleFilter}) async {
    _isLoadingUsers = true;
    _userLoadError = null;

    try {
      _currentUserPage = 0;
      _users = await _repository.getAllUsers(
        page: _currentUserPage,
        pageSize: _userPageSize,
        roleFilter: roleFilter,
      );
    } catch (e) {
      dev.log('Error loading users: $e');
      _userLoadError = e.toString();
    }

    _isLoadingUsers = false;
    notifyListeners();
  }

  Future<void> loadMoreUsers() async {
    if (_isLoadingUsers) return;

    _isLoadingUsers = true;
    notifyListeners();

    try {
      _currentUserPage++;
      final roleFilter = _selectedUserFilter == 'Candidates'
          ? 'candidate'
          : _selectedUserFilter == 'Employers'
          ? 'employer'
          : null;
      final moreUsers = await _repository.getAllUsers(
        page: _currentUserPage,
        pageSize: _userPageSize,
        roleFilter: roleFilter,
      );
      if (moreUsers.isNotEmpty) {
        _users.addAll(moreUsers);
      }
    } catch (e) {
      _currentUserPage--;
      dev.log('Error loading more users: $e');
      _userLoadError = e.toString();
    }

    _isLoadingUsers = false;
    notifyListeners();
  }

  Future<bool> blockUser(String userId, String reason) async {
    final ok = await _repository.blockUser(userId, reason);
    if (ok) {
      final roleFilter = _selectedUserFilter == 'Candidates'
          ? 'candidate'
          : _selectedUserFilter == 'Employers'
          ? 'employer'
          : null;
      await loadUsers(roleFilter: roleFilter);
      return true;
    }

    return false;
  }

  Future<bool> unblockUser(String userId) async {
    final ok = await _repository.unblockUser(userId);
    if (ok) {
      final roleFilter = _selectedUserFilter == 'Candidates'
          ? 'candidate'
          : _selectedUserFilter == 'Employers'
          ? 'employer'
          : null;
      await loadUsers(roleFilter: roleFilter);
      return true;
    }

    return false;
  }

  Future<bool> deleteUser(String userId) async {
    final ok = await _repository.deleteUser(userId);
    if (ok) {
      final roleFilter = _selectedUserFilter == 'Candidates'
          ? 'candidate'
          : _selectedUserFilter == 'Employers'
          ? 'employer'
          : null;
      await loadUsers(roleFilter: roleFilter);
      return true;
    }

    return false;
  }

  Future<void> loadDeletedUsers() async {
    _isLoadingDeleted = true;
    notifyListeners();

    try {
      _deletedUsers = await _repository.getDeletedUsers(page: 0, pageSize: 100);
    } catch (e) {
      dev.log('Error loading deleted users: $e');
    }

    _isLoadingDeleted = false;
    notifyListeners();
  }

  Future<bool> restoreUser(String userId) async {
    final ok = await _repository.restoreUser(userId);
    if (ok) {
      _deletedUsers.removeWhere((u) => u.id == userId);
      final roleFilter = _selectedUserFilter == 'Candidates' ? 'candidate' : _selectedUserFilter == 'Employers' ? 'employer' : null;
      await loadUsers(roleFilter: roleFilter); // Tải lại danh sách chính
      return true;
    }
    return false;
  }

  Future<bool> hardDeleteUser(String userId) async {
    final ok = await _repository.hardDeleteUser(userId);
    if (ok) {
      _deletedUsers.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    }
    return false;
  }

  void setUserFilter(String filter) {
    _selectedUserFilter = filter;
    notifyListeners();
  }

  void setUserSearchQuery(String query) {
    _userSearchQuery = query;
    notifyListeners();
  }

  Future<void> loadPendingJobs() async {
    _isLoadingJobs = true;
    _selectedJobFilter = 'Pending';

    try {
      _currentJobPage = 0;
      _jobs = await _repository.getPendingJobs(
        page: _currentJobPage,
        pageSize: _jobPageSize,
      );
    } catch (e) {
      dev.log('Error loading pending jobs: $e');
    }

    _isLoadingJobs = false;
    notifyListeners();
  }

  Future<void> loadModeratedJobs({String? status}) async {
    _isLoadingJobs = true;

    try {
      _currentJobPage = 0;
      _jobs = await _repository.getModeratedJobs(
        page: _currentJobPage,
        pageSize: _jobPageSize,
        status: status,
      );
    } catch (e) {
      dev.log('Error loading moderated jobs: $e');
    }

    _isLoadingJobs = false;
    notifyListeners();
  }

  Future<bool> approveJob(String jobId) async {
    final success = await _repository.approveJob(jobId);
    if (success) {
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = _jobs[index].copyWith(status: 'approved');
      }
      notifyListeners();
    }
    return success;
  }

  Future<bool> rejectJob(
    String jobId,
    List<String> reasons,
    String? note,
  ) async {
    final success = await _repository.rejectJob(jobId, reasons, note);
    if (success) {
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = _jobs[index].copyWith(
          status: 'rejected',
          rejectionReasons: reasons,
        );
      }
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteJob(String jobId) async {
    final success = await _repository.deleteJob(jobId);
    if (success) {
      if (_selectedJobFilter == 'Pending') {
        await loadPendingJobs();
      } else {
        await loadModeratedJobs(status: _selectedJobFilter.toLowerCase());
      }
      return true;
    }

    return false;
  }

  void setJobFilter(String filter) {
    _selectedJobFilter = filter;
    notifyListeners();
  }

  Future<void> loadDashboardStats() async {
    _isLoadingStats = true;

    try {
      final stats = await _repository.getDashboardStats();
      _totalUsers = stats['totalUsers'] ?? 0;
      _pendingJobs = stats['pendingJobs'] ?? 0;
      _activeJobs = stats['activeJobs'] ?? 0;
      _totalEmployers = stats['totalEmployers'] ?? 0;
    } catch (e) {
      dev.log('Error loading dashboard stats: $e');
    }

    _isLoadingStats = false;
    notifyListeners();
  }

  Future<void> loadSupportTickets({String? status}) async {
    _isLoadingTickets = true;

    try {
      _supportTickets = await _repository.getReportedIssues(status: status);
      _unresolvedTicketsCount = await _repository.getUnresolvedTicketsCount();
    } catch (e) {
      dev.log('Error loading support tickets: $e');
    }

    _isLoadingTickets = false;
    notifyListeners();
  }

  void setSupportFilter(String filter) {
    _selectedSupportFilter = filter;
    notifyListeners();
  }

  Future<bool> resolveTicket(String ticketId, String resolution) async {
    final success = await _repository.resolveTicket(ticketId, resolution);
    if (success) {
      final index = _supportTickets.indexWhere((t) => t['id'] == ticketId);
      if (index != -1) {
        _supportTickets[index]['status'] = 'resolved';
        _supportTickets[index]['adminNote'] = resolution;
      }
      _unresolvedTicketsCount = await _repository.getUnresolvedTicketsCount();
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateSupportTicketStatus({
    required String ticketId,
    required String status,
    String? adminNote,
    String? priority,
  }) async {
    final success = await _repository.updateSupportIssueStatus(
      ticketId: ticketId,
      status: status,
      adminNote: adminNote,
      priority: priority,
    );

    if (success) {
      final index = _supportTickets.indexWhere((t) => t['id'] == ticketId);
      if (index != -1) {
        _supportTickets[index]['status'] = status;
        if (adminNote != null) _supportTickets[index]['adminNote'] = adminNote;
        if (priority != null) _supportTickets[index]['priority'] = priority;
      }
      _unresolvedTicketsCount = await _repository.getUnresolvedTicketsCount();
      notifyListeners();
    }

    return success;
  }

  /// Debug method to test database connection
  Future<void> debugTestDatabase() async {
    dev.log('=== AdminProvider: Testing database connection ===');
    try {
      final result = await _repository.debugDatabaseSchema();
      dev.log('Database debug result: $result');
      _userLoadError = result['status'] == 'success' ? null : result['message'].toString();
      notifyListeners();
    } catch (e) {
      dev.log('Error during debug: $e');
      _userLoadError = 'Debug failed: $e';
      notifyListeners();
    }
  }

  Future<void> loadUsersDebug() async {
    dev.log('=== AdminProvider: loadUsersDebug ===');
    await debugTestDatabase();
    await loadUsers(roleFilter: 'candidate');
  }
}
