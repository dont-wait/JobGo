import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';

class CandidateProfilePage extends StatefulWidget {
  final CandidateSupabaseModel candidate;
  final JobApplicantModel? application;

  const CandidateProfilePage({
    super.key,
    required this.candidate,
    this.application,
  });

  @override
  State<CandidateProfilePage> createState() => _CandidateProfilePageState();
}

class _CandidateProfilePageState extends State<CandidateProfilePage> {
  int _currentTab = 0;
  final List<String> _tabs = ['About', 'Experience', 'Skills', 'Resume'];

  String? get _resumeUrl {
    final candidateResume = widget.candidate.resume?.trim() ?? '';
    if (candidateResume.isNotEmpty) {
      return candidateResume;
    }

    final applicationResume = widget.application?.cvUrl.trim() ?? '';
    return applicationResume.isNotEmpty ? applicationResume : null;
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
          if (_resumeUrl != null)
            IconButton(
              icon: const Icon(
                Icons.copy_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: _copyResumeLink,
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 12),
                  _buildTabBar(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    final candidate = widget.candidate;
    final application = widget.application;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _buildAvatar(candidate),
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
            candidate.displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          Text(
            candidate.displayHeadline,
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
                candidate.displayLocation,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPill(candidate.roleLabel),
              _buildPill(candidate.seniorityLabel),
              _buildPill(candidate.salaryLabel),
              if (application != null)
                _buildStatusPill(application.statusLabel),
            ],
          ),

          if (application != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        application.appliedTimeAgo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    application.coverLetter.isNotEmpty
                        ? application.coverLetter
                        : 'No cover letter was submitted for this application.',
                    style: const TextStyle(
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if ((application.internalNotes ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Internal Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      application.internalNotes!,
                      style: const TextStyle(
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton('Reject', AppColors.error, Icons.close, () {}),
              _buildActionButton(
                'Shortlist',
                AppColors.white,
                null,
                () {},
                borderColor: AppColors.primary,
              ),
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
    final resolvedTextColor =
        textColor ??
        (bgColor == AppColors.white ? AppColors.primary : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: resolvedTextColor, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: resolvedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
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
        return _buildAboutTab();
      case 1:
        return _buildExperienceTab();
      case 2:
        return _buildSkillsTab();
      case 3:
        return _buildResumeTab();

      default:
        return const SizedBox();
    }
  }

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          child: Text(
            widget.candidate.displaySummary,
            style: const TextStyle(height: 1.6, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Overview',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildFactGrid([
          (
            label: 'Role',
            value: widget.candidate.roleLabel,
            icon: Icons.badge_outlined,
          ),
          (
            label: 'Seniority',
            value: widget.candidate.seniorityLabel,
            icon: Icons.trending_up_outlined,
          ),
          (
            label: 'Education',
            value: widget.candidate.displayEducation,
            icon: Icons.school_outlined,
          ),
          (
            label: 'Salary',
            value: widget.candidate.salaryLabel,
            icon: Icons.payments_outlined,
          ),
        ]),
        const SizedBox(height: 20),
        const Text(
          'Contact',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildFactGrid([
          (
            label: 'Phone',
            value: widget.candidate.displayPhone,
            icon: Icons.phone_outlined,
          ),
          (
            label: 'Email',
            value: widget.candidate.displayEmail,
            icon: Icons.email_outlined,
          ),
          (
            label: 'Location',
            value: widget.candidate.displayLocation,
            icon: Icons.location_on_outlined,
          ),
          (
            label: 'Date of Birth',
            value: widget.candidate.dateOfBirth ?? 'Not provided',
            icon: Icons.cake_outlined,
          ),
        ]),
      ],
    );
  }

  Widget _buildExperienceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Experience Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          child: Text(
            widget.candidate.displayExperience,
            style: const TextStyle(height: 1.6, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Background',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildFactGrid([
          (
            label: 'Role Match',
            value: widget.candidate.roleLabel,
            icon: Icons.work_outline,
          ),
          (
            label: 'Seniority',
            value: widget.candidate.seniorityLabel,
            icon: Icons.bar_chart_outlined,
          ),
          (
            label: 'Gender',
            value: widget.candidate.gender ?? 'Not provided',
            icon: Icons.wc_outlined,
          ),
          (
            label: 'User ID',
            value: widget.candidate.uId.toString(),
            icon: Icons.confirmation_number_outlined,
          ),
        ]),
      ],
    );
  }

  Widget _buildSkillsTab() {
    final skillList = widget.candidate.skillList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (skillList.isEmpty)
          _buildSectionCard(
            child: const Text(
              'No skills were provided for this profile yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skillList.map((skill) => _buildSkillChip(skill)).toList(),
          ),
      ],
    );
  }

  Widget _buildResumeTab() {
    final resumeUrl = _resumeUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resume',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (resumeUrl == null)
          _buildSectionCard(
            child: const Text(
              'No resume has been uploaded yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          _buildSectionCard(
            child: Column(
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.candidate.resumeFileName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  resumeUrl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _copyResumeLink,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy Resume Link'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildFactGrid(
    List<({String label, String value, IconData icon})> facts,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: facts
              .map(
                (fact) => SizedBox(
                  width: itemWidth,
                  child: _buildFactCard(
                    label: fact.label,
                    value: fact.value,
                    icon: fact.icon,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildFactCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(CandidateSupabaseModel candidate) {
    final avatarUrl = candidate.avatarUrl?.trim() ?? '';

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(radius: 50, backgroundImage: NetworkImage(avatarUrl));
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        candidate.initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _copyResumeLink() async {
    final resumeUrl = _resumeUrl;
    if (resumeUrl == null || resumeUrl.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: resumeUrl));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resume link copied to clipboard')),
    );
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
