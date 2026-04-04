import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/job_moderation_model.dart';
import 'package:jobgo/presentation/widgets/admin/moderation/moderation_tabs.dart';
import 'package:jobgo/presentation/widgets/admin/moderation/job_moderation_card.dart';
import 'package:jobgo/presentation/widgets/admin/moderation/rejection_dialog.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';
import 'package:jobgo/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class JobModerationPage extends StatefulWidget {
  const JobModerationPage({super.key});

  @override
  State<JobModerationPage> createState() => _JobModerationPageState();
}

class _JobModerationPageState extends State<JobModerationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPendingJobs();
    });
  }

  void _showRejectionDialog(
    JobModerationItem job,
    AdminProvider adminProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => RejectionDialog(
        onSubmit: (reasons) {
          _handleRejection(job, reasons, adminProvider);
        },
      ),
    );
  }

  void _handleApproval(
    JobModerationItem job,
    AdminProvider adminProvider,
  ) async {
    try {
      final success = await adminProvider.approveJob(job.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job "${job.title}" has been approved'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Approve failed: unable to update job status'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving job: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleRejection(
    JobModerationItem job,
    List<String> reasons,
    AdminProvider adminProvider,
  ) async {
    try {
      Navigator.of(context).pop();
      final success = await adminProvider.rejectJob(job.id, reasons, null);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job "${job.title}" has been rejected'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reject failed: unable to update job status'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting job: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleDeleteJob(
    JobModerationItem job,
    AdminProvider adminProvider,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete job post?'),
        content: Text('This will permanently remove "${job.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final deleted = await adminProvider.deleteJob(job.id);
      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job "${job.title}" has been deleted'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delete failed: job record was not found'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting job: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'Job Moderation',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            const ProfileAvatar(role: UserRole.admin),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Tabs
            ModerationTabs(
              selectedTab: adminProvider.selectedJobFilter,
              onTabChanged: (tab) {
                adminProvider.setJobFilter(tab);
                if (tab == 'Pending') {
                  adminProvider.loadPendingJobs();
                } else {
                  adminProvider.loadModeratedJobs(status: tab.toLowerCase());
                }
              },
              pendingCount: adminProvider.jobs
                  .where((j) => j.status == 'pending')
                  .length,
            ),

            // Job List
            Expanded(
              child: adminProvider.isLoadingJobs
                  ? const Center(child: CircularProgressIndicator())
                  : adminProvider.jobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${adminProvider.selectedJobFilter.toLowerCase()} jobs',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: adminProvider.jobs.length,
                      itemBuilder: (context, index) {
                        final job = adminProvider.jobs[index];
                        return JobModerationCard(
                          job: job,
                          onApprove: () => _handleApproval(job, adminProvider),
                          onReject: () =>
                              _showRejectionDialog(job, adminProvider),
                          onDelete: () => _handleDeleteJob(job, adminProvider),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
