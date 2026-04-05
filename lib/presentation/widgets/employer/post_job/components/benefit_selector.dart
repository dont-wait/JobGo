import 'package:flutter/material.dart';

import 'package:jobgo/core/localization/app_localizations.dart';
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
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.perksAndBenefits,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allBenefits.map((benefit) {
            final isSelected = selectedBenefits.contains(benefit);
            return FilterChip(
              selected: isSelected,
              label: Text(_benefitLabel(loc, benefit)),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
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

  String _benefitLabel(AppLocalizations loc, String benefit) {
    switch (benefit) {
      case 'Health Insurance':
        return loc.healthInsurance;
      case 'Gym':
        return loc.gym;
      case 'Bonus':
        return loc.bonus;
      case 'Remote Work':
        return loc.remoteWork;
      case 'Paid Leave':
        return loc.paidLeave;
      case 'Flexible Hours':
        return loc.flexibleHours;
      case 'Stock Options':
        return loc.stockOptions;
      default:
        return benefit;
    }
  }
}
