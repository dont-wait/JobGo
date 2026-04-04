import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/admin_user_model.dart';

class UserDetailDialog extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onDelete;

  const UserDetailDialog({
    super.key,
    required this.user,
    required this.onBlock,
    required this.onUnblock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user.name.trim().isEmpty ? 'Unknown User' : user.name;
    final avatarInitial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    avatarInitial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // User Details
            _buildDetailRow(Icons.email, 'Email', user.email),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.access_time,
              'Member Since',
              _formatDate(user.createdAt),
            ),
            if (user.lastActive != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.schedule,
                'Last Active',
                _getLastActiveText(user.lastActive!),
              ),
            ],
            if (user.title != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.work, 'Title', user.title!),
            ],
            if (user.company != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.business, 'Company', user.company!),
            ],
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.info,
              'Status',
              user.status.toUpperCase(),
              valueColor: user.status == 'blocked'
                  ? AppColors.error
                  : AppColors.success,
            ),
            
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: user.status == 'blocked' ? onUnblock : onBlock,
                    icon: Icon(
                      user.status == 'blocked' ? Icons.lock_open : Icons.block,
                      size: 18,
                    ),
                    label: Text(
                      user.status == 'blocked' ? 'Unblock' : 'Block User',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user.status == 'blocked'
                          ? AppColors.success
                          : AppColors.warning,
                      side: BorderSide(
                        color: user.status == 'blocked'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getLastActiveText(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
