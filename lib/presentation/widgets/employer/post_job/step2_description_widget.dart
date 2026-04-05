import 'package:flutter/material.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
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
        Text(
          AppLocalizations.of(context).jobDescription,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: '${AppLocalizations.of(context).description}...',
          ),
        ),
        const SizedBox(height: 24),

        Text(
          AppLocalizations.of(context).jobRequirements,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: requirementsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).experienceExampleHint,
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
