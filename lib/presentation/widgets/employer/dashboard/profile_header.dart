import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class DashboardProfileHeader extends StatelessWidget {
  const DashboardProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with logo and icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left section - Logo and Company
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.work_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DODY MENTORING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Alex Sterling',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Right section - Icons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      // TODO: Search functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      // TODO: Notifications
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
