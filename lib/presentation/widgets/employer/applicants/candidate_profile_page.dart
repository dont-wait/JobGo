import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_candidate.dart';

class CandidateProfilePage extends StatefulWidget {
  final CandidateModel candidate;

  const CandidateProfilePage({super.key, required this.candidate});

  @override
  State<CandidateProfilePage> createState() => _CandidateProfilePageState();
}

class _CandidateProfilePageState extends State<CandidateProfilePage> {
  int _currentTab = 0;
  final List<String> _tabs = ['About', 'Experience', 'Skills', 'Resume'];

  String get _resumeFileName {
    final cleanName = widget.candidate.fullName.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '_',
    );

    return '${cleanName}_resume.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Candidate Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          _buildTabBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.candidate.avatarUrl),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.candidate.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          Text(
            widget.candidate.experience,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                widget.candidate.address,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton('Reject', AppColors.error, Icons.close, () {}),
              const SizedBox(width: 12),
              _buildActionButton(
                'Shortlist',
                AppColors.white,
                null,
                () {},
                borderColor: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                'Schedule',
                AppColors.primary,
                null,
                () {},
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color bgColor,
    IconData? icon,
    VoidCallback onTap, {
    Color? textColor,
    Color borderColor = Colors.transparent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? AppColors.error, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    textColor ??
                    (bgColor == AppColors.white
                        ? AppColors.primary
                        : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: Row(
        children: _tabs.asMap().entries.map((e) {
          final index = e.key;
          final title = e.value;
          final isActive = index == _currentTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Lead Product Designer with 8+ years of experience in creating user-centric digital experiences. Proven track record of leading design teams and delivering high-impact solutions for FinTech and SaaS platforms. Expert in design systems and strategic user research.',
              style: const TextStyle(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Experience',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildExperienceItem(
              'Lead Product Designer',
              'TechFlow Systems • 2020 - Present',
              'Managing a team of 12 designers and overseeing the entire design lifecycle for core products.',
            ),
            const SizedBox(height: 20),
            _buildExperienceItem(
              'Senior UI/UX Designer',
              'Innovate Hub • 2017 - 2020',
              '',
            ),
            const SizedBox(height: 32),
            const Text(
              'Skills',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.candidate.skill
                  .split(',')
                  .map((s) => _buildSkillChip(s.trim()))
                  .toList(),
            ),
          ],
        );

      case 1:
        return const Center(child: Text('Experience tab content'));
      case 2:
        return const Center(child: Text('Skills tab content'));

      case 3:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _resumeFileName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildExperienceItem(
    String title,
    String company,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 10, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                company,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(height: 1.5)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
