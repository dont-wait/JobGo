import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/post_new_job_banner.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/job_status_tab_bar.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/draft_job_card.dart';
import 'package:jobgo/presentation/widgets/employer/manage_jobs/closed_job_card.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/post_job_page.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

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
        automaticallyImplyLeading: false,
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
    switch (_currentTab) {
      case 0:
        return Column(
          children: [
            const SizedBox(height: 20),
            const PostNewJobBanner(),
            const SizedBox(height: 24),
            DraftJobCard(jobTitle: 'Product Marketing Manager'),
            const SizedBox(height: 32),
            ClosedJobCard(jobTitle: 'Frontend Developer', applicantsCount: 5),
            const SizedBox(height: 40),
          ],
        );

      case 1:
        return Column(
          children: [const SizedBox(height: 20), const SizedBox(height: 40)],
        );

      case 2:
        return Column(
          children: [
            const SizedBox(height: 20),
            ClosedJobCard(jobTitle: 'Frontend Developer', applicantsCount: 5),
            const SizedBox(height: 40),
          ],
        );

      case 3:
        return Column(
          children: [
            const SizedBox(height: 20),
            DraftJobCard(jobTitle: 'Product Marketing Manager'),
            const SizedBox(height: 40),
          ],
        );

      default:
        return const Center(
          child: Text(
            'No jobs in this tab yet',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        );
    }
  }
}
