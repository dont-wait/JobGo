import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/admin_user_model.dart';
import 'package:jobgo/data/models/job_moderation_model.dart';
import 'package:jobgo/data/repositories/admin_repository.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

class AdminSearchPage extends StatefulWidget {
  const AdminSearchPage({super.key});

  @override
  State<AdminSearchPage> createState() => _AdminSearchPageState();
}

class _AdminSearchPageState extends State<AdminSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final AdminRepository _repository = AdminRepository();

  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _error;

  List<AdminUserModel> _users = const [];
  List<JobModerationItem> _jobs = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final candidateUsers = await _repository.getAllUsers(
        pageSize: 200,
        roleFilter: 'candidate',
      );
      final employerUsers = await _repository.getAllUsers(
        pageSize: 200,
        roleFilter: 'employer',
      );

      final userMap = <String, AdminUserModel>{
        for (final u in [...candidateUsers, ...employerUsers])
          '${u.id}|${u.email}|${u.name}': u,
      };

      final pendingJobs = await _repository.getPendingJobs(pageSize: 200);
      final moderatedJobs = await _repository.getModeratedJobs(pageSize: 200);

      final mapById = <String, JobModerationItem>{
        for (final item in pendingJobs) item.id: item,
        for (final item in moderatedJobs) item.id: item,
      };

      setState(() {
        _users = userMap.values.toList();
        _jobs = mapById.values.toList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<AdminUserModel> get _filteredUsers {
    final q = _searchController.text.trim().toLowerCase();
    final source = _selectedFilter == 'Employers'
        ? _users.where((u) => u.role == 'employer').toList()
        : _selectedFilter == 'Candidates'
            ? _users.where((u) => u.role == 'candidate').toList()
            : _users; // Trường hợp 'All' sẽ lấy toàn bộ _users

    if (q.isEmpty) return source;

    return source.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.role.toLowerCase().contains(q);
    }).toList();
  }

  List<JobModerationItem> get _filteredJobs {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _jobs;

    return _jobs.where((j) {
      return j.title.toLowerCase().contains(q) ||
          j.company.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final showUsers = _selectedFilter == 'All' ||
        _selectedFilter == 'Candidates' ||
        _selectedFilter == 'Employers';
    final showJobs = _selectedFilter == 'All' || _selectedFilter == 'Job Posts';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Global Search',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: const [
          ProfileAvatar(role: UserRole.admin),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search candidates, employers, jobs...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadData,
                    ),
                    filled: true,
                    fillColor: AppColors.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _chip('All'),
                    const SizedBox(width: 8),
                    _chip('Candidates'),
                    const SizedBox(width: 8),
                    _chip('Employers'),
                    const SizedBox(width: 8),
                    _chip('Job Posts'),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Loaded: ${_users.length} accounts, ${_jobs.length} jobs',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (showUsers) ...[
                          Text(
                            _selectedFilter == 'All' ? 'Accounts (Candidates & Employers)' : _selectedFilter,
                            style: const TextStyle(fontWeight: FontWeight.w700)
                          ),
                          const SizedBox(height: 8),
                          ..._filteredUsers.take(50).map(_userTile),
                          const SizedBox(height: 16),
                        ],
                        if (showJobs) ...[
                          const Text('Job Posts', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          ..._filteredJobs.take(50).map(_jobTile),
                        ],
                        if ((_filteredUsers.isEmpty && showUsers) &&
                            (_filteredJobs.isEmpty && showJobs))
                          const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Center(
                              child: Text(
                                'No data found from Supabase',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    final selected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _userTile(AdminUserModel u) {
    final name = u.name.trim().isEmpty ? 'Unknown Account' : u.name;
    final subtitle = u.email.trim().isEmpty ? 'Email not available' : u.email;

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(name[0].toUpperCase())),
        title: Text(name),
        subtitle: Text('$subtitle | ${u.role}'),
      ),
    );
  }

  Widget _jobTile(JobModerationItem j) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.work_outline),
        title: Text(j.title.isEmpty ? 'Untitled job' : j.title),
        subtitle: Text('${j.company} | ${j.location} | ${j.status}'),
      ),
    );
  }
}
