import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Search',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tìm kiếm công việc phù hợp',
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
