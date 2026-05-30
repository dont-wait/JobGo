import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:provider/provider.dart';

class EditInterviewPage extends StatefulWidget {
  final InterviewScheduleModel schedule;

  const EditInterviewPage({super.key, required this.schedule});

  @override
  State<EditInterviewPage> createState() => _EditInterviewPageState();
}

class _EditInterviewPageState extends State<EditInterviewPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _locationCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _noteCtrl;

  late DateTime _date;
  late TimeOfDay _time;
  late String _type;

  @override
  void initState() {
    super.initState();
    _locationCtrl = TextEditingController(text: widget.schedule.location);
    _contactCtrl = TextEditingController(text: widget.schedule.contactPerson);
    _noteCtrl = TextEditingController(text: widget.schedule.note);
    _date = widget.schedule.date;
    _time = TimeOfDay(
      hour: widget.schedule.date.hour,
      minute: widget.schedule.date.minute,
    );
    _type = widget.schedule.type;
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: _date.isBefore(DateTime.now()) ? DateTime.now() : _date,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final interviewDateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    if (interviewDateTime.isBefore(DateTime.now())) {
      _showMessage(loc.interviewDateTimeMustBeFuture);
      return;
    }

    await context.read<InterviewProvider>().updateSchedule(
      scheduleId: widget.schedule.id,
      date: interviewDateTime,
      type: _type,
      location: _locationCtrl.text.trim(),
      contactPerson: _contactCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.updateInterviewSuccess),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(loc.editInterviewTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.schedule.candidateName} • ${widget.schedule.jobTitle}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel(loc.interviewDateLabel.replaceAll(' *', '')),
              InkWell(
                onTap: _pickDate,
                child: _buildInfoBox(
                  icon: Icons.calendar_today,
                  text: '${_date.day}/${_date.month}/${_date.year}',
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel(loc.interviewTimeLabel.replaceAll(' *', '')),
              InkWell(
                onTap: _pickTime,
                child: _buildInfoBox(
                  icon: Icons.access_time,
                  text:
                      '${_time.hour}:${_time.minute.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel(loc.interviewTypeLabel),
              DropdownButtonFormField<String>(
                initialValue: _type,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 'Online',
                    child: Text(loc.translate('online')),
                  ),
                  DropdownMenuItem(
                    value: 'Offline',
                    child: Text(loc.translate('offline')),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _type = value);
                },
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),
              _buildLabel(loc.location),
              _buildTextField(
                _locationCtrl,
                loc.locationHint,
                required: true,
                requiredMessage: loc.locationRequired,
              ),
              const SizedBox(height: 16),
              _buildLabel(loc.contactPersonLabel),
              _buildTextField(
                _contactCtrl,
                loc.contactPersonHint,
                required: true,
                requiredMessage:
                    '${loc.contactPersonLabel} ${loc.isFieldsRequired}',
              ),
              const SizedBox(height: 16),
              _buildLabel(loc.notesLabel),
              _buildTextField(_noteCtrl, loc.notesHint, maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    loc.updateSchedule,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInfoBox({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool required = false,
    String? requiredMessage,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      decoration: _inputDecoration(hint: hint),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return requiredMessage ??
                    AppLocalizations.of(context).fillRequiredFields;
              }
              return null;
            }
          : null,
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
