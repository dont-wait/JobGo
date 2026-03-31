import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

/// Nút "Apply Now" cố định ở dưới trang chi tiết
class JobApplyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isEnabled;
  final bool isLoading;

  const JobApplyButton({
    super.key,
    this.onPressed,
    this.label = 'Apply Now',
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (isEnabled && !isLoading) ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? AppColors.primary : AppColors.border,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textHint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}
