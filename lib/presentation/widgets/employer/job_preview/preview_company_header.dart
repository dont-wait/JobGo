import 'package:flutter/material.dart';

import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/employer_job_model.dart';

class PreviewCompanyHeader extends StatelessWidget {
  final EmployerJobModel job;

  const PreviewCompanyHeader({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final logoColor = _parseColor(job.companyLogoColor);
    final hasLogoUrl = job.companyLogoUrl.trim().isNotEmpty;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: logoColor,
              borderRadius: BorderRadius.circular(16),
              image: hasLogoUrl
                  ? DecorationImage(
                      image: NetworkImage(job.companyLogoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasLogoUrl
                ? null
                : Center(
                    child: Text(
                      job.companyLogoText,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            job.companyName.isEmpty ? 'Unknown Company' : job.companyName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                job.location.isEmpty ? 'Location not set' : job.location,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: AppColors.success, size: 18),
              const Text(
                ' • Verified',
                style: TextStyle(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.title.isEmpty ? 'Untitled Job' : job.title,
            style: const TextStyle(
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

  Color _parseColor(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return const Color(0xFF1E2937);

    var hex = normalized;
    if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    }
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }

    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return const Color(0xFF1E2937);

    // Normalize 24-bit RGB values (RRGGBB) to opaque ARGB.
    final argb = parsed <= 0x00FFFFFF ? (parsed | 0xFF000000) : parsed;
    return Color(argb);
  }
}
