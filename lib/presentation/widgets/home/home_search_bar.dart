import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const HomeSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.textHint, size: 22),
            SizedBox(width: 12),
            Text(
              'Search jobs, companies...',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
