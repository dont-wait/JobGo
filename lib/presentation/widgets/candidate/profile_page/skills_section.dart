// import 'package:flutter/material.dart';
// import '../../../../core/configs/theme/app_colors.dart';

// class SkillsSection extends StatelessWidget {
//   const SkillsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSearchBox(),
//         const SizedBox(height: 20),

//         _buildSkillGroup(
//           title: 'Design',
//           skills: ['Figma', 'Adobe XD', 'UI Design', 'Prototyping'],
//         ),

//         _buildSkillGroup(
//           title: 'Development',
//           skills: ['Flutter', 'Dart', 'React'],
//         ),

//         _buildSkillGroup(
//           title: 'Soft Skills',
//           skills: ['Leadership', 'Communication', 'Problem Solving'],
//         ),

//         const SizedBox(height: 24),
//         _buildSuggested(),
//       ],
//     );
//   }

//   // Search box 
//   Widget _buildSearchBox() {
//     return TextField(
//       decoration: InputDecoration(
//         hintText: 'Add a skill...',
//         prefixIcon: const Icon(Icons.search),
//       ),
//     );
//   }

//   // Skill group 
//   Widget _buildSkillGroup({
//     required String title,
//     required List<String> skills,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const Spacer(),
//             Text(
//               '${skills.length} skills',
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: skills.map((skill) => _SkillChip(skill)).toList(),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   // Suggested 
//   Widget _buildSuggested() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Suggested for your profile',
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: const [
//             _SuggestedChip('UX Research'),
//             _SuggestedChip('Accessibility'),
//             _SuggestedChip('Design Systems'),
//           ],
//         ),
//       ],
//     );
//   }
// }

// // CHIP 

// class _SkillChip extends StatelessWidget {
//   final String label;

//   const _SkillChip(this.label);

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       label: Text(label),
//       deleteIcon: const Icon(Icons.close, size: 16),
//       onDeleted: () {},
//       backgroundColor: AppColors.searchPrimaryBar,
//       labelStyle: const TextStyle(
//         color: AppColors.searchPrimaryBarText,
//         fontWeight: FontWeight.w500,
//       ),
//     );
//   }
// }

// class _SuggestedChip extends StatelessWidget {
//   final String label;

//   const _SuggestedChip(this.label);

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       label: Text('+ $label'),
//       backgroundColor: AppColors.divider,
//       labelStyle: const TextStyle(
//         color: AppColors.textSecondary,
//         fontWeight: FontWeight.w500,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';

class SkillsSection extends StatelessWidget {
  final String? skills;

  const SkillsSection({super.key, this.skills});

  // ✅ Parse chuỗi skills thành list
  List<String> get _skillList {
    if (skills == null || skills!.trim().isEmpty) return [];
    return skills!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final skillList = _skillList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBox(),
        const SizedBox(height: 20),

        if (skillList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No skills added yet.\nUpdate your profile to add skills.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          _buildSkillGroup(title: 'My Skills', skills: skillList),

        const SizedBox(height: 24),
        _buildSuggested(),
      ],
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Add a skill...',
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildSkillGroup({
    required String title,
    required List<String> skills,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimary,
              )),
            const Spacer(),
            Text('${skills.length} skills',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) => _SkillChip(skill)).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSuggested() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Suggested for your profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _SuggestedChip('UX Research'),
            _SuggestedChip('Accessibility'),
            _SuggestedChip('Design Systems'),
          ],
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {},
      backgroundColor: AppColors.searchPrimaryBar,
      labelStyle: const TextStyle(
        color: AppColors.searchPrimaryBarText,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SuggestedChip extends StatelessWidget {
  final String label;
  const _SuggestedChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('+ $label'),
      backgroundColor: AppColors.divider,
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}