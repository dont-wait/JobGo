import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/presentation/widgets/employer/dashboard/profile_header.dart';
import 'package:jobgo/presentation/widgets/employer/dashboard/overview_card.dart';
import 'package:jobgo/presentation/widgets/employer/dashboard/views_statistics.dart';
import 'package:jobgo/presentation/widgets/employer/dashboard/recent_activity.dart';
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
          title: 'John Doe applied for Senior UI Desi...',
          description: 'Design Team • 2h ago',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'application',
        ),
        ActivityItem(
          title: 'Interview scheduled with Sarah Smith',
          description: 'Engineering • 1h ago',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          type: 'view',
        ),
        ActivityItem(
          title: 'New message from David Lee',
          description: 'Product Management • 3h ago',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          type: 'posting',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              const DashboardProfileHeader(),
              const SizedBox(height: 20),

              // Overview Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.overview,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            loc.last30Days,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Overview Cards - Responsive
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 360;

                        if (isNarrow) {
                          return Column(
                            children: [
                              OverviewCard(
                                title: loc.activeJobs,
                                value: '12',
                                percentage: '+7%',
                                icon: Icons.work_outline,
                                color: AppColors.primary,
                                isPositive: true,
                              ),
                              SizedBox(height: 12),
                              OverviewCard(
                                title: loc.applicants,
                                value: '48',
                                percentage: '+9%',
                                icon: Icons.people_outline,
                                color: AppColors.success,
                                isPositive: true,
                              ),
                              SizedBox(height: 12),
                              OverviewCard(
                                title: loc.interviewsCount,
                                value: '5',
                                percentage: '+2%',
                                icon: Icons.calendar_today_outlined,
                                color: Color(0xFF8B5CF6),
                                isPositive: true,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: OverviewCard(
                                title: loc.activeJobs,
                                value: '12',
                                percentage: '+7%',
                                icon: Icons.work_outline,
                                color: AppColors.primary,
                                isPositive: true,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OverviewCard(
                                title: loc.applicants,
                                value: '48',
                                percentage: '+9%',
                                icon: Icons.people_outline,
                                color: AppColors.success,
                                isPositive: true,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OverviewCard(
                                title: loc.interviewsCount,
                                value: '5',
                                percentage: '+2%',
                                icon: Icons.calendar_today_outlined,
                                color: Color(0xFF8B5CF6),
                                isPositive: true,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Views Statistics
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewsStatisticsChart(
                  weeklyData: const [250, 650, 400, 500, 350, 200, 800],
                ),
              ),
              const SizedBox(height: 28),

              // Recent Activities
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.recentActivities,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: View all activities
                          },
                          child: Text(
                            loc.viewAll,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
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
