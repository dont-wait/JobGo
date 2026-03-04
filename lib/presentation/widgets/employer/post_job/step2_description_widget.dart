import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/components/skill_chip_selector.dart';

class Step2DescriptionWidget extends StatelessWidget {
  final TextEditingController descriptionController;
  final TextEditingController requirementsController;
  final List<String> selectedSkills;
  final ValueChanged<List<String>> onSkillsChanged;

  const Step2DescriptionWidget({
    super.key,
    required this.descriptionController,
    required this.requirementsController,
    required this.selectedSkills,
    required this.onSkillsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Description',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Describe the role, responsibilities...',
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Requirements & Skills',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: requirementsController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'E.g. 5+ years experience with Figma...',
          ),
        ),
        const SizedBox(height: 16),

        SkillChipSelector(
          selectedSkills: selectedSkills,
          onChanged: onSkillsChanged,
        ),
      ],
    );
  }
}
