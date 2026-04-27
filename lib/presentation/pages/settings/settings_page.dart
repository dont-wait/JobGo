import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/core/routes/edit_profile_route.dart';
import 'package:jobgo/presentation/pages/auth/forgotpassword/forgotpassword_layout.dart';
import 'package:jobgo/presentation/providers/employer_provider.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'package:jobgo/presentation/widgets/common/language_selector_button.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  /// Role của user đang đăng nhập — dùng để điều hướng đúng trang edit profile.
  final UserRole role;

  const SettingsPage({super.key, required this.role});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      switch (widget.role) {
        case UserRole.employer:
          final employerProvider = context.read<EmployerProvider>();
          if (employerProvider.employer == null &&
              !employerProvider.isLoading) {
            employerProvider.loadProfile();
          }
          break;
        case UserRole.candidate:
          final profileProvider = context.read<ProfileProvider>();
          if (profileProvider.candidate == null && !profileProvider.isLoading) {
            profileProvider.loadProfile();
          }
          break;
        case UserRole.admin:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.settings,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer2<EmployerProvider, ProfileProvider>(
          builder: (context, employerProvider, profileProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                _buildProfileCard(employerProvider, profileProvider),
                const SizedBox(height: 24),

                // ACCOUNT
                _buildSectionLabel(loc.account),
                const SizedBox(height: 8),
                _buildMenuGroup([
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    label: loc.editProfile,
                    onTap: () => navigateToEditProfile(context, widget.role),
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    label: loc.changePassword,
                    showDivider: false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // LANGUAGE
                _buildSectionLabel(loc.language),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const LanguageSelectorButton(isCompact: false),
                ),
                const SizedBox(height: 20),

                // NOTIFICATIONS
                _buildSectionLabel(loc.notifications.toUpperCase()),
                const SizedBox(height: 8),
                _buildMenuGroup([
                  _buildToggleItem(
                    icon: Icons.notifications_active_outlined,
                    label: loc.pushNotifications,
                    value: _pushNotifications,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                  ),
                ]),
                const SizedBox(height: 20),

                // PRIVACY
                _buildSectionLabel(loc.privacy),
                const SizedBox(height: 8),
                _buildMenuGroup([
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    label: loc.privacyPolicy,
                    onTap: () => _showInfoSheet(
                      title: loc.privacyPolicy,
                      body: _privacyPolicyContent(),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    label: loc.termsOfService,
                    onTap: () => _showInfoSheet(
                      title: loc.termsOfService,
                      body: _termsOfServiceContent(),
                    ),
                    showDivider: false,
                  ),
                ]),
                const SizedBox(height: 20),

                // SUPPORT
                _buildSectionLabel(loc.support),
                const SizedBox(height: 8),
                _buildMenuGroup([
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    label: loc.helpCenter,
                    onTap: () => _showInfoSheet(
                      title: loc.helpCenter,
                      body: _helpCenterContent(),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.mail_outline,
                    label: loc.contactUs,
                    onTap: () => _showInfoSheet(
                      title: loc.contactUs,
                      body: _contactUsContent(),
                    ),
                    showDivider: false,
                  ),
                ]),
                const SizedBox(height: 20),

                // LOGOUT
                _buildMenuGroup([
                  _buildMenuItem(
                    icon: Icons.logout,
                    label: loc.logout,
                    iconColor: AppColors.error,
                    labelColor: AppColors.error,
                    showChevron: false,
                    showDivider: false,
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    EmployerProvider employerProvider,
    ProfileProvider profileProvider,
  ) {
    switch (widget.role) {
      case UserRole.employer:
        return _buildEmployerProfileCard(employerProvider);
      case UserRole.candidate:
        return _buildCandidateProfileCard(profileProvider);
      case UserRole.admin:
        return _buildAdminProfileCard();
    }
  }

  Widget _buildEmployerProfileCard(EmployerProvider provider) {
    final employer = provider.employer;

    if (provider.isLoading && employer == null) {
      return _buildLoadingProfileCard('Loading employer profile...');
    }

    if (employer == null) {
      return _buildUnavailableProfileCard(
        title: 'Could not load employer profile',
        subtitle: 'Please try again after reloading your profile.',
        onRetry: () => provider.loadProfile(),
      );
    }

    final displayName = _pickDisplayName(
      employer.contactName,
      employer.companyName,
      fallback: 'Employer',
    );
    final subtitle = _joinNonEmpty([employer.companyName, employer.email]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildProfileAvatar(
            initials: _initialsFromName(displayName),
            backgroundColor: Color(
              int.tryParse(employer.logoColor) ?? 0xFF1A3A4A,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              SizedBox(
                width: 220,
                child: Text(
                  subtitle.isEmpty ? 'Employer account' : subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateProfileCard(ProfileProvider provider) {
    final candidate = provider.candidate;

    if (provider.isLoading && candidate == null) {
      return _buildLoadingProfileCard('Loading candidate profile...');
    }

    if (candidate == null) {
      return _buildUnavailableProfileCard(
        title: 'Could not load candidate profile',
        subtitle: 'Please try again after reloading your profile.',
        onRetry: () => provider.loadProfile(),
      );
    }

    final displayName = candidate.displayName;
    final subtitle = _joinNonEmpty([
      candidate.displayHeadline,
      candidate.displayEmail,
    ]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildProfileAvatar(
            initials: candidate.initials,
            backgroundColor: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 220,
                child: Text(
                  subtitle.isEmpty ? 'Candidate account' : subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfileCard() {
    final authUser = Supabase.instance.client.auth.currentUser;
    final displayName = authUser?.email?.split('@').first ?? 'Administrator';
    final subtitle = authUser?.email ?? 'Admin account';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildProfileAvatar(
            initials: _initialsFromName(displayName),
            backgroundColor: AppColors.textSecondary,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 220,
                child: Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingProfileCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableProfileCard({
    required String title,
    required String subtitle,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_off_outlined,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar({
    required String initials,
    required Color backgroundColor,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _pickDisplayName(
    String? primary,
    String secondary, {
    required String fallback,
  }) {
    final primaryText = primary?.trim() ?? '';
    if (primaryText.isNotEmpty) return primaryText;

    final secondaryText = secondary.trim();
    if (secondaryText.isNotEmpty) return secondaryText;

    return fallback;
  }

  String _joinNonEmpty(List<String?> values) {
    return values
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .join(' • ');
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'JG';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  void _showInfoSheet({required String title, required String body}) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      body,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _privacyPolicyContent() {
    return AppLocalizations.of(context).privacyPolicyContent;
  }

  String _termsOfServiceContent() {
    return AppLocalizations.of(context).termsOfServiceContent;
  }

  String _helpCenterContent() {
    return AppLocalizations.of(context).helpCenterContent;
  }

  String _contactUsContent() {
    return AppLocalizations.of(context).contactUsContent;
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = AppColors.primary,
    Color labelColor = AppColors.textPrimary,
    bool showChevron = true,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: iconColor, size: 22),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: showChevron
              ? const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                )
              : null,
        ),
        if (showDivider)
          const Divider(height: 1, indent: 56, color: AppColors.divider),
      ],
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
