
import 'package:flutter/material.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
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
     final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _AddExperienceSheet(),
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




class _AddExperienceSheet extends StatefulWidget {
  const _AddExperienceSheet();
  @override
  State<_AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<_AddExperienceSheet> {
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
    final l = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(l.addExperience,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Form
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  _buildField(
                    icon: Icons.business,
                    label: l.companyName,
                    controller: _companyCtrl,
                    hint: l.companyNameHint,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    icon: Icons.work_outline,
                    label: l.position,
                    controller: _positionCtrl,
                    hint: l.positionHint,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker(
                        label: l.startDate,
                        date: _startDate,
                        icon: Icons.calendar_today,
                        required: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            initialDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _startDate = picked);
                        },
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDatePicker(
                        label: l.endDate,
                        date: _endDate,
                        icon: Icons.calendar_today_outlined,
                        hint: l.endDateHint,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _endDate = picked);
                        },
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    icon: Icons.notes,
                    label: l.description,
                    controller: _descCtrl,
                    hint: l.describeRole,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l.save,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('$label${required ? ' *' : ''}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
    String? hint,
    bool required = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text('$label${required ? ' *' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            Text(
              date != null
                  ? '${date.month}/${date.year}'
                  : (hint ?? '—'),
              style: TextStyle(
                fontSize: 13,
                color: date != null ? AppColors.textPrimary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final l = AppLocalizations.of(context);
    if (_companyCtrl.text.trim().isEmpty ||
        _positionCtrl.text.trim().isEmpty ||
        _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.fillRequiredFields)));
      return;
    }
    if (_endDate != null && _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.endDateBeforeStart)));
      return;
    }
    Navigator.pop(context, {
      'company': _companyCtrl.text.trim(),
      'position': _positionCtrl.text.trim(),
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'description': _descCtrl.text.trim(),
    });
  }
}