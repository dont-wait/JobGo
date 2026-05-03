import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/core/utils/app_logger.dart';
import 'package:jobgo/presentation/pages/employer/company/company_profile_page.dart';
import 'package:jobgo/presentation/pages/employer/interview_schedule/interview_schedule_page.dart';
import 'package:jobgo/presentation/pages/employer/profile/employer_edit_profile_page.dart';
import 'package:jobgo/presentation/pages/settings/settings_page.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/presentation/providers/employer_provider.dart';

class EmployerProfilePage extends StatefulWidget {
  const EmployerProfilePage({super.key});

  @override
  State<EmployerProfilePage> createState() => _EmployerProfilePageState();
}

class _EmployerProfilePageState extends State<EmployerProfilePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployerProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(role: UserRole.employer),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<EmployerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final employer = provider.employer;
          if (employer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Could not load company profile'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, provider),
                const SizedBox(height: 28),

                _buildSectionTitle('COMPANY MANAGEMENT'),
                const SizedBox(height: 10),
                _buildMenuCard([
                  _SettingsItem(
                    icon: Icons.account_balance_rounded,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: AppColors.primary,
                    label: 'Company Profile',
                    subtitle: 'View public company page',
                    onTap: () => _navigateToCompanyProfile(context),
                  ),
                  _SettingsItem(
                    icon: Icons.schedule,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: AppColors.primary,
                    label: 'Lịch hẹn phỏng vấn',
                    subtitle: 'Quản lý lịch phỏng vấn',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InterviewSchedulePage(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.business_outlined,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: AppColors.primary,
                    label: 'Company Information',
                    subtitle: 'Logo, banner, and description',
                    onTap: () => _navigateToEdit(context),
                  ),
                  _SettingsItem(
                    icon: Icons.people_outline_rounded,
                    iconBg: const Color(0xFFEDE7F6),
                    iconColor: const Color(0xFF6A1B9A),
                    label: 'Team Management',
                    subtitle: 'Manage recruiters and permissions',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('BILLING & SECURITY'),
                const SizedBox(height: 10),
                _buildMenuCard([
                  _SettingsItem(
                    icon: Icons.credit_card_rounded,
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: AppColors.orange,
                    label: 'Billing & Subscription',
                    subtitle: 'Manage plans and invoices',
                    onTap: () {},
                    trailing: _buildDotBadge(),
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline_rounded,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: AppColors.success,
                    label: 'Account Security',
                    subtitle: 'Password, 2FA, login activity',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('SUPPORT'),
                const SizedBox(height: 10),
                _buildMenuCard([
                  _SettingsItem(
                    icon: Icons.help_outline_rounded,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: AppColors.primary,
                    label: 'Help Center',
                    subtitle: 'Documentation and live chat',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.mail_outline_rounded,
                    iconBg: const Color(0xFFFCE4EC),
                    iconColor: AppColors.error,
                    label: 'Contact Us',
                    subtitle: 'Get in touch with support',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 24),

                _buildMenuCard([
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    iconBg: const Color(0xFFFFEBEE),
                    iconColor: AppColors.error,
                    label: 'Logout',
                    subtitle: null,
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    labelColor: AppColors.error,
                    showChevron: false,
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, EmployerProvider provider) {
    final employer = provider.employer!;
    final color = Color(int.parse(employer.logoColor));

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CompanyLogo(
                imageUrl: employer.logoUrl,
                fallbackText: employer.logoText,
                backgroundColor: color,
                width: 88,
                height: 88,
                borderRadius: 44,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                onTap: provider.isLoading ? null : _pickAndUploadLogo,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Name from Users join (e.g. HR_Sang)
          Text(
            employer.contactName ?? 'Recruiter',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Company details using SQL fields
          Text(
            '${employer.companyName} • ${employer.address ?? 'Headquarters'}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Text(
              'Verified Employer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMenuCard(List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              _buildMenuTile(item),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(left: 68),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuTile(_SettingsItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: item.labelColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing != null) ...[
              item.trailing!,
              const SizedBox(width: 8),
            ],
            if (item.showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotBadge() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.orange,
        shape: BoxShape.circle,
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmployerEditProfilePage()),
    );
  }

  Future<void> _pickAndUploadLogo() async {
    try {
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
              const Text(
                'Chọn ảnh đại diện',
                style: TextStyle(
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
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary),
                ),
                title: const Text('Chụp ảnh mới'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primary),
                ),
                title: const Text('Chọn từ thư viện'),
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
            const SnackBar(
              content: Text('Logo uploaded successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload logo. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e, st) {
      AppLogger.error('Error picking image', error: e, stackTrace: st);
    }
  }
}

class _SettingsItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? labelColor;
  final bool showChevron;

  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.labelColor,
    this.showChevron = true,
  });
}

void _navigateToCompanyProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CompanyProfilePage(),
    ),
  );
}