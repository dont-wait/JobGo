// import 'package:flutter/material.dart';
// import 'package:jobgo/presentation/providers/interview_provider.dart';
// import 'package:provider/provider.dart';

// class CreateInterviewPage extends StatefulWidget {
//   const CreateInterviewPage({super.key});

//   @override
//   State<CreateInterviewPage> createState() =>
//       _CreateInterviewPageState();
// }

// class _CreateInterviewPageState extends State<CreateInterviewPage> {
//   final locationCtrl = TextEditingController();
//   final contactCtrl = TextEditingController();
//   final noteCtrl = TextEditingController();

//   DateTime? date;
//   String type = 'Offline';

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.read<InterviewProvider>();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Tạo lịch phỏng vấn")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             ListTile(
//               title: Text(date == null
//                   ? "Chọn ngày"
//                   : date.toString()),
//               trailing: const Icon(Icons.calendar_today),
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime(2100),
//                   initialDate: DateTime.now(),
//                 );

//                 if (picked != null) {
//                   setState(() => date = picked);
//                 }
//               },
//             ),

//             DropdownButtonFormField(
//               value: type,
//               items: const [
//                 DropdownMenuItem(value: 'Online', child: Text('Online')),
//                 DropdownMenuItem(value: 'Offline', child: Text('Offline')),
//               ],
//               onChanged: (v) => type = v!,
//             ),

//             TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: "Địa điểm")),
//             TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: "Người liên hệ")),
//             TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: "Ghi chú")),

//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: () async {
//                 if (date == null) return;

//                 await provider.createSchedule(
//                   date: date!,
//                   type: type,
//                   location: locationCtrl.text,
//                   contactPerson: contactCtrl.text,
//                   note: noteCtrl.text,
//                   cId: 1, // tạm
//                   jId: 1, // tạm
//                 );

//                 Navigator.pop(context);
//               },
//               child: const Text("Tạo"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/repositories/employer_job_repository.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Future<void> _loadData() async 
  // {
  //   try {
  //     final supabase = Supabase.instance.client;
  //     final repo = EmployerJobRepository();
  //     final authUser = supabase.auth.currentUser;
  //     final userRow = await supabase
  //         .from('users')
  //         .select('u_id') 
  //         .or('auth_uid.eq.${authUser!.id},u_email.eq.${authUser.email}')
  //         .maybeSingle();
  //     final uId = userRow!['u_id'] as int;

  //     final employerRow = await supabase
  //         .from('employers')
  //         .select('e_id')
  //         .eq('u_id', uId)
  //         .maybeSingle();

  //     final eId = employerRow!['e_id'] as int;
  //     final jobsData = await supabase
  //         .from('jobs')
  //         .select('j_id, j_title')
  //         .eq('e_id', eId)
  //         .order('j_id', ascending: true);

  //     setState(() {
  //       _jobs = (jobsData as List)
  //           .map((j) => {
  //                 'id': j['j_id'] as int,
  //                 'title': j['j_title'] as String,
  //               })
  //           .toList();
  //     });

  //     // Load jobs của employer
  //     final jobs = await repo.fetchMyJobs();
  //     final activeJobs = jobs.where((j) => j.isActive).toList();
      
  //      print("Jobs tổng: ${jobs.length}, Active: ${activeJobs.length}");
  //     //  Load candidates từ bảng candidates
  //     final candidatesData = await supabase
  //         .from('candidates')
  //         .select('c_id, c_full_name')
  //         .not('c_full_name', 'is', null);

  //     if (!mounted) return;
  //     setState(() {
  //       _jobs = jobs
  //           .map((j) => {'id': j.id, 'title': j.title})
  //           .toList();
  //       print("Mapped jobs: $_jobs"); // Debug log
  //       _candidates = (candidatesData as List)
  //           .map((c) => {
  //                 'id': c['c_id'] as int,
  //                 'name': c['c_full_name'] as String,
  //               })
  //           .toList();
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() => _isLoading = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
  //     );
  //   }
  // }
  Future<void> _loadData() async {
  try {
    final supabase = Supabase.instance.client;
    final authUser = supabase.auth.currentUser;
     print('🔍 authUser: ${authUser?.email}');

    // Lấy u_id
    final userRow = await supabase
        .from('users')
        .select('u_id')
        .or('auth_uid.eq.${authUser!.id},u_email.eq.${authUser.email}')
        .maybeSingle();
    print('🔍 userRow: $userRow');
    final uId = userRow!['u_id'] as int;

    // Lấy e_id
    final employerRow = await supabase
        .from('employers')
        .select('e_id')
        .eq('u_id', uId)
        .maybeSingle();
    print('🔍 employerRow: $employerRow');
    final eId = employerRow!['e_id'] as int;

    // Load jobs của employer này thôi
    final jobsData = await supabase
        .from('jobs')
        .select('j_id, j_title')
        .eq('e_id', eId)
        .order('j_id', ascending: true);
      print('🔍 jobsData: $jobsData');
    // Load candidates
    final candidatesData = await supabase
        .from('candidates')
        .select('c_id, c_full_name')
        .not('c_full_name', 'is', null);
    print('🔍 candidatesData: $candidatesData');

    if (!mounted) return;
    setState(() {
      _jobs = (jobsData as List)
          .map((j) => {
                'id': j['j_id'] as int,
                'title': j['j_title'] as String,
              })
          .toList();
      _candidates = (candidatesData as List)
          .map((c) => {
                'id': c['c_id'] as int,
                'name': c['c_full_name'] as String,
              })
          .toList();
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
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
    if (_selectedJobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn job')),
      );
      return;
    }
    if (_selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ứng viên')),
      );
      return;
    }
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Tạo lịch phỏng vấn"),
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
                  _buildLabel('Vị trí tuyển dụng *'),
                  DropdownButtonFormField<int>(
                    value: _selectedJobId,
                    hint: const Text('Chọn job'),
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
                  _buildLabel('Ứng viên *'),
                  DropdownButtonFormField<int>(
                    value: _selectedCandidateId,
                    hint: const Text('Chọn ứng viên'),
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
                  _buildLabel('Ngày phỏng vấn *'),
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
                                ? 'Chọn ngày'
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
                  _buildLabel('Giờ phỏng vấn *'),
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
                                ? 'Chọn giờ'
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

                  // Địa điểm
                  _buildLabel('Địa điểm'),
                  _buildTextField(_locationCtrl, 'Nhập địa điểm'),

                  const SizedBox(height: 16),

                  // Người liên hệ
                  _buildLabel('Người liên hệ'),
                  _buildTextField(_contactCtrl, 'Tên người liên hệ'),

                  const SizedBox(height: 16),

                  // Ghi chú
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
                        'Tạo lịch phỏng vấn',
                        style: TextStyle(
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