
import 'package:flutter/material.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/skill_model.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';

class SkillsSection extends StatelessWidget {
  final List<SkillModel>? skills;
  final int? cId;

  const SkillsSection({super.key, this.skills, this.cId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Skills',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddSkillDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (skills == null || skills!.isEmpty)
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills!.map((skill) {
              return Chip(
                label: Text(
                  skill.csYears != null
                      ? '${skill.skName} • ${skill.csYears} yrs'
                      : skill.skName,
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _deleteSkill(context, skill.skId),
                backgroundColor: AppColors.searchPrimaryBar,
                labelStyle: const TextStyle(
                  color: AppColors.searchPrimaryBarText,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _showAddSkillDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AddSkillDialog(cId: cId, existingSkills: skills),
    );
    print(' result: $result');
    print(' cId: $cId');

    if (result == null || cId == null) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('candidates_skill').insert({
        'c_id': cId,
        'sk_id': result['skId'],
        'cs_years': result['years'],
      });

      print('Insert thành công');

      if (context.mounted) {
        context.read<ProfileProvider>().reloadProfile();
      }
    } catch (e) {
      print(' Lỗi: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _deleteSkill(BuildContext context, int skId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('candidates_skill')
          .delete()
          .eq('c_id', cId!)
          .eq('sk_id', skId);

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

class _AddSkillDialog extends StatefulWidget {
  final int? cId;
  final List<SkillModel>? existingSkills;

  const _AddSkillDialog({this.cId, this.existingSkills});

  @override
  State<_AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<_AddSkillDialog> {
  List<Map<String, dynamic>> _availableSkills = [];
  int? _selectedSkillId;
  String? _selectedSkillName;
  int? _years;
  bool _isLoading = true;
  String? _loadError;
  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('skill')
          .select('sk_id, sk_name')
          .order('sk_name');

      // Lọc bỏ skill đã có
      final existingIds = widget.existingSkills
              ?.map((s) => s.skId)
              .toSet() ??
          {};
      if (!mounted) return;
      setState(() {
        _availableSkills = (data as List)
            .map((e) => {'id': e['sk_id'] as int, 'name': e['sk_name'] as String})
            .where((s) => !existingIds.contains(s['id']))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      // if (!mounted) return;
      // setState(() => _isLoading = false);
      if (!mounted) return;
        setState(() {
          _isLoading = false;
          _loadError = 'Failed to load skills';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Skill'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _loadError != null    
            ? Text(_loadError!)  
          : _availableSkills.isEmpty
              ? const Text('Bạn đã thêm tất cả skills có sẵn!')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown chọn skill
                    // DropdownButtonFormField<int>(
                    //   value: _selectedSkillId,
                    //   hint: const Text('Chọn skill'),
                    //   items: _availableSkills.map((s) {
                    //     return DropdownMenuItem<int>(
                    //       value: s['id'] as int,
                    //       child: Text(s['name'] as String),
                    //     );
                    //   }).toList(),
                    //   onChanged: (v) => setState(() {
                    //     _selectedSkillId = v;
                    //     _selectedSkillName = _availableSkills
                    //         .firstWhere((s) => s['id'] == v)['name'] as String;
                    //   }),
                    //   decoration: const InputDecoration(
                    //     labelText: 'Skill *',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    Autocomplete<Map<String, dynamic>>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const []; 
                        return _availableSkills.where((s) =>
                            (s['name'] as String)
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase())); 
                      },
                      displayStringForOption: (s) => s['name'] as String,
                      onSelected: (s) {
                        setState(() {
                          _selectedSkillId = s['id'] as int;
                          _selectedSkillName = s['name'] as String;
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                        final l = AppLocalizations.of(context);
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: (value) {
                            // Clear selection nếu text không khớp với skill đã chọn
                            if (_selectedSkillName != null && value != _selectedSkillName) {
                              setState(() {
                                _selectedSkillId = null;
                                _selectedSkillName = null;
                              });
                            }
                          },
                          decoration:  InputDecoration(
                            labelText: '${l.skillLabel} *',
                            hintText: l.skillSearchHint,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final skill = options.elementAt(index);
                                  return ListTile(
                                    title: Text(skill['name'] as String),
                                    onTap: () => onSelected(skill),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Nhập số năm
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Years of experience',
                        hintText: 'e.g. 2',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _years = int.tryParse(v),
                    ),
                  ],
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedSkillId == null
              ? null
              : () => Navigator.pop(context, {
                    'skId': _selectedSkillId,
                    'years': _years,
                  }),
          child: const Text('Add'),
        ),
      ],
    );
  }
}