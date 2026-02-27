import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';

class UploadResumeBox extends StatelessWidget {
  const UploadResumeBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.upload, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload a new resume',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PDF, DOCX up to 10MB',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Browse Files'),
          ),
        ],
      ),
    );
  }
}
