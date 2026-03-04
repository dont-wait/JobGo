import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class PreviewCompanyHeader extends StatelessWidget {
  const PreviewCompanyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2937),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'TechFlow Inc.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'San Francisco, CA',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: AppColors.success, size: 18),
              const Text(
                ' • Verified',
                style: TextStyle(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            'Senior Flutter Developer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
