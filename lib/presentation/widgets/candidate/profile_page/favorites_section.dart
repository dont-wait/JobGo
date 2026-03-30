import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';
import 'package:jobgo/presentation/pages/candidate/job_detail/job_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/presentation/providers/bookmark_provider.dart';

class FavoritesSection extends StatefulWidget {
  const FavoritesSection({super.key});

  @override
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final savedJobs = provider.savedJobs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(savedJobs.length),
            const SizedBox(height: 16),
            if (savedJobs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No bookmarked jobs yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...savedJobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FavoriteJobCard(
                    job: job,
                    onUnsave: () => provider.toggleBookmark(job.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(int count) {
    return Row(
      children: [
        const Text(
          'Bookmarked Jobs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          '$count SAVED',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FavoriteJobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onUnsave;

  const _FavoriteJobCard({required this.job, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailPage(job: job.toMockJob()),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompanyLogo(
              imageUrl: job.logoUrl,
              fallbackText: job.logoText,
              backgroundColor: Color(int.parse(job.logoColor)),
              width: 44,
              height: 44,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    job.salary,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onUnsave,
              icon: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
