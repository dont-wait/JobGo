import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/admin_stats_model.dart';
import 'package:jobgo/presentation/widgets/admin/dashboard/stat_card.dart';
import 'package:jobgo/presentation/widgets/admin/dashboard/growth_chart.dart';
import 'package:jobgo/presentation/widgets/admin/dashboard/admin_recent_activity.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';
import 'package:jobgo/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      await context.read<AdminProvider>().loadDashboardStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingStats) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final stats = AdminStats(
          totalUsers: adminProvider.totalUsers,
          pendingJobs: adminProvider.pendingJobs,
          platformRevenue: (adminProvider.activeJobs * 125.50),
          revenueGrowth:
              '+${(adminProvider.pendingJobs * 2.5).toStringAsFixed(0)} this week',
          lastUpdated: DateTime.now(),
          recentActivities: [
            ActivityItem(
              title: 'Platform Stats',
              description:
                  '${adminProvider.totalUsers} users, ${adminProvider.activeJobs} active jobs',
              timestamp: DateTime.now(),
              type: 'stats',
            ),
            ActivityItem(
              title: 'Pending Review',
              description:
                  '${adminProvider.pendingJobs} job postings awaiting moderation',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              type: 'review',
            ),
            ActivityItem(
              title: 'Active Employers',
              description:
                  '${adminProvider.totalEmployers} employers on the platform',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              type: 'employer',
            ),
          ],
          growthData: [
            GrowthDataPoint(label: 'Mon', users: 30, jobs: 20),
            GrowthDataPoint(label: 'Tue', users: 45, jobs: 28),
            GrowthDataPoint(label: 'Wed', users: 60, jobs: 35),
            GrowthDataPoint(label: 'Thu', users: 80, jobs: 42),
            GrowthDataPoint(label: 'Fri', users: 95, jobs: 50),
            GrowthDataPoint(label: 'Sat', users: 110, jobs: 58),
            GrowthDataPoint(label: 'Sun', users: 130, jobs: 65),
          ],
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text(
              'Dashboard',
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Stats Overview
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.people,
                          iconColor: AppColors.primary,
                          iconBackground: AppColors.primary.withOpacity(0.1),
                          label: 'Total Users',
                          value: stats.totalUsers.toString(),
                          trend: '+12%',
                          trendUp: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.work,
                          iconColor: AppColors.warning,
                          iconBackground: AppColors.warning.withOpacity(0.1),
                          label: 'Pending Jobs',
                          value: stats.pendingJobs.toString(),
                          trend: 'Stable',
                          trendUp: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Platform Revenue Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.attach_money,
                            color: AppColors.success,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Platform Revenue',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${stats.platformRevenue.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stats.revenueGrowth,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Growth Trends
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Growth Trends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Last 7 days',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GrowthChart(data: stats.growthData),
                  const SizedBox(height: 24),

                  // Recent Activities
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AdminRecentActivity(activities: stats.recentActivities),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
