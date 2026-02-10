import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Messages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tin nhắn từ nhà tuyển dụng',
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
