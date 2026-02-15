import 'package:flutter/material.dart';
import '../../../core/configs/theme/app_colors.dart';

class ExperienceItem extends StatelessWidget {
  final String title;
  final String company;
  final String time;
  final String description;

  const ExperienceItem({
    super.key,
    required this.title,
    required this.company,
    required this.time,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.work, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(company,
                    style: const TextStyle(color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(time,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint)),
                const SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
