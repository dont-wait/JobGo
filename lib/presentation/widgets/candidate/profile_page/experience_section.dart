// import 'package:flutter/material.dart';
// import 'experience_item.dart';
// class ExperienceSection extends StatelessWidget {
//   const ExperienceSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Work Experience',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             TextButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.add, size: 18),
//               label: const Text('Add'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         const ExperienceItem(
//           title: 'Senior UI/UX Designer',
//           company: 'TechCorp Solutions',
//           time: 'Jan 2022 - Present · 2 yrs 4 mos',
//           description:
//               '• Lead design for core SaaS platform\n'
//               '• Collaborated with cross-functional teams\n'
//               '• Implemented unified design system',
//         ),
//         const ExperienceItem(
//           title: 'Product Designer',
//           company: 'DesignFlow Agency',
//           time: 'Mar 2019 - Dec 2021 · 2 yrs 10 mos',
//           description:
//               '• Delivered high-fidelity prototypes\n'
//               '• Designed projects in Fintech & EdTech',
//         ),
//         const ExperienceItem(
//           title: 'Junior Designer',
//           company: 'StartupHub',
//           time: 'Jun 2017 - Feb 2019 · 1 yr 9 mos',
//           description:
//               '• Assisted senior designers\n'
//               '• Built UI components for startups',
//         ),
//         const SizedBox(height: 12),
//         OutlinedButton.icon(
//           onPressed: () {},
//           icon: const Icon(Icons.add),
//           label: const Text('Add New Experience'),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'experience_item.dart';

class ExperienceSection extends StatelessWidget {
  final String? experience;

  const ExperienceSection({super.key, this.experience});

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ✅ Hiển thị data thật hoặc thông báo trống
        if (experience == null || experience!.trim().isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No experience added yet.\nTap Add to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ExperienceItem(
            title: 'Experience',
            company: '',
            time: '',
            description: experience!,
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