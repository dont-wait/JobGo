import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const HomeSearchBar({super.key, this.onTap, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.searchPrimaryBar,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.searchPrimaryBarText,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onTap: onTap,
                cursorColor: AppColors.searchPrimaryBarText,
                decoration: const InputDecoration(
                  hintText: 'Search jobs, companies...',
                  hintStyle: TextStyle(
                    color: AppColors.searchPrimaryBarText,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  color: AppColors.searchPrimaryBarText,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
