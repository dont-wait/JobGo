import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../presentation/pages/settings/settings_page.dart';
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
    Future.microtask(() =>
      context.read<ProfileProvider>().loadProfile()
    );
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
                      builder: (_) => const SettingsPage(role: UserRole.candidate),
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

  Widget _buildInfoTab(candidate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resume & Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (candidate?.resume != null)
          ResumeCard(
            title: candidate!.resume!,
            subtitle: 'CV của bạn',
            isDefault: true,
          ),
          if (candidate?.title != null && candidate!.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
        const SizedBox(height: 16),
        const UploadResumeBox(),
      ],
    );
  }
}