import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/ai_cv_analysis_model.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/data/repositories/ai_cv_analysis_repository.dart';
import 'package:jobgo/data/repositories/candidate_repository.dart';
import 'package:jobgo/data/repositories/job_application_repository.dart';
import 'package:jobgo/data/services/gemini_cv_analysis_service.dart';
import 'package:jobgo/presentation/pages/employer/interview_schedule/interview_schedule_page.dart';

class CandidateProfilePage extends StatefulWidget {
  final CandidateSupabaseModel candidate;
  final JobApplicantModel? application;
  final AiCvAnalysisModel? initialAiAnalysis;

  const CandidateProfilePage({
    super.key,
    required this.candidate,
    this.application,
    this.initialAiAnalysis,
  });

  @override
  State<CandidateProfilePage> createState() => _CandidateProfilePageState();
}

class _CandidateProfilePageState extends State<CandidateProfilePage> {
  int _currentTab = 0;
  final List<String> _tabs = ['About', 'Experience', 'Skills', 'Resume'];
  CandidateSupabaseModel? _fullCandidate;
  final AiCvAnalysisRepository _analysisRepository = AiCvAnalysisRepository();
  final GeminiCvAnalysisService _geminiService = GeminiCvAnalysisService();
  AiCvAnalysisModel? _aiAnalysis;
  bool _isAnalyzing = false;
  String? _analysisError;
  String? _currentLanguageCode;
  int _analysisRequestToken = 0;
  String? get _resumeUrl {
    final candidateResume = widget.candidate.resume?.trim() ?? '';
    if (candidateResume.isNotEmpty) {
      return candidateResume;
    }

    final applicationResume = widget.application?.cvUrl.trim() ?? '';
    return applicationResume.isNotEmpty ? applicationResume : null;
  }

  @override
  void initState() {
    super.initState();
    _aiAnalysis = widget.initialAiAnalysis;
    _loadFullCandidate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Localizations.localeOf(context).languageCode;
    if (_currentLanguageCode == languageCode) return;
    final isFirstLocale = _currentLanguageCode == null;
    _currentLanguageCode = languageCode;
    _analysisRequestToken++;

    final application = widget.application;
    if (application == null) return;

    if (!isFirstLocale &&
        (_analysisError != null || _aiAnalysis != null || _isAnalyzing)) {
      setState(() {
        _analysisError = null;
        _aiAnalysis = null;
        _isAnalyzing = false;
      });
    }

    _loadCachedAnalysis(
      languageCode: languageCode,
      requestToken: _analysisRequestToken,
    );
  }

  Future<void> _loadFullCandidate() async {
    final repo = CandidateRepository();
    final full = await repo.fetchCandidateById(widget.candidate.cId);
    if (mounted && full != null) {
      setState(() => _fullCandidate = full);
    } else {
      // Fallback: dùng widget.candidate luôn dù không có join data
      if (mounted) setState(() => _fullCandidate = widget.candidate);
    }
  }

  Future<void> _loadCachedAnalysis({
    required String languageCode,
    required int requestToken,
  }) async {
    final application = widget.application;
    if (application == null) return;

    final cached = await _analysisRepository.fetchCachedAnalysis(
      applicationId: application.applicationId,
      jobId: application.jobId,
      cvUrl: application.cvUrl,
      languageCode: languageCode,
    );
    if (!mounted ||
        cached == null ||
        requestToken != _analysisRequestToken ||
        _currentLanguageCode != languageCode) {
      return;
    }

    setState(() {
      _aiAnalysis = cached;
    });
  }

  Future<void> _analyzeApplication() async {
    final application = widget.application;
    if (application == null) return;
    if (_isAnalyzing) return;
    final loc = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final requestToken = ++_analysisRequestToken;

    final cvUrl = application.cvUrl.trim();
    if (!GeminiCvAnalysisService.isPdfUrl(cvUrl)) {
      setState(() {
        _analysisError = loc.aiAnalysisSupportsPdfOnly;
      });
      return;
    }

    final job = application.job;
    if (job == null) {
      setState(() {
        _analysisError = loc.missingJobDetailsForAiAnalysis;
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    try {
      final result = await _geminiService.analyzeCv(
        applicationId: application.applicationId,
        jobId: application.jobId,
        candidateId: application.candidateId,
        cvUrl: application.cvUrl,
        job: job,
        candidate: _candidate,
        coverLetter: application.coverLetter,
        languageCode: languageCode,
      );
      final saved = await _analysisRepository.saveAnalysis(result);
      if (!mounted ||
          requestToken != _analysisRequestToken ||
          _currentLanguageCode != languageCode) {
        return;
      }
      setState(() {
        _aiAnalysis = saved ?? result;
      });
    } catch (e) {
      if (!mounted || requestToken != _analysisRequestToken) return;
      setState(() {
        _analysisError =
            '${loc.analyzeFailed}: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted && requestToken == _analysisRequestToken) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  CandidateSupabaseModel get _candidate => _fullCandidate ?? widget.candidate;
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final hasApplication = widget.application != null;

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
            padding: EdgeInsets.only(bottom: hasApplication ? 132 : 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(loc),
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
      bottomNavigationBar: hasApplication
          ? SafeArea(top: false, child: _buildApplicantActionBar())
          : null,
    );
  }

  Widget _buildProfileHeader(AppLocalizations loc) {
    // final candidate = widget.candidate;
    final candidate = _candidate;

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
            const SizedBox(height: 12),
            _buildAiInsightCard(loc),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicantActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Application actions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Reject',
                  AppColors.error,
                  Icons.close,
                  _confirmRejectCandidate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Shortlist',
                  AppColors.white,
                  null,
                  _shortlistCandidate,
                  borderColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Schedule',
                  AppColors.primary,
                  null,
                  _openInterviewSchedule,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(AppLocalizations loc) {
    final analysis = _aiAnalysis;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                loc.aiInsight,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (analysis != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${analysis.matchScore}/100',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_analysisError != null) ...[
            Text(
              _analysisError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
          if (analysis == null)
            Text(
              loc.noAiAnalysisYet,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            )
          else ...[
            Text(
              analysis.summary,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            if (analysis.gaps.isNotEmpty)
              Text(
                '${loc.missingSkillsLabel} ${analysis.gaps.take(3).join(' • ')}',
                style: const TextStyle(fontSize: 12),
              ),
            if (analysis.riskFlags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${loc.interviewChecksLabel} ${analysis.riskFlags.take(3).join(' • ')}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeApplication,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_fix_high_rounded, size: 16),
              label: Text(analysis == null ? loc.analyze : loc.reanalyze),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
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
          mainAxisAlignment: MainAxisAlignment.center,
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
    if (_fullCandidate == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }
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
          // child: widget.candidate.hasSummary
          child: _candidate.hasSummary
              ? Text(
                  // widget.candidate.cleanSummary,
                  _candidate.cleanSummary,
                  style: const TextStyle(
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                )
              : const Text(
                  'No profile summary provided.',
                  style: TextStyle(height: 1.6, color: AppColors.textSecondary),
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
            // value: widget.candidate.roleLabel,
            value: _candidate.roleLabel,
            icon: Icons.badge_outlined,
          ),
          (
            label: 'Seniority',
            // value: widget.candidate.seniorityLabel,
            value: _candidate.seniorityLabel,
            icon: Icons.trending_up_outlined,
          ),
          (
            label: 'Education',
            // value: widget.candidate.displayEducation,
            value: _candidate.displayEducation,
            icon: Icons.school_outlined,
          ),
          (
            label: 'Salary',
            // value: widget.candidate.salaryLabel,
            value: _candidate.salaryLabel,
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
            // value: widget.candidate.displayPhone,
            value: _candidate.displayPhone,
            icon: Icons.phone_outlined,
          ),
          (
            label: 'Email',
            // value: widget.candidate.displayEmail,
            value: _candidate.displayEmail,
            icon: Icons.email_outlined,
          ),
          (
            label: 'Location',
            // value: widget.candidate.displayLocation,
            value: _candidate.displayLocation,
            icon: Icons.location_on_outlined,
          ),
          (
            label: 'Date of Birth',
            // value: widget.candidate.dateOfBirth ?? 'Not provided',
            value: _candidate.dateOfBirth ?? 'Not provided',
            icon: Icons.cake_outlined,
          ),
        ]),
      ],
    );
  }

  // Widget _buildExperienceTab() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Experience Summary',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //       const SizedBox(height: 12),
  //       _buildSectionCard(
  //         child: Text(
  //           widget.candidate.displayExperience,
  //           style: const TextStyle(height: 1.6, color: AppColors.textSecondary),
  //         ),
  //       ),
  //       const SizedBox(height: 20),
  //       const Text(
  //         'Background',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //       const SizedBox(height: 12),
  //       _buildFactGrid([
  //         (
  //           label: 'Role Match',
  //           value: widget.candidate.roleLabel,
  //           icon: Icons.work_outline,
  //         ),
  //         (
  //           label: 'Seniority',
  //           value: widget.candidate.seniorityLabel,
  //           icon: Icons.bar_chart_outlined,
  //         ),
  //         (
  //           label: 'Gender',
  //           value: widget.candidate.gender ?? 'Not provided',
  //           icon: Icons.wc_outlined,
  //         ),
  //         (
  //           label: 'User ID',
  //           value: widget.candidate.uId.toString(),
  //           icon: Icons.confirmation_number_outlined,
  //         ),
  //       ]),
  //     ],
  //   );
  // }
  Widget _buildExperienceTab() {
    // print(widget.candidate.experiences);
    // print('Candidate ID: ${widget.candidate.cId}');
    // print('Experiences: ${widget.candidate.experiences}');
    // print('Skills: ${widget.candidate.skills}');
    // final experiences = widget.candidate.experiences;
    final experiences = _candidate.experiences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Experience',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (experiences == null || experiences.isEmpty)
          _buildSectionCard(
            child: const Text(
              'No experience provided yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          Column(
            children: experiences.map((exp) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.work, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.position,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exp.companyName,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exp.period,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                          if (exp.description != null &&
                              exp.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              exp.description!,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
            // value: widget.candidate.roleLabel,
            value: _candidate.roleLabel,
            icon: Icons.work_outline,
          ),
          (
            label: 'Seniority',
            // value: widget.candidate.seniorityLabel,
            value: _candidate.seniorityLabel,
            icon: Icons.bar_chart_outlined,
          ),
          (
            label: 'Gender',
            // value: widget.candidate.gender ?? 'Not provided',
            value: _candidate.gender ?? "Not provided",
            icon: Icons.wc_outlined,
          ),
          (
            label: 'User ID',
            // value: widget.candidate.uId.toString(),
            value: _candidate.uId.toString(),
            icon: Icons.confirmation_number_outlined,
          ),
        ]),
      ],
    );
  }

  // Widget _buildSkillsTab() {
  //   final skillList = widget.candidate.skillList;

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Skills',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //       const SizedBox(height: 12),
  //       if (skillList.isEmpty)
  //         _buildSectionCard(
  //           child: const Text(
  //             'No skills were provided for this profile yet.',
  //             style: TextStyle(color: AppColors.textSecondary),
  //           ),
  //         )
  //       else
  //         Wrap(
  //           spacing: 8,
  //           runSpacing: 8,
  //           children: skillList.map((skill) => _buildSkillChip(skill)).toList(),
  //         ),
  //     ],
  //   );
  // }
  Widget _buildSkillsTab() {
    // final skills = widget.candidate.skills;
    final skills = _candidate.skills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (skills == null || skills.isEmpty)
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
            children: skills
                .map(
                  (skill) => _buildSkillChip(
                    skill.csYears != null
                        ? '${skill.skName} • ${skill.csYears} yrs'
                        : skill.skName,
                  ),
                )
                .toList(),
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
                  // widget.candidate.resumeFileName,
                  _candidate.resumeFileName,
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

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
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

  Future<void> _shortlistCandidate() async {
    if (widget.application == null) return;

    try {
      final repository = JobApplicationRepository();
      final success = await repository.shortlistApplication(
        widget.application!.applicationId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Candidate shortlisted successfully.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to shortlist candidate. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _confirmRejectCandidate() async {
    if (widget.application == null) return;

    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject candidate?'),
        content: const Text(
          'This will mark the candidate as rejected for the current job.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reject',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldReject == true) {
      try {
        final repository = JobApplicationRepository();
        final success = await repository.rejectApplication(
          widget.application!.applicationId,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Candidate rejected successfully.')),
            );
            // Go back to applicants list after rejection
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to reject candidate. Please try again.'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _openInterviewSchedule() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InterviewSchedulePage()),
    );
  }
}
