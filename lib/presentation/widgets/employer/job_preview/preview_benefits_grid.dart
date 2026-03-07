import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class PreviewBenefitsGrid extends StatelessWidget {
  const PreviewBenefitsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      {'title': 'Health & Dental', 'subtitle': 'Premium coverage'},
      {'title': 'Equity Options', 'subtitle': 'Stock incentives'},
      {'title': 'Learning Budget', 'subtitle': '\$2,500/year stipend'},
      {'title': 'Work from Anywhere', 'subtitle': 'Fully remote options'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Benefits',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final b = benefits[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      b['title']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b['subtitle']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
