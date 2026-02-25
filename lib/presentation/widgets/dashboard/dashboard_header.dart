import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/dashboard_model.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardStats stats;

  const DashboardHeader({
    super.key,
    required this.stats,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Employer Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Refresh dashboard
                  },
                  icon: const Icon(
                    Icons.refresh_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderStat(
                  label: 'Active',
                  value: stats.activePostings.toString(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildHeaderStat(
                  label: 'New Profiles',
                  value: stats.newProfiles.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
