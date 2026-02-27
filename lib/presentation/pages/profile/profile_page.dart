import 'package:flutter/material.dart';
import '../../../core/configs/theme/app_colors.dart';
import '../../widgets/profile_page/skills_section.dart';
import '../../widgets/profile_page/profile_header.dart';
import '../../widgets/profile_page/profile_tabs.dart';
import '../../widgets/profile_page/experience_section.dart';
import '../../widgets/profile_page/resume_card.dart';
import '../../widgets/profile_page/upload_resume_box.dart';
import '../../widgets/profile_page/favorites_section.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentTab = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.maybePop(context);

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
            const ProfileHeader(),
            const SizedBox(height: 20),

            ///Tabs
            ProfileTabs(
              currentIndex: _currentTab,
              onChanged: (index) {
                setState(() => _currentTab = index);
              },
            ),

            const SizedBox(height: 24),

            // Tab content
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
  switch (_currentTab) {
    case 0:
      return _buildInfoTab();
    case 1:
      return _buildExperienceTab();
    case 2:
      return _buildSkillsTab();
    case 3:
      return _buildFavoritesTab();
    default:
      return const SizedBox.shrink();
  }
}


  //  INFO 
  Widget _buildInfoTab() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        'Resume & Documents',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: 12),

      ResumeCard(
        title: 'Resume_Designer_2024.pdf',
        subtitle: 'Uploaded Oct 12, 2023 · 1.2 MB',
        isDefault: true,
      ),
      SizedBox(height: 12),

      ResumeCard(
        title: 'Creative_CV_Portfolio.pdf',
        subtitle: 'Uploaded Aug 05, 2023 · 2.8 MB',
      ),
      SizedBox(height: 16),

      UploadResumeBox(),
    ],
  );
}


  // EXPERIENCE 
  Widget _buildExperienceTab() {
  return const ExperienceSection();
}


  // SKILLS 
  Widget _buildSkillsTab() {
  return const SkillsSection();
}

  // FAVORITES 
  Widget _buildFavoritesTab() {
  return const FavoritesSection();
}

}
