import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class PreviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const PreviewSection({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
