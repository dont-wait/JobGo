import 'package:flutter/material.dart';

import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/employer_job_model.dart';
import 'package:jobgo/data/repositories/employer_job_repository.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/closed_job_card.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/draft_job_card.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/job_status_tab_bar.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/post_new_job_banner.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/published_job_card.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/post_job_page.dart';
import 'package:jobgo/core/localization/app_localizations.dart';

class ManageJobsPage extends StatefulWidget {
  const ManageJobsPage({super.key});

  @override
  State<ManageJobsPage> createState() => _ManageJobsPageState();
}

class _ManageJobsPageState extends State<ManageJobsPage> {
  final EmployerJobRepository _repository = EmployerJobRepository();

  int _currentTab = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<EmployerJobModel> _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (mounted) {
      setState(() => _errorMessage = null);
    }

    try {
      final jobs = await _repository.fetchMyJobs();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e is StateError
          ? e.message
          : AppLocalizations.of(context).couldNotLoadJobs;

      if (_jobs.isEmpty || !refresh) {
        setState(() {
          _jobs = [];
          _errorMessage = message;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<EmployerJobModel> get _draftJobs =>
      _jobs.where((job) => job.isDraft).toList();

  List<EmployerJobModel> get _activeJobs =>
      _jobs.where((job) => job.isActive).toList();

  List<EmployerJobModel> get _closedJobs =>
      _jobs.where((job) => job.isClosed).toList();

  Future<void> _openCreateJob() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PostJobPage()),
    );

    if (result == true) {
      await _loadJobs(refresh: true);
    }
  }

  Future<void> _openEditJob(EmployerJobModel job) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PostJobPage(initialJob: job)),
    );

    if (result == true) {
      await _loadJobs(refresh: true);
    }
  }

  Future<void> _reopenJob(EmployerJobModel job) async {
    if (job.id == null) return;

    final loc = AppLocalizations.of(context);
    final shouldReopen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.reopenJobTitle),
        content: Text(loc.reopenJobConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.ok),
          ),
        ],
      ),
    );

    if (shouldReopen != true) return;

    try {
      await _repository.reopenJob(job.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.jobReopenedSuccess)));
      await _loadJobs(refresh: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _closeJob(EmployerJobModel job) async {
    if (job.id == null) return;

    final loc = AppLocalizations.of(context);
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.closeJobTitle),
        content: Text(loc.closeJobConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.close),
          ),
        ],
      ),
    );

    if (shouldClose != true) return;

    try {
      await _repository.closeJob(job.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.jobClosedSuccess)));
      await _loadJobs(refresh: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(
            Icons.work_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _openCreateJob,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
            child: Text(AppLocalizations.of(context).postNewJob),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCurrentTabContent() {
    if (_isLoading) {
      return const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator()),
      ];
    }

    if (_errorMessage != null) {
      return [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadJobs(refresh: true),
                  child: Text(AppLocalizations.of(context).retryButton),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final widgets = <Widget>[const SizedBox(height: 20)];

    if (_currentTab == 0) {
      widgets.add(PostNewJobBanner(onPressed: _openCreateJob));
      widgets.add(const SizedBox(height: 12));

      if (_jobs.isEmpty) {
        widgets.add(
          _emptyState(
            AppLocalizations.of(context).noJobsYet,
            AppLocalizations.of(context).createFirstJobPost,
          ),
        );
        widgets.add(const SizedBox(height: 20));
        return widgets;
      }

      if (_draftJobs.isNotEmpty) {
        widgets.add(_sectionHeader(AppLocalizations.of(context).draftJobs));
        for (final job in _draftJobs) {
          widgets.add(
            DraftJobCard(
              job: job,
              onResume: () => _openEditJob(job),
              onClose: () => _closeJob(job),
            ),
          );
          widgets.add(const SizedBox(height: 16));
        }
      }

      if (_activeJobs.isNotEmpty) {
        widgets.add(_sectionHeader(AppLocalizations.of(context).activeJobs));
        for (final job in _activeJobs) {
          widgets.add(
            PublishedJobCard(
              job: job,
              onEdit: () => _openEditJob(job),
              onClose: () => _closeJob(job),
            ),
          );
          widgets.add(const SizedBox(height: 16));
        }
      }

      if (_closedJobs.isNotEmpty) {
        widgets.add(_sectionHeader(AppLocalizations.of(context).closedJobs));
        for (final job in _closedJobs) {
          widgets.add(
            ClosedJobCard(
              job: job,
              onReopen: () => _reopenJob(job),
              onViewHistory: () {},
            ),
          );
          widgets.add(const SizedBox(height: 16));
        }
      }

      widgets.add(const SizedBox(height: 20));
      return widgets;
    }

    final filteredJobs = switch (_currentTab) {
      1 => _activeJobs,
      2 => _closedJobs,
      3 => _draftJobs,
      _ => _jobs,
    };

    if (filteredJobs.isEmpty) {
      widgets.add(
        _emptyState(
          AppLocalizations.of(context).noJobsInTab,
          AppLocalizations.of(context).tryCreatingNewJob,
        ),
      );
      widgets.add(const SizedBox(height: 20));
      return widgets;
    }

    for (final job in filteredJobs) {
      widgets.add(switch (_currentTab) {
        1 => PublishedJobCard(
          job: job,
          onEdit: () => _openEditJob(job),
          onClose: () => _closeJob(job),
        ),
        2 => ClosedJobCard(job: job, onReopen: () => _reopenJob(job)),
        3 => DraftJobCard(
          job: job,
          onResume: () => _openEditJob(job),
          onClose: () => _closeJob(job),
        ),
        _ => const SizedBox.shrink(),
      });
      widgets.add(const SizedBox(height: 16));
    }

    widgets.add(const SizedBox(height: 20));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context).manageJobs,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary, size: 28),
            onPressed: _openCreateJob,
          ),
          const ProfileAvatar(role: UserRole.employer),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            JobStatusTabBar(
              currentIndex: _currentTab,
              onTabChanged: (index) => setState(() => _currentTab = index),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadJobs(refresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _buildCurrentTabContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
