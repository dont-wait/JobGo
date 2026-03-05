import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class UserTypeTabs extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;

  const UserTypeTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildTab(Icons.person, 'Candidates'),
          const SizedBox(width: 12),
          _buildTab(Icons.business, 'Employers'),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    final isSelected = selectedTab == label;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
