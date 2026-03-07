import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/mockdata/mock_candidate.dart';
import 'package:jobgo/data/mockdata/mockdata_employer.dart';
import 'package:jobgo/presentation/pages/main/app_shell.dart';

/// Avatar tròn hiển thị trên AppBar — nhấn vào sẽ navigate tới trang Profile
/// của role tương ứng.
///
/// Usage trong AppBar.actions:
/// ```dart
/// actions: [ ProfileAvatar(role: UserRole.candidate) ]
/// ```
class ProfileAvatar extends StatelessWidget {
  final UserRole role;

  const ProfileAvatar({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final info = _avatarInfo;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _goToProfile(context),
        child: Tooltip(
          message: info.name,
          child: info.avatar,
        ),
      ),
    );
  }

  void _goToProfile(BuildContext context) {
    AppShell.goToProfile(context);
  }

  ({String name, Widget avatar}) get _avatarInfo {
    switch (role) {
      case UserRole.employer:
        final emp = mockEmployers.isNotEmpty ? mockEmployers.first : null;
        return (
          name: emp?.fullName ?? 'Employer',
          avatar: emp?.avatarPath != null
              ? CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(emp!.avatarPath!),
                )
              : const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
        );
      case UserRole.admin:
        return (
          name: 'Admin',
          avatar: const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      case UserRole.candidate:
        final cand =
            mockCandidatesData.isNotEmpty ? mockCandidatesData.first : null;
        return (
          name: cand?.fullName ?? 'Candidate',
          avatar: cand != null
              ? CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(cand.avatarUrl),
                )
              : const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
        );
    }
  }
}
