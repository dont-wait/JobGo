import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class PostNewJobBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const PostNewJobBanner({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.work_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Need to hire?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Text(
            'Post a new job opportunity today',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Post New Job',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
