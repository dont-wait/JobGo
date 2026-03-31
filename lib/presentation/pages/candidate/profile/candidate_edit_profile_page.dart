import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';

class CandidateEditProfilePage extends StatefulWidget {
  final CandidateSupabaseModel? candidate;

  const CandidateEditProfilePage({super.key, this.candidate});

  @override
  State<CandidateEditProfilePage> createState() =>
      _CandidateEditProfilePageState();
}

class _CandidateEditProfilePageState extends State<CandidateEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _skillCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _experienceCtrl;
  late final TextEditingController _cvUrlCtrl;
  late final TextEditingController _salaryMinCtrl;
  late final TextEditingController _salaryMaxCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _summaryCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.candidate;
    _nameCtrl = TextEditingController(text: c?.fullName ?? '');
    _dobCtrl = TextEditingController(text: c?.dateOfBirth ?? '');
    _genderCtrl = TextEditingController(text: c?.gender ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _skillCtrl = TextEditingController(text: c?.skill ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _educationCtrl = TextEditingController(text: c?.education ?? '');
    _experienceCtrl = TextEditingController(text: c?.experience ?? '');
    _cvUrlCtrl = TextEditingController(text: c?.resume ?? '');
    _salaryMinCtrl = TextEditingController(text: c?.desiredSalaryMin?.toString() ?? '');
    _salaryMaxCtrl = TextEditingController(text: c?.desiredSalaryMax?.toString() ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _summaryCtrl = TextEditingController(text: c?.summary ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    _addressCtrl.dispose();
    _skillCtrl.dispose();
    _phoneCtrl.dispose();
    _educationCtrl.dispose();
    _experienceCtrl.dispose();
    _cvUrlCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _emailCtrl.dispose();
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final supabase = Supabase.instance.client;
        final uId = widget.candidate?.uId;

        if (uId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy user ID')),
          );
          return;
        }

        // UPDATE bảng candidates
        await supabase.from('candidates').update({
          'c_full_name': _nameCtrl.text.trim(),
          'c_date_of_birth': _dobCtrl.text.trim().isEmpty ? null : _dobCtrl.text.trim(),
          'c_gender': _genderCtrl.text.trim(),
          'c_address': _addressCtrl.text.trim(),
          'c_skill': _skillCtrl.text.trim(),
          'c_phone': _phoneCtrl.text.trim(),
          'c_education': _educationCtrl.text.trim(),
          'c_experience': _experienceCtrl.text.trim(),
          'c_resume': _cvUrlCtrl.text.trim(),
          'c_desired_salary_min': _salaryMinCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(_salaryMinCtrl.text.trim()),
          'c_desired_salary_max': _salaryMaxCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(_salaryMaxCtrl.text.trim()),
          'c_title': _titleCtrl.text.trim(),
          'c_summary': _summaryCtrl.text.trim(),
        }).eq('u_id', uId);

        //  UPDATE u_name trong bảng users nếu đổi tên
        await supabase.from('users').update({
          'u_name': _nameCtrl.text.trim(),
          'u_phone': _phoneCtrl.text.trim(),
        }).eq('u_id', uId);

        if (!mounted) return;

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatar(widget.candidate?.avatarUrl),
              const SizedBox(height: 28),

              _buildField(label: 'Full Name', controller: _nameCtrl, icon: Icons.person_outline),
              _buildField(label: 'Date of Birth', controller: _dobCtrl, icon: Icons.cake_outlined),
              _buildField(label: 'Gender', controller: _genderCtrl, icon: Icons.wc_outlined),
              _buildField(label: 'Address', controller: _addressCtrl, icon: Icons.home_outlined),
              _buildField(label: 'Skill', controller: _skillCtrl, icon: Icons.build_outlined, maxLines: 2),
              _buildField(label: 'Phone', controller: _phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              _buildField(label: 'Email', controller: _emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              _buildField(label: 'Education', controller: _educationCtrl, icon: Icons.school_outlined),
              _buildField(label: 'Experience', controller: _experienceCtrl, icon: Icons.work_outline, maxLines: 2),
              _buildField(label: 'CV URL', controller: _cvUrlCtrl, icon: Icons.picture_as_pdf_outlined, keyboardType: TextInputType.url),
              _buildField(label: 'Desired Salary Min', controller: _salaryMinCtrl, icon: Icons.attach_money, keyboardType: TextInputType.number),
              _buildField(label: 'Desired Salary Max', controller: _salaryMaxCtrl, icon: Icons.attach_money, keyboardType: TextInputType.number),
              _buildField(label: 'Job Title', controller: _titleCtrl, icon: Icons.title_outlined),
              _buildField(label: 'Summary', controller: _summaryCtrl, icon: Icons.description, maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
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

  Widget _buildAvatar(String? avatarUrl) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl) as ImageProvider
                : null,
            backgroundColor: AppColors.lightBackground,
            child: avatarUrl == null
                ? const Icon(Icons.person_outline, size: 40, color: AppColors.textHint)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: pick image
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            )),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: maxLines == 1
                  ? Icon(icon, size: 20, color: AppColors.textHint)
                  : null,
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 14 : 0,
              ),
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
            ),
            validator: (v) => v == null || v.trim().isEmpty ? '$label is required' : null,
          ),
        ],
      ),
    );
  }
}