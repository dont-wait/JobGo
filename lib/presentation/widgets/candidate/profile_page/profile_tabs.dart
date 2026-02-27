import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';

class ProfileTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const ProfileTabs({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  static const _tabs = [
    'Info',
    'Experience',
    'Skills',
    'Favorites',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        _tabs.length,
        (index) => _TabItem(
          title: _tabs[index],
          isActive: currentIndex == index,
          onTap: () => onChanged(index),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isActive ? AppColors.primary : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
