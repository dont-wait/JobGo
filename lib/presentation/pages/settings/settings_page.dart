import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/core/routes/edit_profile_route.dart';
import 'package:jobgo/presentation/pages/auth/forgotpassword/forgotpassword_layout.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            _buildProfileCard(),
            const SizedBox(height: 24),

            // ACCOUNT
            _buildSectionLabel('ACCOUNT'),
            const SizedBox(height: 8),
            _buildMenuGroup([
              _buildMenuItem(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => navigateToEditProfile(context, widget.role),
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                label: 'Change Password',
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

            // NOTIFICATIONS
            _buildSectionLabel('NOTIFICATIONS'),
            const SizedBox(height: 8),
            _buildMenuGroup([
              _buildToggleItem(
                icon: Icons.notifications_active_outlined,
                label: 'Push Notifications',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
            ]),
            const SizedBox(height: 20),

            // PRIVACY
            _buildSectionLabel('PRIVACY'),
            const SizedBox(height: 8),
            _buildMenuGroup([
              _buildMenuItem(
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () {},
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 20),

            // SUPPORT
            _buildSectionLabel('SUPPORT'),
            const SizedBox(height: 8),
            _buildMenuGroup([
              _buildMenuItem(
                icon: Icons.help_outline,
                label: 'Help Center',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.mail_outline,
                label: 'Contact Us',
                onTap: () {},
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 20),

            // LOGOUT
            _buildMenuGroup([
              _buildMenuItem(
                icon: Icons.logout,
                label: 'Logout',
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
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
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
              Icons.person_outline,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alex Johnson',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Senior Product Designer',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        activeColor: AppColors.primary,
      ),
    );
  }
}
