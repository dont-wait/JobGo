import 'package:flutter/material.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/components/benefit_selector.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/components/job_summary_preview.dart';

class Step3PerksSalaryWidget extends StatelessWidget {
  final TextEditingController minSalaryController;
  final TextEditingController maxSalaryController;
  final List<String> selectedBenefits;
  final ValueChanged<List<String>> onBenefitsChanged;

  const Step3PerksSalaryWidget({
    super.key,
    required this.minSalaryController,
    required this.maxSalaryController,
    required this.selectedBenefits,
    required this.onBenefitsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Salary Range',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minSalaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minimum (USD)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxSalaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Maximum (USD)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        BenefitSelector(
          selectedBenefits: selectedBenefits,
          onChanged: onBenefitsChanged,
        ),
        const SizedBox(height: 24),

        JobSummaryPreview(
          jobTitle: 'Senior UI/UX Designer',
          location: 'New York, NY (Hybrid)',
          experience: '5+ Years',
        ),
      ],
    );
  }
}
