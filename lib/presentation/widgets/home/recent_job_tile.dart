import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_jobs.dart';

class RecentJobTile extends StatelessWidget {
  final MockJob job;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;

  const RecentJobTile({
    super.key,
    required this.job,
    this.onTap,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(job.logoColor));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Company logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  job.logoText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Job info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.company,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Bookmark button
            IconButton(
              onPressed: onBookmark,
              icon: Icon(
                job.isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_border_outlined,
                color: job.isBookmarked
                    ? AppColors.primary
                    : AppColors.textHint,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
