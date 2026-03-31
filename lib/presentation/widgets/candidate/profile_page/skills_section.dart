
// import 'package:flutter/material.dart';
// import '../../../../core/configs/theme/app_colors.dart';

// class SkillsSection extends StatelessWidget {
//   final String? skills;

//   const SkillsSection({super.key, this.skills});

//   // Parse chuỗi skills thành list
//   List<String> get _skillList {
//     if (skills == null || skills!.trim().isEmpty) return [];
//     return skills!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final skillList = _skillList;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSearchBox(),
//         const SizedBox(height: 20),

//         if (skillList.isEmpty)
//           const Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 32),
//               child: Text(
//                 'No skills added yet.\nUpdate your profile to add skills.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           )
//         else
//           _buildSkillGroup(title: 'My Skills', skills: skillList),

//         const SizedBox(height: 24),
//         _buildSuggested(),
//       ],
//     );
//   }

//   Widget _buildSearchBox() {
//     return TextField(
//       decoration: InputDecoration(
//         hintText: 'Add a skill...',
//         prefixIcon: const Icon(Icons.search),
//       ),
//     );
//   }

//   Widget _buildSkillGroup({
//     required String title,
//     required List<String> skills,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//                 color: AppColors.textPrimary,
//               )),
//             const Spacer(),
//             Text('${skills.length} skills',
//               style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

//   Widget _buildSuggested() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Suggested for your profile',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/configs/theme/app_colors.dart';

class SkillsSection extends StatelessWidget {
  final String? skills;

  const SkillsSection({super.key, this.skills});

  List<String> get _skillList {
    if (skills == null || skills!.trim().isEmpty) return [];
    return skills!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final skillList = _skillList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        if (skillList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No skills added yet.\nTap Add to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          _buildSkillGroup(title: 'My Skills', skills: skillList),

        const SizedBox(height: 20),

        Center(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final newSkill = await showDialog<String>(
                context: context,
                builder: (_) => _AddSkillDialog(),
              );

              if (newSkill != null && newSkill.trim().isNotEmpty) {
                final supabase = Supabase.instance.client;
                final authUser = supabase.auth.currentUser;
                if (authUser == null) return;

                final userRow = await supabase
                    .from('users')
                    .select('u_id')
                    .eq('auth_uid', authUser.id)
                    .maybeSingle();

                if (userRow == null) return;
                final uId = userRow['u_id'] as int;

                final candidateRow = await supabase
                    .from('candidates')
                    .select('c_skill') // ✅ đúng tên cột
                    .eq('u_id', uId)
                    .maybeSingle();

                final currentSkills = candidateRow?['c_skill'] ?? '';
                final updatedSkills = currentSkills.isEmpty
                    ? newSkill
                    : '$currentSkills, $newSkill';

                await supabase
                    .from('candidates')
                    .update({'c_skill': updatedSkills}) // ✅ đúng tên cột
                    .eq('u_id', uId);

                context.read<ProfileProvider>().reloadProfile();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Add New Skill',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
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
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) => _SkillChip(skill)).toList(),
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
      backgroundColor: AppColors.searchPrimaryBar,
      labelStyle: const TextStyle(
        color: AppColors.searchPrimaryBarText,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _AddSkillDialog extends StatefulWidget {
  @override
  State<_AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<_AddSkillDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Skill'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter your skill',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}