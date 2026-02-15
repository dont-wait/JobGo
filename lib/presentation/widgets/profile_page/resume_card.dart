import 'package:flutter/material.dart';
import '../../../core/configs/theme/app_colors.dart';

class ResumeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDefault;

  const ResumeCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.searchPrimaryBar,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.searchPrimaryBar,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'DEFAULT',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.searchPrimaryBarText,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
