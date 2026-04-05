import 'package:flutter/material.dart';

import 'package:jobgo/presentation/widgets/common/adaptive_button_label.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/employer_job_model.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/widgets/employer/applicants/job_applicants_page.dart';

class PublishedJobCard extends StatelessWidget {
  final EmployerJobModel job;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const PublishedJobCard({
    super.key,
    required this.job,
    required this.onEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final applicantCount = job.applicationCount;
    final jobId = job.id?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(loc, job.status),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                job.updatedLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.title.isEmpty ? loc.untitledJob : job.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '$applicantCount ${loc.applicants}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Flexible(
                child: GestureDetector(
                  onTap: jobId.isEmpty
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobApplicantsPage(
                              jobTitle: job.title.isEmpty
                                  ? loc.untitledJob
                                  : job.title,
                              totalApplicants: applicantCount,
                              jobId: jobId,
                            ),
                          ),
                        ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AdaptiveButtonLabel(
                      text: loc.viewApplicants,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: AdaptiveButtonLabel(
                    text: loc.edit,
                    style: const TextStyle(),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withOpacity(0.05),
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                  label: AdaptiveButtonLabel(
                    text: loc.close,
                    style: const TextStyle(),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    side: const BorderSide(color: Colors.orange, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations loc, String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'published':
      case 'open':
        return loc.statusActive;
      case 'closed':
      case 'expired':
      case 'archived':
        return loc.statusClosed;
      case 'pending':
        return loc.statusPending;
      case 'draft':
      case 'saved':
      default:
        return loc.statusDraft;
    }
  }
}
