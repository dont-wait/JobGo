
import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/repositories/candidate_repository.dart';
import 'package:jobgo/data/repositories/employer_job_repository.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/core/localization/app_localizations.dart';

class CreateInterviewPage extends StatefulWidget {
  const CreateInterviewPage({super.key});

  @override
  State<CreateInterviewPage> createState() => _CreateInterviewPageState();
}

class _CreateInterviewPageState extends State<CreateInterviewPage> {
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  String _type = 'Offline';
  bool _isLoading = true;

  // Data thật
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _candidates = [];
  int? _selectedJobId;
  int? _selectedCandidateId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final jobRepo = EmployerJobRepository();
      final candidateRepo = CandidateRepository();

      final jobs = await jobRepo.fetchMyJobs();
      final candidates = await candidateRepo.fetchCandidates();

      if (!mounted) return;
      setState(() {
        _jobs = jobs.map((j) => {'id': j.id, 'title': j.title}).toList();
        _candidates = candidates.map((c) => {'id': c.cId, 'name': c.fullName}).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.errorMessage}$e')),
      );
    }
  }


  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    if (_selectedJobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseSelectJob)),
      );
      return;
    }
    if (_selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseSelectCandidate)),
      );
      return;
    }
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseSelectDateTime)),
      );
      return;
    }

    final dateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    await context.read<InterviewProvider>().createSchedule(
      date: dateTime,
      type: _type,
      location: _locationCtrl.text,
      contactPerson: _contactCtrl.text,
      note: _noteCtrl.text,
      cId: _selectedCandidateId!,
      jId: _selectedJobId!,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(loc.createInterviewTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chọn Job
                  _buildLabel(loc.recruitingPosition),
                  DropdownButtonFormField<int>(
                    value: _selectedJobId,
                    hint: Text(loc.selectJobHint),
                    items: _jobs.map((j) {
                      return DropdownMenuItem<int>(
                        value: j['id'] as int,
                        child: Text(j['title'] as String),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedJobId = v),
                    decoration: _inputDecoration(),
                  ),

                  const SizedBox(height: 16),

                  // Chọn Candidate
                  _buildLabel(loc.candidateRequired),
                  DropdownButtonFormField<int>(
                    value: _selectedCandidateId,
                    hint: Text(loc.selectCandidateHint),
                    items: _candidates.map((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'] as int,
                        child: Text(c['name'] as String),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCandidateId = v),
                    decoration: _inputDecoration(),
                  ),

                  const SizedBox(height: 16),

                  // Chọn ngày
                  _buildLabel(loc.interviewDateLabel),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            _date == null
                                ? loc.selectDateHint
                                : '${_date!.day}/${_date!.month}/${_date!.year}',
                            style: TextStyle(
                              color: _date == null
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Chọn giờ
                  _buildLabel(loc.interviewTimeLabel),
                  InkWell(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            _time == null
                                ? loc.selectTimeHint
                                : '${_time!.hour}:${_time!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: _time == null
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Loại phỏng vấn
                  _buildLabel(loc.interviewTypeLabel),
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

                  // Địa điểm
                  _buildLabel(isVi ? 'Địa điểm' : 'Location'),
                  _buildTextField(_locationCtrl, loc.locationHint),

                  const SizedBox(height: 16),

                  // Người liên hệ
                  _buildLabel(isVi ? 'Người liên hệ' : 'Contact Person'),
                  _buildTextField(_contactCtrl, loc.contactPersonHint),

                  const SizedBox(height: 16),

                  // Ghi chú
                  _buildLabel(isVi ? 'Ghi chú' : 'Notes'),
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
                        loc.createInterviewTitle,
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