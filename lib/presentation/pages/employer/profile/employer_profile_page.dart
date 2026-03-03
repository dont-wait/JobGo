import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mockdata_employer.dart';
import 'package:jobgo/presentation/pages/employer/profile/employer_edit_profile_page.dart';
import 'package:jobgo/presentation/pages/settings/settings_page.dart';

/// Employer Account Settings — profile page matching the mockup.
class EmployerProfilePage extends StatelessWidget {
  const EmployerProfilePage({super.key});

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
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Header ──
            _buildProfileHeader(context),
            const SizedBox(height: 28),

            // ── COMPANY MANAGEMENT ──
            _buildSectionTitle('COMPANY MANAGEMENT'),
            const SizedBox(height: 10),
            _buildMenuCard([
              _SettingsItem(
                icon: Icons.business_outlined,
                iconBg: const Color(0xFFE3F2FD),
                iconColor: AppColors.primary,
                label: 'Company Information',
                subtitle: 'Logo, banner, and description',
                onTap: () {},
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

            // ── BILLING & SECURITY ──
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

            // ── SUPPORT ──
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

            // ── DANGER ZONE ──
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
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Profile Header — avatar + name + edit icon
  // ─────────────────────────────────────────────
  Widget _buildProfileHeader(BuildContext context) {
    if (mockEmployers.isEmpty) {
      return const Center(
        child: Text(
          'No employer data available',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }
    final employer = mockEmployers.first;
    return Center(
      child: Column(
        children: [
          // Avatar with edit badge
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 41,
                  backgroundImage: employer.avatarPath != null
                      ? AssetImage(employer.avatarPath!)
                      : null,
                  backgroundColor: AppColors.lightBackground,
                  child: employer.avatarPath == null
                      ? const Icon(Icons.person_outline, size: 36, color: AppColors.textHint)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _navigateToEdit(context),
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

          // Name
          Text(
            employer.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Title & Company
          Text(
            '${employer.jobTitle} at ${employer.companyName}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Account badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              employer.accountType,
              style: const TextStyle(
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

  // ─────────────────────────────────────────────
  //  Section title
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  //  Menu card container
  // ─────────────────────────────────────────────
  Widget _buildMenuCard(List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
            // Icon container
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
            // Label + subtitle
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
            // Trailing
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

  // ── Orange dot badge ──
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
}

// ─────────────────────────────────────────────
//  Data class for settings items
// ─────────────────────────────────────────────
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
