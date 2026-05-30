import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/utils/app_logger.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/presentation/providers/employer_provider.dart';
import 'package:jobgo/core/localization/app_localizations.dart';

class EmployerEditProfilePage extends StatefulWidget {
  const EmployerEditProfilePage({super.key});

  @override
  State<EmployerEditProfilePage> createState() =>
      _EmployerEditProfilePageState();
}

class _EmployerEditProfilePageState extends State<EmployerEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

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
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.chooseProfileImage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(loc.takeNewPhoto),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(loc.chooseFromLibrary),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
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
            SnackBar(
              content: Text(AppLocalizations.of(context).logoUploadSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).logoUploadFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e, st) {
      AppLogger.error('Error picking image', error: e, stackTrace: st);
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
        final loc = AppLocalizations.of(context);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.profileUpdateSuccess),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(loc.profileUpdateFailed)));
        }
      }
    }
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label ${AppLocalizations.of(context).isFieldsRequired}';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final loc = AppLocalizations.of(context);
    final requiredError = _validateRequired(value, loc.emailLabel);
    if (requiredError != null) return requiredError;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return loc.invalidEmailFormat;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final loc = AppLocalizations.of(context);
    final requiredError = _validateRequired(value, loc.phoneLabel);
    if (requiredError != null) return requiredError;

    final normalized = value!.trim().replaceAll(RegExp(r'[\s().-]'), '');
    if (!_phoneRegex.hasMatch(normalized)) {
      return loc.invalidPhoneFormat;
    }
    return null;
  }

  String? _validateWebsite(String? value) {
    final loc = AppLocalizations.of(context);
    final requiredError = _validateRequired(value, loc.websiteLabel);
    if (requiredError != null) return requiredError;

    var url = value!.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) {
      return loc.invalidWebsiteFormat;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
            title: Text(
              loc.editProfile,
              style: const TextStyle(
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
                        label: loc.companyName,
                        controller: _companyCtrl,
                        icon: Icons.business_outlined,
                        validator: (value) =>
                            _validateRequired(value, loc.companyName),
                      ),
                      _buildField(
                        label: loc.addressLabel,
                        controller: _addressCtrl,
                        icon: Icons.location_on_outlined,
                        validator: (value) =>
                            _validateRequired(value, loc.addressLabel),
                      ),
                      _buildField(
                        label: loc.industryLabel,
                        controller: _industryCtrl,
                        icon: Icons.category_outlined,
                        validator: (value) =>
                            _validateRequired(value, loc.industryLabel),
                      ),
                      _buildField(
                        label: loc.companySize,
                        controller: _companySizeCtrl,
                        icon: Icons.people_outline_rounded,
                        validator: (value) =>
                            _validateRequired(value, loc.companySize),
                      ),
                      _buildField(
                        label: loc.phoneLabel,
                        controller: _phoneCtrl,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      _buildField(
                        label: loc.emailLabel,
                        controller: _emailCtrl,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      _buildField(
                        label: loc.websiteLabel,
                        controller: _websiteCtrl,
                        icon: Icons.language_outlined,
                        keyboardType: TextInputType.url,
                        validator: _validateWebsite,
                      ),
                      _buildField(
                        label: loc.description,
                        controller: _descriptionCtrl,
                        icon: Icons.info_outline_rounded,
                        maxLines: 4,
                        validator: (value) =>
                            _validateRequired(value, loc.description),
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
                              : Text(
                                  loc.saveChanges,
                                  style: const TextStyle(
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
    FormFieldValidator<String>? validator,
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
            validator: validator,
          ),
        ],
      ),
    );
  }
}
