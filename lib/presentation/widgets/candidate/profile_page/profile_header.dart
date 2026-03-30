import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/presentation/pages/candidate/profile/candidate_edit_profile_page.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import '../../../../core/configs/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final CandidateSupabaseModel? candidate;

  const ProfileHeader({super.key, this.candidate});

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Chụp ảnh'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chọn từ thư viện'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;

      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      final fileBytes = await pickedFile.readAsBytes();
      final fileName = 'avatar_${authUser.id}.jpg';

      // ✅ Upload lên Storage
      await supabase.storage.from('avatars').uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // ✅ Lấy u_id trước
      final userRow = await supabase
          .from('users')
          .select('u_id')
          .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
          .maybeSingle();

      if (userRow == null) return;
      final uId = userRow['u_id'] as int;

      // ✅ Update đúng cột, đúng điều kiện
      await supabase
          .from('candidates')
          .update({'c_avatar_url': publicUrl}) // ✅ đúng tên cột
          .eq('u_id', uId); // ✅ đúng điều kiện

      if (context.mounted) {
        context.read<ProfileProvider>().reloadProfile();
      }
    }
  }

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
                    ? NetworkImage(candidate!.avatarUrl!)
                    : const AssetImage('assets/images/role_candidate.jpg'),
              ),
              InkWell(
                onTap: () => _pickAndUploadAvatar(context),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.camera_alt,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            candidate?.fullName ?? 'Your Name',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
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