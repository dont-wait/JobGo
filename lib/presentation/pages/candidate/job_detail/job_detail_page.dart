import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_info_grid.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_description_section.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_requirements_section.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_benefits_section.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_apply_button.dart';
import 'package:jobgo/presentation/pages/candidate/apply_job/apply_job_route.dart';
import 'package:jobgo/presentation/pages/common/chat_detail_page.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/employer_detail_popup.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:provider/provider.dart';
import 'package:jobgo/presentation/providers/bookmark_provider.dart';
import 'package:jobgo/presentation/providers/application_provider.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';

/// Trang chi tiết công việc
class JobDetailPage extends StatefulWidget {
  final JobModel job;

  const JobDetailPage({super.key, required this.job});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool _hasAlreadyApplied = false;
  bool _isLoadingStatus = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final profile = context.read<ProfileProvider>().candidate;
    if (profile == null) return;

    final provider = context.read<ApplicationProvider>();

    // Check cache first
    if (provider.isApplied(int.parse(widget.job.id))) {
      setState(() => _hasAlreadyApplied = true);
      return;
    }

    setState(() => _isLoadingStatus = true);

    try {
      final applied = await provider.hasApplied(
        int.parse(widget.job.id),
        profile.cId,
      );
      if (mounted) {
        setState(() {
          _hasAlreadyApplied = applied;
          _isLoadingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStatus = false);
    }
  }

  void _showSavedPopup() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SavedPopup(onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.jobDetails,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          // Bookmark selector (rút gọn)
          Consumer<BookmarkProvider>(
            builder: (context, provider, child) {
              final isSaved = provider.isBookmarked(widget.job.id);
              return IconButton(
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.warning : AppColors.textSecondary,
                ),
                onPressed: () {
                  if (!isSaved) _showSavedPopup();
                  provider.toggleBookmark(widget.job.id);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  if (widget.job.badge != null) ...[
                    _buildBadge(),
                    const SizedBox(height: 16),
                  ],
                  if (widget.job.applicants != null) ...[
                    _buildApplicantsInfo(),
                    const SizedBox(height: 20),
                  ],
                  JobInfoGrid(
                    salary: widget.job.formattedSalary,
                    jobType: widget.job.type,
                    postedTime: widget.job.postedTimeAgo,
                  ),
                  const SizedBox(height: 24),
                  _buildEmployerSection(),
                  const SizedBox(height: 24),
                  if (widget.job.tags != null &&
                      widget.job.tags!.isNotEmpty) ...[
                    _buildTags(),
                    const SizedBox(height: 24),
                  ],
                  if (widget.job.description != null &&
                      widget.job.description!.isNotEmpty) ...[
                    JobDescriptionSection(description: widget.job.description!),
                    const SizedBox(height: 24),
                  ],
                  if (widget.job.requirements != null &&
                      widget.job.requirements!.isNotEmpty) ...[
                    JobRequirementsSection(
                      requirements: widget.job.requirements!,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.job.benefits != null &&
                      widget.job.benefits!.isNotEmpty) ...[
                    JobBenefitsSection(benefits: widget.job.benefits!),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // ── Apply Button với trạng thái applied check ──
          JobApplyButton(
            label: _hasAlreadyApplied
                ? loc.alreadyApplied
                : (widget.job.isOpen ? loc.applyNow : loc.jobClosed),
            isEnabled: !_hasAlreadyApplied && widget.job.isOpen,
            isLoading: _isLoadingStatus,
            onPressed: () => navigateToApply(context, widget.job).then((_) {
              // Refresh status after applying
              _checkApplicationStatus();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: CompanyLogo(
            imageUrl: widget.job.logoUrl,
            fallbackText: widget.job.logoText,
            backgroundColor: Color(int.parse(widget.job.logoColor)),
            width: 72,
            height: 72,
            borderRadius: 18,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            widget.job.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            widget.job.company,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (widget.job.location.isNotEmpty)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.job.location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBadge() {
    final isUrgent = widget.job.badge!.toUpperCase() == 'URGENT';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isUrgent
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          widget.job.badge!,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isUrgent ? AppColors.error : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicantsInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.people_outline_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          '${widget.job.applicants ?? 0} ${AppLocalizations.of(context).applicantsSoFar}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.job.tags!.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToChat(BuildContext context) {
    final employerUserId = widget.job.employerUserId;
    if (employerUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy tài khoản nhà tuyển dụng này.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          otherUserId: employerUserId,
          otherUserName: widget.job.company,
          avatarColor: Color(int.parse(widget.job.logoColor)),
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchEmail(String email, String jobTitle) async {
    final Uri url = Uri.parse(
      'mailto:$email?subject=Hỏi về công việc: $jobTitle',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWebsite(String website) async {
    var urlStr = website;
    if (!urlStr.startsWith('http://') && !urlStr.startsWith('https://')) {
      urlStr = 'https://$urlStr';
    }
    final Uri url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showEmployerDetailPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmployerDetailPopup(job: widget.job),
    );
  }

  Widget _buildEmployerSection() {
    final phone = widget.job.employerCompanyPhone;
    final email = widget.job.employerCompanyEmail;
    final website = widget.job.employerWebsite;
    final industry = widget.job.employerIndustry;
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                loc.employerLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showEmployerDetailPopup,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      loc.viewDetails,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showEmployerDetailPopup,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CompanyLogo(
                      imageUrl: widget.job.logoUrl,
                      fallbackText: widget.job.logoText,
                      backgroundColor: Color(int.parse(widget.job.logoColor)),
                      width: 54,
                      height: 54,
                      borderRadius: 14,
                      fontSize: 15,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.job.company,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            industry ?? loc.industryLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToChat(context),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(
                    loc.messageNow,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (phone != null && phone.isNotEmpty) ...[
                _buildQuickIconButton(
                  icon: Icons.phone_in_talk_rounded,
                  color: AppColors.success,
                  onTap: () => _launchPhone(phone),
                ),
                const SizedBox(width: 8),
              ],
              if (email != null && email.isNotEmpty) ...[
                _buildQuickIconButton(
                  icon: Icons.alternate_email_rounded,
                  color: const Color(0xFFE11D48),
                  onTap: () => _launchEmail(email, widget.job.title),
                ),
                const SizedBox(width: 8),
              ],
              if (website != null && website.isNotEmpty)
                _buildQuickIconButton(
                  icon: Icons.language_rounded,
                  color: const Color(0xFF0369A1),
                  onTap: () => _launchWebsite(website),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Saved Popup Overlay
// ─────────────────────────────────────────────
class _SavedPopup extends StatefulWidget {
  final VoidCallback onDone;
  const _SavedPopup({required this.onDone});

  @override
  State<_SavedPopup> createState() => _SavedPopupState();
}

class _SavedPopupState extends State<_SavedPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _ctrl.forward();

    // Auto-dismiss after 1.6s
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDone());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Outer glow ring ──
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warningLight,
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.25),
                          width: 6,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.warningGlow,
                                AppColors.warning,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.bookmark_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).jobSaved,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context).addedToFavorites,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
