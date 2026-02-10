import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  Widget _socialItem(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Image.asset(
        assetPath,
        width: 24,
        height: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: _socialItem('assets/icons/google.png'),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {},
          child: _socialItem('assets/icons/facebook.jpg'),
        ),
      ],
    );
  }
}
