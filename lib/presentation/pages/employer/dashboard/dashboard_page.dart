import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/presentation/widgets/employer/dashboard/profile_header.dart';
import 'package:jobgo/presentation/widgets/employer/dashboard/overview_card.dart';
import 'package:jobgo/presentation/widgets/employer/dashboard/views_statistics.dart';
import 'package:jobgo/presentation/widgets/employer/dashboard/recent_activity.dart';
import 'package:jobgo/data/models/dashboard_model.dart';
import 'package:jobgo/presentation/providers/employer_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _fetchDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employerProvider = context.read<EmployerProvider>();
      if (employerProvider.employer == null && !employerProvider.isLoading) {
        employerProvider.loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: FutureBuilder<_DashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final data = snapshot.data ?? _DashboardData.empty();
            final stats = data.stats;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Consumer<EmployerProvider>(
                    builder: (context, employerProvider, _) {
                      return DashboardProfileHeader(
                        companyName: employerProvider.employer?.companyName,
                        contactName: employerProvider.employer?.contactName,
                        logoColor: employerProvider.employer?.logoColor,
                      );
                    },
                  ),
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
                                    value: stats.activePostings.toString(),
                                    percentage: _formatTrendLabel(
                                      data.activeJobsTrend,
                                    ),
                                    icon: Icons.work_outline,
                                    color: AppColors.primary,
                                    isPositive: data.activeJobsTrend >= 0,
                                  ),
                                  const SizedBox(height: 12),
                                  OverviewCard(
                                    title: 'Hồ sơ mới', // Đã đổi title sang Hồ sơ mới nhận
                                    value: stats.newProfiles.toString(),
                                    percentage: _formatTrendLabel(
                                      data.applicantsTrend,
                                    ),
                                    icon: Icons.person_add_alt_1_outlined,
                                    color: AppColors.success,
                                    isPositive: data.applicantsTrend >= 0,
                                  ),
                                  const SizedBox(height: 12),
                                  OverviewCard(
                                    title: loc.interviewsCount,
                                    value: data.totalInterviews.toString(),
                                    percentage: _formatTrendLabel(
                                      data.interviewsTrend,
                                    ),
                                    icon: Icons.calendar_today_outlined,
                                    color: const Color(0xFF8B5CF6),
                                    isPositive: data.interviewsTrend >= 0,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: OverviewCard(
                                    title: loc.activeJobs,
                                    value: stats.activePostings.toString(),
                                    percentage: _formatTrendLabel(
                                      data.activeJobsTrend,
                                    ),
                                    icon: Icons.work_outline,
                                    color: AppColors.primary,
                                    isPositive: data.activeJobsTrend >= 0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OverviewCard(
                                    title: 'Hồ sơ mới', // Đã đổi title sang Hồ sơ mới nhận
                                    value: stats.newProfiles.toString(),
                                    percentage: _formatTrendLabel(
                                      data.applicantsTrend,
                                    ),
                                    icon: Icons.person_add_alt_1_outlined,
                                    color: AppColors.success,
                                    isPositive: data.applicantsTrend >= 0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OverviewCard(
                                    title: loc.interviewsCount,
                                    value: data.totalInterviews.toString(),
                                    percentage: _formatTrendLabel(
                                      data.interviewsTrend,
                                    ),
                                    icon: Icons.calendar_today_outlined,
                                    color: const Color(0xFF8B5CF6),
                                    isPositive: data.interviewsTrend >= 0,
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
                      weeklyData: data.weeklyApplications,
                      totalViews: data.totalViews,
                      trendLabel: _formatTrendLabel(data.viewsTrend),
                      trendPositive: data.viewsTrend >= 0,
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
                              onTap: () {},
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _dashboardFuture = _fetchDashboardData();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTrendLabel(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  Future<_DashboardData> _fetchDashboardData() async {
    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return _DashboardData.empty();

      final userRow = await supabase
          .from('users')
          .select('u_id')
          .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
          .maybeSingle();

      final userId = _toInt(userRow?['u_id']);
      if (userId == null) return _DashboardData.empty();

      final employerRow = await supabase
          .from('employers')
          .select('e_id')
          .eq('u_id', userId)
          .maybeSingle();

      final employerId = _toInt(employerRow?['e_id']);
      if (employerId == null) return _DashboardData.empty();

      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfWeek = startOfToday.subtract(const Duration(days: 6));
      final startOfLastWeek = startOfToday.subtract(const Duration(days: 13));

      int activeJobs = 0;
      try {
        final activeJobsResp = await supabase
            .from('jobs')
            .select('j_id')
            .eq('e_id', employerId)
            .eq('j_status', 'active');
        activeJobs = (activeJobsResp as List).length;
      } catch (_) {
        final activeJobsResp = await supabase
            .from('jobs')
            .select('j_id')
            .eq('e_id', employerId)
            .eq('j_moderation_status', 'approved');
        activeJobs = (activeJobsResp as List).length;
      }

      final applicationsResp = await supabase
          .from('applications')
          .select('a_id, jobs!inner(e_id)')
          .eq('jobs.e_id', employerId);

      final totalApplications = (applicationsResp as List).length;

      // Lấy số lượng "Hồ sơ mới nhận" (trạng thái 'pending')
      final newApplicationsResp = await supabase
          .from('applications')
          .select('a_id, jobs!inner(e_id)')
          .eq('jobs.e_id', employerId)
          .eq('a_status', 'pending');
      final newProfilesCount = (newApplicationsResp as List).length;

      final interviewsResp = await supabase
          .from('interview_schedule')
          .select('i_id, jobs!inner(e_id)')
          .eq('jobs.e_id', employerId);

      final totalInterviews = (interviewsResp as List).length;

      final weeklyApplications = await _buildWeeklyApplications(
        employerId: employerId,
        startDate: startOfWeek,
      );

      final lastWeekApplications = await _buildWeeklyApplications(
        employerId: employerId,
        startDate: startOfLastWeek,
      );

      final totalViews = weeklyApplications.fold<int>(
        0,
        (sum, value) => sum + value.toInt(),
      );

      final viewsTrend = _calculateTrend(
        weeklyApplications.fold<double>(0, (sum, v) => sum + v),
        lastWeekApplications.fold<double>(0, (sum, v) => sum + v),
      );

      final recentActivities = await _loadRecentActivities(employerId);

      final stats = DashboardStats(
        activePostings: activeJobs,
        newProfiles: newProfilesCount, // Cập nhật số hồ sơ mới nhận
        totalApplications: totalApplications,
        totalViews: totalViews,
        lastUpdated: now,
        recentActivities: recentActivities,
      );

      final activeJobsTrend = await _calculateCountTrend(
        table: 'jobs',
        dateColumn: 'j_create_at',
        employerId: employerId,
        compareStatus: 'active',
      );

      final applicantsTrend = await _calculateCountTrend(
        table: 'applications',
        dateColumn: 'a_applied_at',
        employerId: employerId,
      );

      final interviewsTrend = await _calculateCountTrend(
        table: 'interview_schedule',
        dateColumn: 'i_interview_date',
        employerId: employerId,
      );

      return _DashboardData(
        stats: stats,
        weeklyApplications: weeklyApplications,
        totalViews: totalViews,
        totalInterviews: totalInterviews,
        viewsTrend: viewsTrend,
        activeJobsTrend: activeJobsTrend,
        applicantsTrend: applicantsTrend,
        interviewsTrend: interviewsTrend,
      );
    } catch (_) {
      return _DashboardData.empty();
    }
  }

  Future<List<double>> _buildWeeklyApplications({
    required int employerId,
    required DateTime startDate,
  }) async {
    final supabase = Supabase.instance.client;
    final endDate = startDate.add(const Duration(days: 6));

    final response = await supabase
        .from('applications')
        .select('a_applied_at, jobs!inner(e_id)')
        .eq('jobs.e_id', employerId)
        .gte('a_applied_at', startDate.toIso8601String())
        .lte('a_applied_at', endDate.add(const Duration(days: 1)).toIso8601String());

    final buckets = List<double>.filled(7, 0);
    for (final row in (response as List)) {
      final appliedAt = _toDateTime(row['a_applied_at']);
      if (appliedAt == null) continue;
      final dayIndex = appliedAt.difference(startDate).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        buckets[dayIndex] += 1;
      }
    }

    return buckets;
  }

  Future<List<ActivityItem>> _loadRecentActivities(int employerId) async {
    final supabase = Supabase.instance.client;

    final applicationsResp = await supabase
        .from('applications')
        .select(
            'a_id, a_applied_at, candidates(c_full_name), jobs!inner(j_title, e_id)')
        .eq('jobs.e_id', employerId)
        .order('a_applied_at', ascending: false)
        .limit(4);

    final interviewsResp = await supabase
        .from('interview_schedule')
        .select(
            'i_id, i_interview_date, candidates(c_full_name), jobs!inner(j_title, e_id)')
        .eq('jobs.e_id', employerId)
        .order('i_interview_date', ascending: false)
        .limit(3);

    final postingsResp = await supabase
        .from('jobs')
        .select('j_id, j_title, j_create_at')
        .eq('e_id', employerId)
        .order('j_create_at', ascending: false)
        .limit(3);

    final activities = <ActivityItem>[];

    for (final row in (applicationsResp as List)) {
      final appliedAt = _toDateTime(row['a_applied_at']) ?? DateTime.now();
      final candidateName = _stringValue(row['candidates']?['c_full_name'],
          fallback: 'Candidate');
      final jobTitle = _stringValue(row['jobs']?['j_title'], fallback: 'Job');
      activities.add(
        ActivityItem(
          title: '$candidateName applied for $jobTitle',
          description: '$jobTitle • ${_timeAgo(appliedAt)}',
          timestamp: appliedAt,
          type: 'application',
        ),
      );
    }

    for (final row in (interviewsResp as List)) {
      final interviewDate =
          _toDateTime(row['i_interview_date']) ?? DateTime.now();
      final candidateName = _stringValue(row['candidates']?['c_full_name'],
          fallback: 'Candidate');
      final jobTitle = _stringValue(row['jobs']?['j_title'], fallback: 'Job');
      activities.add(
        ActivityItem(
          title: 'Interview scheduled with $candidateName',
          description: '$jobTitle • ${_timeAgo(interviewDate)}',
          timestamp: interviewDate,
          type: 'view',
        ),
      );
    }

    for (final row in (postingsResp as List)) {
      final postedAt = _toDateTime(row['j_create_at']) ?? DateTime.now();
      final jobTitle = _stringValue(row['j_title'], fallback: 'New job');
      activities.add(
        ActivityItem(
          title: 'New job posted: $jobTitle',
          description: 'Posting • ${_timeAgo(postedAt)}',
          timestamp: postedAt,
          type: 'posting',
        ),
      );
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(6).toList();
  }

  Future<double> _calculateCountTrend({
    required String table,
    required String dateColumn,
    required int employerId,
    String? compareStatus,
  }) async {
    final supabase = Supabase.instance.client;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfToday.subtract(const Duration(days: 6));
    final startOfLastWeek = startOfToday.subtract(const Duration(days: 13));

    Future<int> countBetween(DateTime from, DateTime to) async {
      if (table == 'jobs') {
        dynamic query = supabase
            .from('jobs')
            .select('j_id')
            .eq('e_id', employerId)
            .gte(dateColumn, from.toIso8601String())
            .lte(dateColumn, to.add(const Duration(days: 1)).toIso8601String());

        if (compareStatus != null) {
          query = supabase
              .from('jobs')
              .select('j_id')
              .eq('e_id', employerId)
              .eq('j_status', compareStatus)
              .gte(dateColumn, from.toIso8601String())
              .lte(dateColumn, to.add(const Duration(days: 1)).toIso8601String());
        }

        final rows = await query;
        return (rows as List).length;
      }

      final response = await supabase
          .from(table)
          .select('$dateColumn, jobs!inner(e_id)')
          .eq('jobs.e_id', employerId)
          .gte(dateColumn, from.toIso8601String())
          .lte(dateColumn, to.add(const Duration(days: 1)).toIso8601String());

      return (response as List).length;
    }

    final currentWeek = await countBetween(startOfWeek, startOfToday);
    final lastWeek = await countBetween(startOfLastWeek, startOfWeek);

    return _calculateTrend(currentWeek.toDouble(), lastWeek.toDouble());
  }

  double _calculateTrend(double currentValue, double previousValue) {
    if (previousValue == 0) {
      return currentValue > 0 ? 100 : 0;
    }
    return ((currentValue - previousValue) / previousValue) * 100;
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final str = value.toString().trim();
    return str.isEmpty ? fallback : str;
  }
}

class _DashboardData {
  final DashboardStats stats;
  final List<double> weeklyApplications;
  final int totalViews;
  final int totalInterviews;
  final double viewsTrend;
  final double activeJobsTrend;
  final double applicantsTrend;
  final double interviewsTrend;

  _DashboardData({
    required this.stats,
    required this.weeklyApplications,
    required this.totalViews,
    required this.totalInterviews,
    required this.viewsTrend,
    required this.activeJobsTrend,
    required this.applicantsTrend,
    required this.interviewsTrend,
  });

  factory _DashboardData.empty() {
    return _DashboardData(
      stats: DashboardStats(
        activePostings: 0,
        newProfiles: 0,
        totalApplications: 0,
        totalViews: 0,
        lastUpdated: DateTime.now(),
        recentActivities: const [],
      ),
      weeklyApplications: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      totalViews: 0,
      totalInterviews: 0,
      viewsTrend: 0,
      activeJobsTrend: 0,
      applicantsTrend: 0,
      interviewsTrend: 0,
    );
  }
}
