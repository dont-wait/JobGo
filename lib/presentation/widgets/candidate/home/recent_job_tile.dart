import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/presentation/providers/bookmark_provider.dart';

class RecentJobTile extends StatelessWidget {
  final JobModel job;
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
    // Parse color string (e.g. 0xFF1A1A2E) to Color object safely
    final colorVal = job.logoColor.startsWith('0x')
        ? int.parse(job.logoColor.substring(2), radix: 16)
        : int.tryParse(job.logoColor) ?? 0xFF1A3A4A;
    final color = Color(0xFF000000 | colorVal);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Company logo
            CompanyLogo(
              imageUrl: job.logoUrl,
              fallbackText: job.logoText,
              backgroundColor: color,
            ),
            const SizedBox(width: 12),
            // Job info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        job.formattedSalary,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.postedTimeAgo,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 12,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${job.applicants ?? 0} applicants',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bookmark button
            Consumer<BookmarkProvider>(
              builder: (context, provider, child) {
                final isSaved = provider.isBookmarked(job.id);
                return IconButton(
                  onPressed: () => provider.toggleBookmark(job.id),
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
                    color: isSaved ? AppColors.warning : AppColors.textHint,
                    size: 22,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
