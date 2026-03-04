import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_jobs.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/post_new_job_banner.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/job_status_tab_bar.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/draft_job_card.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/published_job_card.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/closed_job_card.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/job_posts_page.dart';

class ManageJobsPage extends StatefulWidget {
  const ManageJobsPage({super.key});

  @override
  State<ManageJobsPage> createState() => _ManageJobsPageState();
}

class _ManageJobsPageState extends State<ManageJobsPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Manage Jobs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostJobPage()),
            ),
          ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_currentTab == 0 || _currentTab == 1) {
      return Column(
        children: [
          const SizedBox(height: 20),
          const PostNewJobBanner(),
          const SizedBox(height: 24),
          const DraftJobCard(),
          const SizedBox(height: 32),

          // Published jobs từ mock data
          ...MockJobs.recentJobs.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: PublishedJobCard(
                jobTitle: job.title,
                applicantsCount: job.applicants ?? 0,
                jobId: job.id,
                postedTime: job.postedTime,
              ),
            ),
          ),

          const SizedBox(height: 24),
          const ClosedJobCard(),
          const SizedBox(height: 40),
        ],
      );
    }
    return const Center(
      child: Text(
        'No jobs in this tab yet',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
      ),
    );
  }
}
