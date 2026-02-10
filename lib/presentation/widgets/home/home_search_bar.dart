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
          color: AppColors.searchPrimaryBar,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.searchPrimaryBarText, size: 22),
            SizedBox(width: 12),
            Text(
              'Search jobs, companies...',
              style: TextStyle(
                color: AppColors.searchPrimaryBarText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
