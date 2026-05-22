
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jobgo/data/models/experience_model.dart';
// import 'package:jobgo/presentation/providers/profile_provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'experience_item.dart';

// class ExperienceSection extends StatelessWidget {
//   final List<ExperienceModel>? experience;
//   final int? cId;


//   const ExperienceSection({super.key, this.experience, this.cId});
//   // List<String> get _experienceList {
//   //   if (experience == null || experience!.trim().isEmpty) return [];
//   //   return experience!
//   //       .split(',')
//   //       .map((e) => e.trim())
//   //       .where((e) => e.isNotEmpty)
//   //       .toList();
//   // }


//   @override
//   Widget build(BuildContext context) {
//      final experiences = _experienceList;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Work Experience',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             // TextButton.icon(
//             //   onPressed: () {},
//             //   icon: const Icon(Icons.add, size: 18),
//             //   label: const Text('Add'),
//             // ),
//           ],
//         ),
//         const SizedBox(height: 12),

//         // Hiển thị data thật hoặc thông báo trống
//         if (experience == null || experience!.trim().isEmpty)
//           const Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 32),
//               child: Text(
//                 'No experience added yet.\nTap Add to get started.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           )
//         else
//           // ExperienceItem(
//           //   title: 'Experience',
//           //   company: '',
//           //   time: '',
//           //   description: experience!,
//           // ),
//           Column(
//             children: experiences.map((exp) {
//               return ExperienceItem(
//                 title: 'Experience',
//                 company: '',
//                 time: '',
//                 description: exp,
//               );
//             }).toList(),
//           ),


//         const SizedBox(height: 12),
//         // OutlinedButton.icon(
//         //   onPressed: () {},
//         //   icon: const Icon(Icons.add),
//         //   label: const Text('Add New Experience'),
//         // ),
//         OutlinedButton.icon(
//           onPressed: () async {
//             final newExp = await showDialog<String>(
//               context: context,
//               builder: (_) => _AddExperienceDialog(),
//             );

//             if (newExp != null && newExp.trim().isNotEmpty) {
//               final supabase = Supabase.instance.client;
//               final authUser = supabase.auth.currentUser;
//               if (authUser == null) return;

//               // Lấy u_id
//               final userRow = await supabase
//                   .from('users')
//                   .select('u_id')
//                   .eq('auth_uid', authUser.id)
//                   .maybeSingle();

//               if (userRow == null) return;
//               final uId = userRow['u_id'] as int;

//               // Lấy c_experience hiện tại
//               final candidateRow = await supabase
//                   .from('candidates')
//                   .select('c_experience')
//                   .eq('u_id', uId)
//                   .maybeSingle();

//               final currentExp = candidateRow?['c_experience'] ?? '';
//               final updatedExp = currentExp.isEmpty
//                   ? newExp
//                   : '$currentExp, $newExp';

//               // Update lại
//               await supabase
//                   .from('candidates')
//                   .update({'c_experience': updatedExp})
//                   .eq('u_id', uId);

//               // Reload profile
//               context.read<ProfileProvider>().reloadProfile();
//             }
//           },
//           icon: const Icon(Icons.add),
//           label: const Text('Add New Experience'),
//         ),
//       ],
//     );
//   }
// }
// class _AddExperienceDialog extends StatefulWidget {
//   @override
//   State<_AddExperienceDialog> createState() => _AddExperienceDialogState();
// }

// class _AddExperienceDialogState extends State<_AddExperienceDialog> {
//   final controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Add Experience'),
//       content: TextField(
//         controller: controller,
//         decoration: const InputDecoration(hintText: 'Enter your experience'),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context, controller.text),
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/experience_model.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'experience_item.dart';

class ExperienceSection extends StatelessWidget {
  final List<ExperienceModel>? experiences;
  final int? cId;

  const ExperienceSection({super.key, this.experiences, this.cId});

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
              onPressed: () => _showAddExperienceDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (experiences == null || experiences!.isEmpty)
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
          Column(
            children: experiences!.map((exp) {
              return ExperienceItem(
                title: exp.position,
                company: exp.companyName,
                time: exp.period,
                description: exp.description ?? '',
                onDelete: () => _deleteExperience(context, exp.exId),
              );
            }).toList(),
          ),

        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _showAddExperienceDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _AddExperienceDialog(),
    );

    if (result == null || cId == null) return;

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('experiences').insert({
        'ex_company_name': result['company'],
        'ex_position': result['position'],
        'ex_start_date': result['startDate'],
        'ex_end_date': result['endDate'],
        'ex_description': result['description'],
        'c_id': cId,
      });

      if (context.mounted) {
        context.read<ProfileProvider>().reloadProfile();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _deleteExperience(BuildContext context, int exId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('experiences').delete().eq('ex_id', exId);
      if (context.mounted) {
        context.read<ProfileProvider>().reloadProfile();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa: $e')),
        );
      }
    }
  }
}

class _AddExperienceDialog extends StatefulWidget {
  const _AddExperienceDialog();

  @override
  State<_AddExperienceDialog> createState() => _AddExperienceDialogState();
}

class _AddExperienceDialogState extends State<_AddExperienceDialog> {
  final _companyCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _positionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Experience'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _companyCtrl,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                hintText: 'e.g. Google',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _positionCtrl,
              decoration: const InputDecoration(
                labelText: 'Position *',
                hintText: 'e.g. Flutter Developer',
              ),
            ),
            const SizedBox(height: 12),
            // Start Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.primary),
              title: Text(
                _startDate == null
                    ? 'Start Date *'
                    : '${_startDate!.month}/${_startDate!.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
            ),
            // End Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
              title: Text(
                _endDate == null
                    ? 'End Date (leave empty if current)'
                    : '${_endDate!.month}/${_endDate!.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your role...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_companyCtrl.text.trim().isEmpty ||
                _positionCtrl.text.trim().isEmpty ||
                _startDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin bắt buộc')),
              );
              return;
            }
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('End date must be on or after start date')),
             );
              return;
            }
            Navigator.pop(context, {
              'company': _companyCtrl.text.trim(),
              'position': _positionCtrl.text.trim(),
              'startDate': _startDate!.toIso8601String(),
              'endDate': _endDate?.toIso8601String(),
              'description': _descCtrl.text.trim(),
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}