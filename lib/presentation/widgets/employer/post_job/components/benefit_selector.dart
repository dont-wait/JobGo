import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class BenefitSelector extends StatelessWidget {
  final List<String> selectedBenefits;
  final ValueChanged<List<String>> onChanged;

  const BenefitSelector({
    super.key,
    required this.selectedBenefits,
    required this.onChanged,
  });

  static const List<String> allBenefits = [
    'Health Insurance',
    'Gym',
    'Bonus',
    'Remote Work',
    'Paid Leave',
    'Flexible Hours',
    'Stock Options',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Benefits & Perks',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allBenefits.map((benefit) {
            final isSelected = selectedBenefits.contains(benefit);
            return FilterChip(
              selected: isSelected,
              label: Text(benefit),
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
              onSelected: (selected) {
                final newList = List<String>.from(selectedBenefits);
                if (selected) {
                  newList.add(benefit);
                } else {
                  newList.remove(benefit);
                }
                onChanged(newList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
