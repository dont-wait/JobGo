import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
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
  late final TextEditingController _locationCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _noteCtrl;

  late DateTime _date;
  late TimeOfDay _time;
  late String _type;

  @override
  void initState() {
    super.initState();
    //  Load data từ schedule hiện tại
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
      // firstDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    final dateTime = DateTime(
      _date.year, _date.month, _date.day,
      _time.hour, _time.minute,
    );

    await context.read<InterviewProvider>().updateSchedule(
      scheduleId: widget.schedule.id,
      date: dateTime,
      type: _type,
      location: _locationCtrl.text,
      contactPerson: _contactCtrl.text,
      note: _noteCtrl.text,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cập nhật lịch phỏng vấn thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Sửa lịch phỏng vấn"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info không thể sửa
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
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ngày
            _buildLabel('Ngày phỏng vấn'),
            InkWell(
              onTap: _pickDate,
              child: _buildInfoBox(
                icon: Icons.calendar_today,
                text: '${_date.day}/${_date.month}/${_date.year}',
              ),
            ),

            const SizedBox(height: 16),

            // Giờ
            _buildLabel('Giờ phỏng vấn'),
            InkWell(
              onTap: _pickTime,
              child: _buildInfoBox(
                icon: Icons.access_time,
                text: '${_time.hour}:${_time.minute.toString().padLeft(2, '0')}',
              ),
            ),

            const SizedBox(height: 16),

            // Loại
            _buildLabel('Hình thức'),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'Online', child: Text('Online')),
                DropdownMenuItem(value: 'Offline', child: Text('Offline')),
              ],
              onChanged: (v) => setState(() => _type = v!),
              decoration: _inputDecoration(),
            ),

            const SizedBox(height: 16),

            _buildLabel('Địa điểm'),
            _buildTextField(_locationCtrl, 'Nhập địa điểm'),

            const SizedBox(height: 16),

            _buildLabel('Người liên hệ'),
            _buildTextField(_contactCtrl, 'Tên người liên hệ'),

            const SizedBox(height: 16),

            _buildLabel('Ghi chú'),
            _buildTextField(_noteCtrl, 'Ghi chú thêm', maxLines: 3),

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
                child: const Text(
                  'Cập nhật lịch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
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
          Text(text, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: _inputDecoration(hint: hint),
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
}