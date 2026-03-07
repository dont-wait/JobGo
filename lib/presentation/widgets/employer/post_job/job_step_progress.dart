import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class JobStepProgress extends StatelessWidget {
  final int currentStep;

  const JobStepProgress({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    List<Widget> buildSteps() {
      List<Widget> children = [];
      for (int i = 0; i < 3; i++) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isCompleted = step < currentStep;

        children.add(
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : isActive
                  ? AppColors.primary
                  : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: isCompleted || isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );

        if (i < 2) {
          children.add(
            Expanded(
              child: Container(
                height: 3,
                color: step < currentStep
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
          );
        }
      }
      return children;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 40.0, right: 40.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildSteps(),
        ),
      ),
    );
  }
}
