import 'package:flutter/material.dart';

import 'package:jobgo/presentation/widgets/common/adaptive_button_label.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/employer_job_model.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class ClosedJobCard extends StatelessWidget {
  final EmployerJobModel job;
  final VoidCallback onReopen;
  final VoidCallback? onViewHistory;

  const ClosedJobCard({
    super.key,
    required this.job,
    required this.onReopen,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loc.statusClosed,
                  style: const TextStyle(
                    color: AppColors.error,
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
                '${job.applicationCount} ${loc.applicants}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Flexible(
                child: GestureDetector(
                  onTap: onViewHistory,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AdaptiveButtonLabel(
                      text: loc.viewHistory,
                      style: const TextStyle(color: AppColors.primary),
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
                  onPressed: onReopen,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: AdaptiveButtonLabel(text: loc.reopen),
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
            ],
          ),
        ],
      ),
    );
  }
}
