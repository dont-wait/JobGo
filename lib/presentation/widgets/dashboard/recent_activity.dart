import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/dashboard_model.dart';

class RecentActivityList extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityList({
    super.key,
    required this.activities,
  });

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.mail_outline;
      case 'posting':
        return Icons.article_outlined;
      case 'view':
        return Icons.visibility_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'application':
        return AppColors.success;
      case 'posting':
        return AppColors.primary;
      case 'view':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activities.map((activity) => _buildActivityItem(activity)).toList(),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    final color = _getActivityColor(activity.type);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(activity.type),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(activity.timestamp),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
