import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/repositories/candidate_repository.dart';
import 'package:jobgo/data/repositories/employer_job_repository.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:provider/provider.dart';

class CreateInterviewPage extends StatefulWidget {
  const CreateInterviewPage({super.key});

  @override
  State<CreateInterviewPage> createState() => _CreateInterviewPageState();
}

class _CreateInterviewPageState extends State<CreateInterviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  String _type = 'Offline';
  bool _isLoading = true;

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
        _candidates = candidates
            .map((c) => {'id': c.cId, 'name': c.fullName})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final loc = AppLocalizations.of(context);
      _showMessage('${loc.errorMessage}$e');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_date == null || _time == null) {
      _showMessage(loc.pleaseSelectDateTime);
      return;
    }

    final interviewDateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    if (interviewDateTime.isBefore(DateTime.now())) {
      _showMessage(loc.interviewDateTimeMustBeFuture);
      return;
    }

    await context.read<InterviewProvider>().createSchedule(
      date: interviewDateTime,
      type: _type,
      location: _locationCtrl.text.trim(),
      contactPerson: _contactCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
      cId: _selectedCandidateId!,
      jId: _selectedJobId!,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(loc.recruitingPosition),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedJobId,
                      hint: Text(loc.selectJobHint),
                      isExpanded: true,
                      items: _jobs.map((job) {
                        return DropdownMenuItem<int>(
                          value: job['id'] as int,
                          child: Text(
                            job['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() => _selectedJobId = value);

                        if (value == null) return;
                        final candidateRepo = CandidateRepository();
                        final candidates = await candidateRepo
                            .fetchCandidatesForJob(value);
                        if (!mounted) return;

                        setState(() {
                          _candidates = candidates
                              .map(
                                (c) => {
                                  'id': c.cId,
                                  'name': c.fullName ?? 'Unknown',
                                },
                              )
                              .toList();
                          _selectedCandidateId = null;
                        });
                      },
                      decoration: _inputDecoration(),
                      validator: (value) =>
                          value == null ? loc.pleaseSelectJob : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(loc.candidateRequired),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCandidateId,
                      hint: Text(loc.selectCandidateHint),
                      isExpanded: true,
                      items: _candidates.map((candidate) {
                        return DropdownMenuItem<int>(
                          value: candidate['id'] as int,
                          child: Text(
                            candidate['name'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCandidateId = value),
                      decoration: _inputDecoration(),
                      validator: (value) =>
                          value == null ? loc.pleaseSelectCandidate : null,
                    ),
                    const SizedBox(height: 16),
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
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _date == null
                                    ? loc.selectDateHint
                                    : '${_date!.day}/${_date!.month}/${_date!.year}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _date == null
                                      ? AppColors.textHint
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                            const Icon(
                              Icons.access_time,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _time == null
                                    ? loc.selectTimeHint
                                    : '${_time!.hour}:${_time!.minute.toString().padLeft(2, '0')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _time == null
                                      ? AppColors.textHint
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
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
