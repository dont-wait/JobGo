import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';

class SocialLoginRow extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onFacebookTap;

  const SocialLoginRow({
    super.key,
    required this.onGoogleTap,
    required this.onFacebookTap,
  });

  Widget _socialItem(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Image.asset(assetPath, width: 24, height: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialItem('assets/icons/google.png', onGoogleTap),
        const SizedBox(width: 20),
        _socialItem('assets/icons/facebook.jpg', onFacebookTap),
      ],
    );
  }
}
