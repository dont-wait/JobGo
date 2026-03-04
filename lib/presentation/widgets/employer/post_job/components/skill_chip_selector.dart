import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Skills', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedSkills.map(
              (skill) => Chip(
                label: Text(skill),
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
                    label: Text(skill),
                    onPressed: () {
                      final newList = List<String>.from(selectedSkills)
                        ..add(skill);
                      onChanged(newList);
                    },
                  ),
                ),
            ActionChip(
              label: const Text('+ Add Custom'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom skill coming soon')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
