import 'package:flutter/material.dart';

import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class SkillChipSelector extends StatelessWidget {
  final List<String> selectedSkills;
  final ValueChanged<List<String>> onChanged;

  const SkillChipSelector({
    super.key,
    required this.selectedSkills,
    required this.onChanged,
  });

  static const List<String> suggestedSkills = [
    'Figma',
    'UI Design',
    'Flutter',
    'React',
    'Communication',
    'Leadership',
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.addSkills,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedSkills.map(
              (skill) => Chip(
                label: Text(_skillLabel(loc, skill)),
                deleteIconColor: AppColors.error,
                onDeleted: () {
                  final newList = List<String>.from(selectedSkills)
                    ..remove(skill);
                  onChanged(newList);
                },
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            ),
            ...suggestedSkills
                .where((s) => !selectedSkills.contains(s))
                .map(
                  (skill) => ActionChip(
                    label: Text(_skillLabel(loc, skill)),
                    onPressed: () {
                      final newList = List<String>.from(selectedSkills)
                        ..add(skill);
                      onChanged(newList);
                    },
                  ),
                ),
            ActionChip(
              label: Text(loc.addCustom),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.customSkillComingSoon)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  String _skillLabel(AppLocalizations loc, String skill) {
    switch (skill) {
      case 'Figma':
        return loc.figma;
      case 'UI Design':
        return loc.uiDesign;
      case 'Flutter':
        return loc.flutter;
      case 'React':
        return loc.react;
      case 'Communication':
        return loc.communication;
      case 'Leadership':
        return loc.leadership;
      default:
        return skill;
    }
  }
}
