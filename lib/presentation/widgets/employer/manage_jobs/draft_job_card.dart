import 'package:flutter/material.dart';

import 'package:jobgo/presentation/widgets/common/adaptive_button_label.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/employer_job_model.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class DraftJobCard extends StatelessWidget {
  final EmployerJobModel job;
  final VoidCallback onResume;
  final VoidCallback onClose;

  const DraftJobCard({
    super.key,
    required this.job,
    required this.onResume,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final missingInfoSummary = _missingInfoSummary(loc);

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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loc.draftStatus,
                  style: const TextStyle(
                    color: AppColors.primary,
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
          Text(
            missingInfoSummary,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: AdaptiveButtonLabel(text: loc.resume),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
                  label: AdaptiveButtonLabel(text: loc.close),
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

  String _missingInfoSummary(AppLocalizations loc) {
    final missing = <String>[];

    if (job.title.trim().isEmpty) missing.add(loc.jobTitle);
    if (job.location.trim().isEmpty) missing.add(loc.location);
    if (job.description.trim().isEmpty) missing.add(loc.jobDescription);
    if (job.requirementsText.trim().isEmpty) missing.add(loc.jobRequirements);
    if (job.category.trim().isEmpty) missing.add(loc.selectCategory);
    if (job.employmentType.trim().isEmpty) missing.add(loc.employmentType);
    if (job.deadline == null) missing.add(loc.applicationDeadline);
    if (!job.salaryNegotiable &&
        job.salaryMin == null &&
        job.salaryMax == null) {
      missing.add(loc.salaryRange);
    }

    if (missing.isEmpty) {
      return loc.readyToPublish;
    }

    return '${loc.missing}: ${missing.take(3).join(', ')}';
  }
}
