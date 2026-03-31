
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'experience_item.dart';

class ExperienceSection extends StatelessWidget {
  final String? experience;

  const ExperienceSection({super.key, this.experience});
  List<String> get _experienceList {
    if (experience == null || experience!.trim().isEmpty) return [];
    return experience!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }


  @override
  Widget build(BuildContext context) {
     final experiences = _experienceList;

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
            // TextButton.icon(
            //   onPressed: () {},
            //   icon: const Icon(Icons.add, size: 18),
            //   label: const Text('Add'),
            // ),
          ],
        ),
        const SizedBox(height: 12),

        // Hiển thị data thật hoặc thông báo trống
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
          // ExperienceItem(
          //   title: 'Experience',
          //   company: '',
          //   time: '',
          //   description: experience!,
          // ),
          Column(
            children: experiences.map((exp) {
              return ExperienceItem(
                title: 'Experience',
                company: '',
                time: '',
                description: exp,
              );
            }).toList(),
          ),


        const SizedBox(height: 12),
        // OutlinedButton.icon(
        //   onPressed: () {},
        //   icon: const Icon(Icons.add),
        //   label: const Text('Add New Experience'),
        // ),
        OutlinedButton.icon(
          onPressed: () async {
            final newExp = await showDialog<String>(
              context: context,
              builder: (_) => _AddExperienceDialog(),
            );

            if (newExp != null && newExp.trim().isNotEmpty) {
              final supabase = Supabase.instance.client;
              final authUser = supabase.auth.currentUser;
              if (authUser == null) return;

              // Lấy u_id
              final userRow = await supabase
                  .from('users')
                  .select('u_id')
                  .eq('auth_uid', authUser.id)
                  .maybeSingle();

              if (userRow == null) return;
              final uId = userRow['u_id'] as int;

              // Lấy c_experience hiện tại
              final candidateRow = await supabase
                  .from('candidates')
                  .select('c_experience')
                  .eq('u_id', uId)
                  .maybeSingle();

              final currentExp = candidateRow?['c_experience'] ?? '';
              final updatedExp = currentExp.isEmpty
                  ? newExp
                  : '$currentExp, $newExp';

              // Update lại
              await supabase
                  .from('candidates')
                  .update({'c_experience': updatedExp})
                  .eq('u_id', uId);

              // Reload profile
              context.read<ProfileProvider>().reloadProfile();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Experience'),
        ),
      ],
    );
  }
}
class _AddExperienceDialog extends StatefulWidget {
  @override
  State<_AddExperienceDialog> createState() => _AddExperienceDialogState();
}

class _AddExperienceDialogState extends State<_AddExperienceDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Experience'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Enter your experience'),
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
