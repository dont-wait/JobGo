import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/repositories/candidate_repository.dart';
import 'package:jobgo/data/repositories/employer_repository.dart';
import 'package:jobgo/presentation/pages/main/app_shell.dart';

/// Avatar tròn hiển thị trên AppBar — nhấn vào sẽ navigate tới trang Profile
/// của role tương ứng.
///
/// Usage trong AppBar.actions:
/// ```dart
/// actions: [ ProfileAvatar(role: UserRole.candidate) ]
/// ```
class ProfileAvatar extends StatefulWidget {
  final UserRole role;

  const ProfileAvatar({super.key, required this.role});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  late Future<_AvatarInfo> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadAvatarInfo();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _avatarFuture = _loadAvatarInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AvatarInfo>(
      future: _avatarFuture,
      builder: (context, snapshot) {
        final info = snapshot.data ?? _fallbackAvatarInfo;

        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => _goToProfile(context),
            child: Tooltip(message: info.name, child: info.avatar),
          ),
        );
      },
    );
  }

  void _goToProfile(BuildContext context) {
    AppShell.goToProfile(context);
  }

  Future<_AvatarInfo> _loadAvatarInfo() async {
    switch (widget.role) {
      case UserRole.employer:
        final employer = await EmployerRepository().getCurrentEmployer();
        if (employer == null) return _fallbackAvatarInfo;

        final logoUrl = employer.logoUrl?.trim() ?? '';
        if (logoUrl.isNotEmpty) {
          return _AvatarInfo(
            name: employer.companyName,
            avatar: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(logoUrl),
            ),
          );
        }

        return _AvatarInfo(
          name: employer.companyName,
          avatar: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              employer.logoText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      case UserRole.admin:
        return _AvatarInfo(
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
        final candidate = await CandidateRepository().getCurrentCandidate();
        if (candidate == null) return _fallbackAvatarInfo;

        final avatarUrl = candidate.avatarUrl?.trim() ?? '';
        if (avatarUrl.isNotEmpty) {
          return _AvatarInfo(
            name: candidate.displayName,
            avatar: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          );
        }

        return _AvatarInfo(
          name: candidate.displayName,
          avatar: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              candidate.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
    }
  }

  _AvatarInfo get _fallbackAvatarInfo {
    switch (widget.role) {
      case UserRole.employer:
        return _AvatarInfo(
          name: 'Employer',
          avatar: const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
        );
      case UserRole.admin:
        return _AvatarInfo(
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
        return _AvatarInfo(
          name: 'Candidate',
          avatar: const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
        );
    }
  }
}

class _AvatarInfo {
  final String name;
  final Widget avatar;

  const _AvatarInfo({required this.name, required this.avatar});
}
