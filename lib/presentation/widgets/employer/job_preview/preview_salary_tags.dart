import 'package:flutter/material.dart';

import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/employer_job_model.dart';

class PreviewSalaryTags extends StatelessWidget {
  final EmployerJobModel job;

  const PreviewSalaryTags({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Text(
            job.salaryLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (job.employmentType.isNotEmpty)
                _buildTag(job.employmentType, Icons.work_outline),
              if (job.category.isNotEmpty)
                _buildTag(job.category, Icons.category_outlined),
              _buildTag(job.positionsLabel, Icons.people_outline),
              if (job.deadline != null)
                _buildTag(job.deadlineLabel, Icons.event_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
