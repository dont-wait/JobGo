import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/presentation/providers/employer_provider.dart';

class EmployerEditProfilePage extends StatefulWidget {
  const EmployerEditProfilePage({super.key});

  @override
  State<EmployerEditProfilePage> createState() =>
      _EmployerEditProfilePageState();
}

class _EmployerEditProfilePageState extends State<EmployerEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _companyCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _industryCtrl;
  late final TextEditingController _companySizeCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final employer = context.read<EmployerProvider>().employer;

    _companyCtrl = TextEditingController(text: employer?.companyName ?? '');
    _addressCtrl = TextEditingController(text: employer?.address ?? '');
    _descriptionCtrl = TextEditingController(text: employer?.description ?? '');
    _websiteCtrl = TextEditingController(text: employer?.website ?? '');
    _industryCtrl = TextEditingController(text: employer?.industry ?? '');
    _companySizeCtrl = TextEditingController(text: employer?.companySize ?? '');
    _phoneCtrl = TextEditingController(text: employer?.phone ?? '');
    _emailCtrl = TextEditingController(text: employer?.email ?? '');
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    _websiteCtrl.dispose();
    _industryCtrl.dispose();
    _companySizeCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final success = await context
            .read<EmployerProvider>()
            .uploadAndChangeLogo(File(image.path));

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo uploaded successfully!')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to upload logo. Please check Supabase Storage permissions.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<EmployerProvider>();
      final currentEmployer = provider.employer;

      if (currentEmployer == null) return;

      final updatedEmployer = currentEmployer.copyWith(
        companyName: _companyCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
        industry: _industryCtrl.text.trim(),
        companySize: _companySizeCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      final success = await provider.updateProfile(updatedEmployer);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Company profile updated successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployerProvider>(
      builder: (context, provider, child) {
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
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAvatar(provider),
                      const SizedBox(height: 28),
                      _buildField(
                        label: 'Company Name',
                        controller: _companyCtrl,
                        icon: Icons.business_outlined,
                      ),
                      _buildField(
                        label: 'Company Address',
                        controller: _addressCtrl,
                        icon: Icons.location_on_outlined,
                      ),
                      _buildField(
                        label: 'Industry',
                        controller: _industryCtrl,
                        icon: Icons.category_outlined,
                      ),
                      _buildField(
                        label: 'Company Size',
                        controller: _companySizeCtrl,
                        icon: Icons.people_outline_rounded,
                      ),
                      _buildField(
                        label: 'Phone',
                        controller: _phoneCtrl,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildField(
                        label: 'Email',
                        controller: _emailCtrl,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildField(
                        label: 'Website',
                        controller: _websiteCtrl,
                        icon: Icons.language_outlined,
                        keyboardType: TextInputType.url,
                      ),
                      _buildField(
                        label: 'Description',
                        controller: _descriptionCtrl,
                        icon: Icons.info_outline_rounded,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(EmployerProvider provider) {
    final employer = provider.employer;
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 3),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: provider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : (employer?.logoUrl != null && employer!.logoUrl!.isNotEmpty)
                  ? Image.network(
                      employer.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.business,
                        size: 40,
                        color: AppColors.textHint,
                      ),
                    )
                  : const Icon(
                      Icons.business,
                      size: 40,
                      color: AppColors.textHint,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: provider.isLoading ? null : _pickAndUploadLogo,
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
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
