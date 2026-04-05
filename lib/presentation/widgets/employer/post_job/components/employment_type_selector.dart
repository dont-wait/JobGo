import 'package:flutter/material.dart';

import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class EmploymentTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;
  final List<String> types;

  const EmploymentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.types = const ['Full-time', 'Part-time', 'Remote', 'Contract'],
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final availableTypes = List<String>.from(types);
    if (selectedType.isNotEmpty && !availableTypes.contains(selectedType)) {
      availableTypes.insert(0, selectedType);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.employmentType,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTypes.map((type) {
            final isSelected = selectedType == type;
            return GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  _typeLabel(loc, type),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _typeLabel(AppLocalizations loc, String type) {
    switch (type) {
      case 'Full-time':
        return loc.fullTime;
      case 'Part-time':
        return loc.partTime;
      case 'Remote':
        return loc.remote;
      case 'Contract':
        return loc.contract;
      case 'Freelance':
        return loc.freelance;
      case 'Internship':
        return loc.internship;
      default:
        return type;
    }
  }
}
