import 'package:flutter/material.dart';

import 'package:jobgo/data/models/employer_job_model.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/widgets/employer/applicants/job_applicants_page.dart';

class PublishedJobCard extends StatelessWidget {
  final EmployerJobModel job;
  final VoidCallback onEdit;
  final VoidCallback onBoost;

  const PublishedJobCard({
    super.key,
    required this.job,
    required this.onEdit,
    required this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
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
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
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
            job.title.isEmpty ? 'Untitled Job' : job.title,
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
                '$applicantCount Applicants',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: jobId.isEmpty
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobApplicantsPage(
                            jobTitle: job.title.isEmpty
                                ? 'Untitled Job'
                                : job.title,
                            totalApplicants: applicantCount,
                            jobId: jobId,
                          ),
                        ),
                      ),
                child: const Text(
                  'View Applicants →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
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
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onBoost,
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('Boost'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
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
