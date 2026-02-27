import 'package:flutter/material.dart';
import 'experience_item.dart';
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Work Experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const ExperienceItem(
          title: 'Senior UI/UX Designer',
          company: 'TechCorp Solutions',
          time: 'Jan 2022 - Present · 2 yrs 4 mos',
          description:
              '• Lead design for core SaaS platform\n'
              '• Collaborated with cross-functional teams\n'
              '• Implemented unified design system',
        ),
        const ExperienceItem(
          title: 'Product Designer',
          company: 'DesignFlow Agency',
          time: 'Mar 2019 - Dec 2021 · 2 yrs 10 mos',
          description:
              '• Delivered high-fidelity prototypes\n'
              '• Designed projects in Fintech & EdTech',
        ),
        const ExperienceItem(
          title: 'Junior Designer',
          company: 'StartupHub',
          time: 'Jun 2017 - Feb 2019 · 1 yr 9 mos',
          description:
              '• Assisted senior designers\n'
              '• Built UI components for startups',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add New Experience'),
        ),
      ],
    );
  }
}
