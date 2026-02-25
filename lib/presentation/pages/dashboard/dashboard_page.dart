import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/widgets/dashboard/stats_card.dart';
import 'package:jobgo/presentation/widgets/dashboard/dashboard_header.dart';
import 'package:jobgo/presentation/widgets/dashboard/recent_activity.dart';
import 'package:jobgo/data/models/dashboard_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardStats stats;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  void _loadDashboardStats() {
    // Mock data - replace with actual API call
    stats = DashboardStats(
      activePostings: 12,
      newProfiles: 8,
      totalApplications: 45,
      totalViews: 234,
      lastUpdated: DateTime.now(),
      recentActivities: [
        ActivityItem(
          title: 'New application received',
          description: 'Senior Flutter Developer role',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'application',
        ),
        ActivityItem(
          title: 'Job posting created',
          description: 'UI/UX Designer position',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'posting',
        ),
        ActivityItem(
          title: 'Profile viewed',
          description: 'By HR Manager from Tech Corp',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          type: 'view',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              DashboardHeader(stats: stats),
              const SizedBox(height: 24),
              
              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Active Postings',
                            value: stats.activePostings.toString(),
                            icon: Icons.article_outlined,
                            color: AppColors.primary,
                            onTap: () {
                              // TODO: Navigate to job postings list
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'New Profiles',
                            value: stats.newProfiles.toString(),
                            icon: Icons.person_add_outlined,
                            color: AppColors.success,
                            onTap: () {
                              // TODO: Navigate to profiles list
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Total Applications',
                            value: stats.totalApplications.toString(),
                            icon: Icons.inbox_outlined,
                            color: AppColors.warning,
                            onTap: () {
                              // TODO: Navigate to applications
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Profile Views',
                            value: stats.totalViews.toString(),
                            icon: Icons.visibility_outlined,
                            color: const Color(0xFF8B5CF6),
                            onTap: () {
                              // TODO: Navigate to profile views analytics
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Recent Activity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecentActivityList(activities: stats.recentActivities),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
