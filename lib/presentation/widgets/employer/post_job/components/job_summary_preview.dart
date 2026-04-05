import 'package:flutter/material.dart';

import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/employer_job_model.dart';

class JobSummaryPreview extends StatelessWidget {
  final EmployerJobModel job;

  const JobSummaryPreview({super.key, required this.job});

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.work_outline, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  job.title.isEmpty ? loc.untitledJob : job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip(Icons.location_on_outlined, job.location),
              _buildMetaChip(
                Icons.work_outline,
                _employmentTypeLabel(loc, job.employmentType),
              ),
              _buildMetaChip(
                Icons.people_outline,
                _positionsLabel(loc, job.positions),
              ),
              _buildMetaChip(
                Icons.event_outlined,
                _deadlineLabel(loc, job.deadline),
              ),
              _buildMetaChip(Icons.payments_outlined, _salaryLabel(loc, job)),
            ].where((widget) => widget != null).cast<Widget>().toList(),
          ),
        ],
      ),
    );
  }

  String _employmentTypeLabel(AppLocalizations loc, String type) {
    switch (type) {
      case 'Full-time':
        return loc.fullTime;
      case 'Part-time':
        return loc.partTime;
      case 'Remote':
        return loc.remote;
      case 'Contract':
        return loc.contract;
      case 'Freelance':
        return loc.freelance;
      case 'Internship':
        return loc.internship;
      default:
        return type;
    }
  }

  String _positionsLabel(AppLocalizations loc, int positions) {
    return positions <= 1 ? '1 ${loc.opening}' : '$positions ${loc.openings}';
  }

  String _deadlineLabel(AppLocalizations loc, DateTime? deadline) {
    if (deadline == null) return '';
    return '${loc.applicationDeadline}: ${deadline.day.toString().padLeft(2, '0')}/${deadline.month.toString().padLeft(2, '0')}/${deadline.year}';
  }

  String _salaryLabel(AppLocalizations loc, EmployerJobModel job) {
    if (job.salaryNegotiable &&
        job.salaryMin == null &&
        job.salaryMax == null) {
      return loc.negotiable;
    }

    if (job.salaryMin != null && job.salaryMax != null) {
      return '\$${_compactMoney(job.salaryMin!)} - \$${_compactMoney(job.salaryMax!)}';
    }

    if (job.salaryMin != null) {
      return '${loc.fromSalary} \$${_compactMoney(job.salaryMin!)}';
    }

    if (job.salaryMax != null) {
      return '${loc.upToSalary} \$${_compactMoney(job.salaryMax!)}';
    }

    if (job.salaryValue != null && job.salaryValue! > 0) {
      return '\$${_compactMoney(job.salaryValue!)}';
    }

    return loc.negotiable;
  }

  String _compactMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.0+$'), '');
  }

  Widget _buildMetaChip(IconData icon, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
