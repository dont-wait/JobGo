import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Applications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Theo dõi đơn ứng tuyển',
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
