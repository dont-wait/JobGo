import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/job_moderation_model.dart';
import 'package:jobgo/presentation/widgets/admin/moderation/moderation_tabs.dart';
import 'package:jobgo/presentation/widgets/admin/moderation/job_moderation_card.dart';
import 'package:jobgo/presentation/widgets/admin/moderation/rejection_dialog.dart';

class JobModerationPage extends StatefulWidget {
  const JobModerationPage({super.key});

  @override
  State<JobModerationPage> createState() => _JobModerationPageState();
}

class _JobModerationPageState extends State<JobModerationPage> {
  String selectedTab = 'Pending';
  List<JobModerationItem> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() {
    // Mock data - replace with actual API call
    setState(() {
      jobs = [
        JobModerationItem(
          id: '1',
          title: 'Product Designer',
          company: 'TechSolutions Inc',
          location: 'San Francisco',
          salaryRange: '\$100k - \$80k',
          postedDate: DateTime.now().subtract(const Duration(hours: 4)),
          status: 'pending',
        ),
        JobModerationItem(
          id: '2',
          title: 'Growth Lead',
          company: 'Growify Co',
          location: 'Remote',
          salaryRange: '\$120k - \$150k',
          postedDate: DateTime.now().subtract(const Duration(days: 2)),
          status: 'pending',
        ),
        JobModerationItem(
          id: '3',
          title: 'Data Analyst',
          company: 'Magnify',
          location: 'New York',
          salaryRange: '\$90k - \$110k',
          postedDate: DateTime.now().subtract(const Duration(days: 5)),
          status: 'pending',
        ),
        JobModerationItem(
          id: '4',
          title: 'Senior Product Designer',
          company: 'TechCorp',
          location: 'Remote',
          salaryRange: '\$140k - \$180k',
          postedDate: DateTime.now().subtract(const Duration(days: 1)),
          status: 'approved',
        ),
        JobModerationItem(
          id: '5',
          title: 'Backend Engineer',
          company: 'StartupXYZ',
          location: 'Austin',
          salaryRange: '\$80k - \$120k',
          postedDate: DateTime.now().subtract(const Duration(days: 3)),
          status: 'rejected',
          rejectionReasons: ['Incomplete Description', 'Violates TOS / Spam'],
        ),
      ];
      isLoading = false;
    });
  }

  List<JobModerationItem> get filteredJobs {
    return jobs.where((job) {
      if (selectedTab == 'Pending') return job.status == 'pending';
      if (selectedTab == 'Approved') return job.status == 'approved';
      if (selectedTab == 'Rejected') return job.status == 'rejected';
      return true;
    }).toList();
  }

  void _showRejectionDialog(JobModerationItem job) {
    showDialog(
      context: context,
      builder: (context) => RejectionDialog(
        onSubmit: (reasons) {
          _handleRejection(job, reasons);
        },
      ),
    );
  }

  void _handleApproval(JobModerationItem job) {
    setState(() {
      final index = jobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        jobs[index] = job.copyWith(status: 'approved');
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job "${job.title}" has been approved'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleRejection(JobModerationItem job, List<String> reasons) {
    setState(() {
      final index = jobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        jobs[index] = job.copyWith(
          status: 'rejected',
          rejectionReasons: reasons,
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job "${job.title}" has been rejected'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          ModerationTabs(
            selectedTab: selectedTab,
            onTabChanged: (tab) {
              setState(() {
                selectedTab = tab;
              });
            },
            pendingCount: jobs.where((j) => j.status == 'pending').length,
          ),

          // Job List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredJobs.isEmpty
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
                              'No ${selectedTab.toLowerCase()} jobs',
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
                        itemCount: filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = filteredJobs[index];
                          return JobModerationCard(
                            job: job,
                            onApprove: () => _handleApproval(job),
                            onReject: () => _showRejectionDialog(job),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
