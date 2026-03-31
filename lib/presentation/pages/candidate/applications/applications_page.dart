import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/presentation/providers/application_provider.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch applications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().candidate;
      if (profile != null) {
        context.read<ApplicationProvider>().fetchMyApplications(profile.cId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Application History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(),
        ),
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final allApps = provider.applications;

          // Filter by tab
          final appliedApps = allApps
              .where(
                (a) =>
                    a.status == ApplicationStatus.pending ||
                    a.status == ApplicationStatus.reviewing ||
                    a.status == ApplicationStatus.rejected ||
                    a.status == ApplicationStatus.withdrawn,
              )
              .toList();

          final interviewApps = allApps
              .where((a) => a.status == ApplicationStatus.interview)
              .toList();
          final acceptedApps = allApps
              .where((a) => a.status == ApplicationStatus.hired)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _ApplicationList(applications: appliedApps),
              _ApplicationList(applications: interviewApps),
              _ApplicationList(applications: acceptedApps),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'Applied'),
          Tab(text: 'Interviews'),
          Tab(text: 'Accepted'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Application List (per tab)
// ─────────────────────────────────────────────
class _ApplicationList extends StatelessWidget {
  final List<JobApplicantModel> applications;
  const _ApplicationList({required this.applications});

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No applications found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your applications for this category will appear here',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ApplicationCard(application: applications[index]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Single Application Card
// ─────────────────────────────────────────────
class _ApplicationCard extends StatelessWidget {
  final JobApplicantModel application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final job = application.job;
    if (job == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company logo
              _buildLogo(job),
              const SizedBox(width: 12),
              // Title & Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.company} • ${job.location}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.formattedSalary,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 14),

          // Bottom row: Applied time + Withdraw action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Applied on ${_formatDate(application.appliedAt ?? DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              if (application.status == ApplicationStatus.pending)
                _WithdrawButton(application: application),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLogo(dynamic job) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Color(int.parse(job.logoColor)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          job.logoText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (Color bg, Color fg) = _statusColors;
    String label = application.status.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  (Color, Color) get _statusColors {
    switch (application.status) {
      case ApplicationStatus.pending:
        return (const Color(0xFFFFF3E0), const Color(0xFFE65100));
      case ApplicationStatus.reviewing:
        return (const Color(0xFFE3F2FD), const Color(0xFF1565C0));
      case ApplicationStatus.interview:
        return (const Color(0xFFEDE7F6), const Color(0xFF6A1B9A));
      case ApplicationStatus.hired:
        return (const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case ApplicationStatus.rejected:
        return (const Color(0xFFFFEBEE), const Color(0xFFC62828));
      case ApplicationStatus.withdrawn:
        return (const Color(0xFFF5F5F5), const Color(0xFF616161));
    }
  }
}

class _WithdrawButton extends StatefulWidget {
  final JobApplicantModel application;
  const _WithdrawButton({required this.application});

  @override
  State<_WithdrawButton> createState() => _WithdrawButtonState();
}

class _WithdrawButtonState extends State<_WithdrawButton> {
  bool _isWithdrawing = false;

  Future<void> _handleWithdraw() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rút hồ sơ?'),
        content: const Text('Bạn có chắc chắn muốn rút hồ sơ ứng tuyển này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rút hồ sơ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isWithdrawing = true);

    final profile = context.read<ProfileProvider>().candidate;
    if (profile == null) return;

    final success = await context.read<ApplicationProvider>().withdraw(
      widget.application.applicationId,
      profile.cId,
    );

    if (mounted) {
      setState(() => _isWithdrawing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã rút hồ sơ thành công')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rút hồ sơ thất bại')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isWithdrawing
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : GestureDetector(
            onTap: _handleWithdraw,
            child: const Text(
              'Withdraw',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          );
  }
}
