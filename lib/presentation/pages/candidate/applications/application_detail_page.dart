import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/presentation/providers/application_provider.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailPage extends StatelessWidget {
  final JobApplicantModel application;

  const ApplicationDetailPage({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final job = application.job;
    if (job == null) return Scaffold(body: Center(child: Text(loc.error)));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.applicationStatus,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJobHeader(job),
            const SizedBox(height: 24),
            _buildStatusSection(loc),
            const SizedBox(height: 24),
            _buildTimelineSection(loc),
            const SizedBox(height: 24),
            _buildApplicationInfoSection(loc),
            const SizedBox(height: 32),
            if (application.status == ApplicationStatus.pending ||
                application.status == ApplicationStatus.reviewing)
              _buildWithdrawButton(context, loc),
          ],
        ),
      ),
    );
  }

  Widget _buildJobHeader(dynamic job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CompanyLogo(
            imageUrl: job.logoUrl,
            fallbackText: job.logoText,
            backgroundColor: Color(int.parse(job.logoColor)),
            width: 60,
            height: 60,
            borderRadius: 12,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.company,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.formattedSalary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(AppLocalizations loc) {
    final statusColor = _getStatusColor(application.status);
    final statusText = _getStatusText(application.status, loc);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.currentStatus,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: statusColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(AppLocalizations loc) {
    final steps = [
      {
        'title': loc.applicationSubmitted,
        // Wait, did we add a description for these?
        // Let's use the ones already in data if any, or static localizations.
        'desc':
            loc.applicationSubmitted, // Just use the title if no description
        'done': true,
      },
      {
        'title': loc.underReview,
        'desc': loc.underReview,
        'done': application.status != ApplicationStatus.pending,
      },
      {
        'title': loc.shortlistedInterview,
        'desc': loc.shortlistedInterview,
        'done':
        application.status == ApplicationStatus.shortlisted ||
            application.status == ApplicationStatus.interview ||
            application.status == ApplicationStatus.hired,
      },
      {
        'title': loc.decision,
        'desc': loc.decision,
        'done':
            application.status == ApplicationStatus.hired ||
            application.status == ApplicationStatus.rejected,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.applicationTimeline,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final isDone = step['done'] as bool;
          final isLast = index == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.primary : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isDone ? AppColors.primary : AppColors.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                        // Removed description for now as it's not and wasn't properly localized or needed once titles are clear
                        if (index == 0 && application.appliedAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat(
                                'MMM d, yyyy • HH:mm',
                              ).format(application.appliedAt!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildApplicationInfoSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.yourApplication,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (application.coverLetter != null &&
            application.coverLetter!.isNotEmpty) ...[
          Text(
            loc.coverLetter,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              application.coverLetter!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          loc.resume,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final uri = Uri.parse(application.cvUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.attachedResume,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawButton(BuildContext context, AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => _showWithdrawDialog(context, loc),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          loc.withdrawButton,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.withdrawConfirmTitle),
        content: Text(loc.withdrawConfirmMessageUndo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              final success = await context
                  .read<ApplicationProvider>()
                  .withdraw(application.applicationId, application.candidateId);
              if (success && context.mounted) {
                Navigator.pop(context); // Go back to history
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.withdrawSuccessMessage)),
                );
              }
            },
            child: Text(
              loc.withdrawButton,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.reviewing:
        return Colors.blue;
      case ApplicationStatus.shortlisted:
        return Colors.deepPurple;
      case ApplicationStatus.interview:
        return Colors.purple;
      case ApplicationStatus.hired:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
    }
  }

  String _getStatusText(ApplicationStatus status, AppLocalizations loc) {
    switch (status) {
      case ApplicationStatus.pending:
        return loc.pendingReview;
      case ApplicationStatus.reviewing:
        return loc.employerReviewing;
      case ApplicationStatus.shortlisted:
        return loc.shortlistedInterview;
      case ApplicationStatus.interview:
        return loc.interviewInvited;
      case ApplicationStatus.hired:
        return loc.acceptedHired;
      case ApplicationStatus.rejected:
        return loc.notSelected;
      case ApplicationStatus.withdrawn:
        return loc.withdrawnByYou;
    }
  }
}
