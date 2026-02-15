import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

/// Section "About the Role" trong trang chi tiết công việc
class JobDescriptionSection extends StatelessWidget {
  final String description;

  const JobDescriptionSection({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the Role',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
