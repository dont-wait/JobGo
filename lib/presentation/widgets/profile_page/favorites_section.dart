import 'package:flutter/material.dart';
import '../../../core/configs/theme/app_colors.dart';

class FavoritesSection extends StatelessWidget {
  const FavoritesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),

        const _FavoriteJobCard(
          title: 'Senior Product Designer',
          company: 'Global Design Systems',
          location: 'London, UK (Remote)',
          salary: '\$85k - \$110k',
        ),
        const SizedBox(height: 12),

        const _FavoriteJobCard(
          title: 'Lead UX Researcher',
          company: 'Fintech Innovators',
          location: 'Berlin, DE',
          salary: '\$75k - \$95k',
        ),
        const SizedBox(height: 12),

        const _FavoriteJobCard(
          title: 'Mobile Interface Specialist',
          company: 'Digital Trends Lab',
          location: 'New York, NY',
          salary: '\$130k - \$160k',
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: const [
        Text(
          'Bookmarked Jobs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Spacer(),
        Text(
          '3 SAVED',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// JOB CARD 

class _FavoriteJobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String salary;

  const _FavoriteJobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
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
                  salary,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.bookmark,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.searchPrimaryBar,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.business,
        color: AppColors.searchPrimaryBarText,
      ),
    );
  }
}
