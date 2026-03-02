import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_jobs.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';
import 'package:jobgo/presentation/pages/candidate/job_detail/job_detail_page.dart';
import 'package:jobgo/presentation/pages/candidate/apply_job/apply_job_route.dart';

/// Card hiển thị 1 kết quả tìm kiếm công việc
class SearchJobCard extends StatelessWidget {
  final MockJob job;

  const SearchJobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobDetailPage(job: job)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Logo + Title + Company + Bookmark ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanyLogo(
                  imageUrl: job.logoUrl,
                  fallbackText: job.logoText,
                  backgroundColor: Color(int.parse(job.logoColor)),
                  width: 48,
                  height: 48,
                  borderRadius: 12,
                  fontSize: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                if (job.badge != null) _buildBadge(job.badge!),
              ],
            ),

            const SizedBox(height: 12),

            // ── Row 2: Location + Salary ──
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location.isNotEmpty ? job.location : 'Remote',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  job.salary.isNotEmpty ? job.salary : '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Row 3: Tags ──
            if (job.tags != null && job.tags!.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: job.tags!.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),

            if (job.tags != null && job.tags!.isNotEmpty)
              const SizedBox(height: 12),

            // ── Row 4: Posted time + Apply button ──
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  job.postedTime.isNotEmpty ? job.postedTime : 'Recently',
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
                if (job.applicants != null && job.applicants! > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${job.applicants} applicants',
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => navigateToApply(context, job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Apply Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String badge) {
    final isUrgent = badge.toUpperCase() == 'URGENT';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        badge,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isUrgent ? AppColors.error : AppColors.primary,
        ),
      ),
    );
  }
}
