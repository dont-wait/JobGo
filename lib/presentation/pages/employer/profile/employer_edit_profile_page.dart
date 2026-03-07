import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mockdata_employer.dart';

/// Page cho phép nhà tuyển dụng chỉnh sửa thông tin cá nhân.
class EmployerEditProfilePage extends StatefulWidget {
  const EmployerEditProfilePage({super.key});

  @override
  State<EmployerEditProfilePage> createState() =>
      _EmployerEditProfilePageState();
}

class _EmployerEditProfilePageState extends State<EmployerEditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final employer = mockEmployers.isNotEmpty ? mockEmployers.first : null;
    _nameCtrl = TextEditingController(text: employer?.fullName ?? '');
    _titleCtrl = TextEditingController(text: employer?.jobTitle ?? '');
    _companyCtrl = TextEditingController(text: employer?.companyName ?? '');
    _emailCtrl = TextEditingController(text: employer?.email ?? '');
    _phoneCtrl = TextEditingController(text: employer?.phone ?? '');
    _locationCtrl = TextEditingController(text: employer?.location ?? '');
    _bioCtrl = TextEditingController(text: employer?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // TODO: persist changes
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
              // ── Avatar ──
              _buildAvatar(),
              const SizedBox(height: 28),

              // ── Fields ──
              _buildField(
                label: 'Full Name',
                controller: _nameCtrl,
                icon: Icons.person_outline_rounded,
              ),
              _buildField(
                label: 'Job Title',
                controller: _titleCtrl,
                icon: Icons.badge_outlined,
              ),
              _buildField(
                label: 'Company',
                controller: _companyCtrl,
                icon: Icons.business_outlined,
              ),
              _buildField(
                label: 'Email',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildField(
                label: 'Phone',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _buildField(
                label: 'Location',
                controller: _locationCtrl,
                icon: Icons.location_on_outlined,
              ),
              _buildField(
                label: 'Bio',
                controller: _bioCtrl,
                icon: Icons.info_outline_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
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

  // ─────────────────────────────────────────────
  // Avatar with camera icon
  // ─────────────────────────────────────────────
  Widget _buildAvatar() {
    final employer = mockEmployers.isNotEmpty ? mockEmployers.first : null;
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 3),
              color: AppColors.lightBackground,
            ),
            child: CircleAvatar(
              radius: 47,
              backgroundImage: employer?.avatarPath != null
                  ? AssetImage(employer!.avatarPath!)
                  : null,
              backgroundColor: AppColors.lightBackground,
              child: employer?.avatarPath == null
                  ? const Icon(Icons.person_outline, size: 40, color: AppColors.textHint)
                  : null,
            ),
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
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Reusable field card
  // ─────────────────────────────────────────────
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? '$label is required' : null,
          ),
        ],
      ),
    );
  }
}
