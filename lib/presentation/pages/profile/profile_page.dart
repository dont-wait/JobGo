import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hồ sơ cá nhân',
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
