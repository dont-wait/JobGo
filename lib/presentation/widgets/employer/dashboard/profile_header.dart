import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

class DashboardProfileHeader extends StatelessWidget {
  final String? companyName;
  final String? contactName;
  final String? logoColor;

  const DashboardProfileHeader({
    super.key,
    this.companyName,
    this.contactName,
    this.logoColor,
  });

  Color _parseLogoColor(String? value) {
    if (value == null || value.trim().isEmpty) return AppColors.primary;
    final normalized = value.trim();
    final parsed = int.tryParse(normalized);
    if (parsed != null) return Color(parsed);

    final hex = normalized.startsWith('0x')
        ? normalized.substring(2)
        : normalized;
    final hexValue = int.tryParse(hex, radix: 16);
    return Color(hexValue ?? AppColors.primary.value);
  }

  String _displayCompany() {
    final name = companyName?.trim() ?? '';
    return name.isEmpty ? 'COMPANY' : name.toUpperCase();
  }

  String _displayContact() {
    final name = contactName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final company = companyName?.trim() ?? '';
    return company.isNotEmpty ? company : 'Employer';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with logo and icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left section - Logo and Company
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseLogoColor(logoColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.work_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayCompany(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _displayContact(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Right section - Icons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      // TODO: Search functionality
                    },
                  ),
                  const ProfileAvatar(role: UserRole.employer),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
