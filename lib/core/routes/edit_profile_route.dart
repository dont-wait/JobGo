import 'package:flutter/material.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/pages/employer/profile/employer_edit_profile_page.dart';

/// Điều hướng đến đúng trang Edit Profile tương ứng với role.
/// Khi có CandidateEditProfilePage thì thêm case vào đây — SettingsPage không cần sửa.
void navigateToEditProfile(BuildContext context, UserRole role) {
  switch (role) {
    case UserRole.employer:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EmployerEditProfilePage()),
      );
      break;
    case UserRole.candidate:
      // TODO: Navigator.push → CandidateEditProfilePage khi có
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidate edit profile — coming soon')),
      );
      break;
    case UserRole.admin:
      // TODO: AdminEditProfilePage
      break;
  }
}
