
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/presentation/pages/candidate/profile/candidate_edit_profile_page.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import '../../../../core/configs/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final CandidateSupabaseModel? candidate;

  const ProfileHeader({super.key, this.candidate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: candidate?.avatarUrl != null
                    ? NetworkImage(candidate!.avatarUrl!) as ImageProvider
                    : const AssetImage('assets/images/role_candidate.jpg'),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            candidate?.fullName ?? 'Your Name',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            candidate?.address ?? 'Update your profile',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CandidateEditProfilePage(
                    candidate: candidate,
                  ),
                ),
              );
              // Reload profile sau khi edit xong
              if (context.mounted) {
                context.read<ProfileProvider>().reloadProfile();
              }
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}