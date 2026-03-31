import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../presentation/pages/settings/settings_page.dart';
import '../../../../data/models/candidate_supabase_model.dart';
import '../../../../presentation/providers/profile_provider.dart';
import '../../../widgets/candidate/profile_page/skills_section.dart';
import '../../../widgets/candidate/profile_page/profile_header.dart';
import '../../../widgets/candidate/profile_page/profile_tabs.dart';
import '../../../widgets/candidate/profile_page/experience_section.dart';
import '../../../widgets/candidate/profile_page/resume_card.dart';
import '../../../widgets/candidate/profile_page/upload_resume_box.dart';
import '../../../widgets/candidate/profile_page/favorites_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentTab = 1;

  @override
  void initState() {
    super.initState();
    // Load profile khi vào trang
    Future.microtask(() => context.read<ProfileProvider>().loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        // Loading
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (provider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProfile(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        //  Hiển thị profile
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SettingsPage(role: UserRole.candidate),
                    ),
                  );
                },
              ),
            ],
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(candidate: provider.candidate),
                const SizedBox(height: 20),
                ProfileTabs(
                  currentIndex: _currentTab,
                  onChanged: (index) => setState(() => _currentTab = index),
                ),
                const SizedBox(height: 24),
                _buildTabContent(provider.candidate),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent(candidate) {
    switch (_currentTab) {
      case 0:
        return _buildInfoTab(candidate);
      case 1:
        return ExperienceSection(experience: candidate?.experience);
      case 2:
        return SkillsSection(skills: candidate?.skill);
      case 3:
        return const FavoritesSection();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _replaceResume(String oldUrl) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result == null) return;

      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final filePath = '${authUser.id}/$fileName';

      // Upload lên Supabase Storage
      await supabase.storage
          .from('cv-bucket')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // Lấy public URL
      final publicUrl = supabase.storage
          .from('cv-bucket')
          .getPublicUrl(filePath);

      // Thay thế URL trong provider
      if (!mounted) return;
      await context.read<ProfileProvider>().replaceResume(oldUrl, publicUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Replaced successfully with: $fileName'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Replace failed: $e')));
    }
  }

  void _viewResume(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Resume Preview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                url.split('/').last,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open the CV URL'),
                              ),
                            );
                          }
                        }
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab(CandidateSupabaseModel? candidate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Resume & Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (candidate?.resumes != null)
              Text(
                '${candidate!.resumes!.length} FILES',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (candidate?.resumes != null && candidate!.resumes!.isNotEmpty)
          ...candidate.resumes!.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return ResumeCard(
              title: url.split('/').last,
              subtitle:
                  'Uploaded ${candidate.createdAt != null ? candidate.createdAt!.toString().substring(0, 10) : "Recently"}',
              isDefault: index == 0,
              onTap: () => _viewResume(url),
              onDelete: () => context.read<ProfileProvider>().removeResume(url),
              onSetDefault: index == 0
                  ? null
                  : () => context.read<ProfileProvider>().setDefaultResume(url),
              onReplace: () => _replaceResume(url),
            );
          }).toList(),
        if (candidate?.title != null && candidate!.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              'Vị trí mong muốn: ${candidate.title}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        if (candidate?.summary != null && candidate!.summary!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              candidate.summary!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 16),
        const UploadResumeBox(),
      ],
    );
  }
}
