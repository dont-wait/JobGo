import 'package:flutter/material.dart';
import 'package:jobgo/data/models/employer_job_model.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/components/benefit_selector.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/components/job_summary_preview.dart';

class Step3PerksSalaryWidget extends StatelessWidget {
  final TextEditingController minSalaryController;
  final TextEditingController maxSalaryController;
  final TextEditingController positionsController;
  final TextEditingController deadlineController;
  final bool salaryNegotiable;
  final DateTime? selectedDeadline;
  final ValueChanged<bool> onSalaryNegotiableChanged;
  final ValueChanged<DateTime?> onDeadlineChanged;
  final List<String> selectedBenefits;
  final ValueChanged<List<String>> onBenefitsChanged;
  final EmployerJobModel previewJob;

  const Step3PerksSalaryWidget({
    super.key,
    required this.minSalaryController,
    required this.maxSalaryController,
    required this.positionsController,
    required this.deadlineController,
    required this.salaryNegotiable,
    required this.selectedDeadline,
    required this.onSalaryNegotiableChanged,
    required this.onDeadlineChanged,
    required this.selectedBenefits,
    required this.onBenefitsChanged,
    required this.previewJob,
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
        const SizedBox(height: 12),

        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: salaryNegotiable,
          onChanged: onSalaryNegotiableChanged,
          title: const Text(
            'Salary negotiable',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Let candidates know salary can be discussed.'),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: positionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Open positions'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: deadlineController,
                readOnly: true,
                onTap: () => _pickDeadline(context),
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  suffixIcon: Icon(Icons.calendar_month_outlined),
                ),
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

        JobSummaryPreview(job: previewJob),
      ],
    );
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDeadline ?? now.add(const Duration(days: 14));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      onDeadlineChanged(pickedDate);
    }
  }
}
