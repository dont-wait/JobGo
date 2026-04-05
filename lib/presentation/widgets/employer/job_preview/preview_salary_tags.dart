import 'package:flutter/material.dart';

import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/employer_job_model.dart';

class PreviewSalaryTags extends StatelessWidget {
  final EmployerJobModel job;

  const PreviewSalaryTags({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
                _buildTag(
                  _employmentTypeLabel(loc, job.employmentType),
                  Icons.work_outline,
                ),
              if (job.category.isNotEmpty)
                _buildTag(
                  _categoryLabel(loc, job.category),
                  Icons.category_outlined,
                ),
              _buildTag(
                _positionsLabel(loc, job.positions),
                Icons.people_outline,
              ),
              if (job.deadline != null)
                _buildTag(
                  _deadlineLabel(loc, job.deadline!),
                  Icons.event_outlined,
                ),
            ],
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

  String _categoryLabel(AppLocalizations loc, String category) {
    switch (category) {
      case 'Software Development':
        return loc.softwareDevelopment;
      case 'Design & Creative':
        return loc.designCreative;
      case 'Product Management':
        return loc.productManagement;
      case 'Data Science & Analytics':
        return loc.dataScienceAnalytics;
      case 'DevOps & Infrastructure':
        return loc.devOpsInfrastructure;
      case 'Marketing & Growth':
        return loc.marketingGrowth;
      case 'Sales & Business Development':
        return loc.salesBusinessDevelopment;
      case 'Human Resources':
        return loc.humanResources;
      case 'Finance & Accounting':
        return loc.financeAccounting;
      case 'Operations & Administration':
        return loc.operationsAdministration;
      default:
        return category;
    }
  }

  String _positionsLabel(AppLocalizations loc, int positions) {
    return positions <= 1 ? '1 ${loc.opening}' : '$positions ${loc.openings}';
  }

  String _deadlineLabel(AppLocalizations loc, DateTime deadline) {
    return '${loc.applicationDeadline}: ${deadline.day.toString().padLeft(2, '0')}/${deadline.month.toString().padLeft(2, '0')}/${deadline.year}';
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
