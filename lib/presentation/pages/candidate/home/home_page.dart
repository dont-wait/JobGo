import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_jobs.dart';
import 'package:jobgo/presentation/widgets/candidate/home/home_search_bar.dart';
import 'package:jobgo/presentation/widgets/candidate/home/recommended_job_card.dart';
import 'package:jobgo/presentation/widgets/candidate/home/recent_job_tile.dart';
import 'package:jobgo/presentation/pages/candidate/job_detail/job_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to Dashboard
            },
            icon: const Icon(
              Icons.dashboard_outlined,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Go to Dashboard',
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to notifications
            },
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Search bar
              HomeSearchBar(
                onTap: () {
                  // TODO: Navigate to search page
                },
              ),
              const SizedBox(height: 24),
              // Recommended Jobs
              _buildSectionTitle('Recommended Jobs'),
              const SizedBox(height: 16),
              _buildRecommendedJobs(),
              const SizedBox(height: 28),
              // Recent Job Postings
              _buildSectionTitle('Recent Job Postings'),
              const SizedBox(height: 8),
              _buildRecentJobs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildRecommendedJobs() {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: MockJobs.recommendedJobs.length,
        itemBuilder: (context, index) {
          final job = MockJobs.recommendedJobs[index];
          return RecommendedJobCard(
            job: job,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobDetailPage(job: job),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentJobs() {
    // shrinkWrap: true -> ListView chỉ cao vừa đủ nội dung, không chiếm hết màn hình.
    // NeverScrollableScrollPhysics → tắt scroll riêng của ListView này,
    // để SingleChildScrollView cha xử lý toàn bộ scroll.
    // Pattern này dùng khi cần đặt ListView bên trong ScrollView.
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: MockJobs.recentJobs.length,
      separatorBuilder: (_, __) => const Divider(
        color: AppColors.divider,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final job = MockJobs.recentJobs[index];
        return RecentJobTile(
          job: job,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JobDetailPage(job: job),
              ),
            );
          },
          onBookmark: () {
            // TODO: Toggle bookmark
          },
        );
      },
    );
  }
}
