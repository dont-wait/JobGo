import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';
import 'package:jobgo/presentation/pages/common/chat_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Popup xem thông tin chi tiết nhà tuyển dụng (HR)
class EmployerDetailPopup extends StatefulWidget {
  final JobModel job;

  const EmployerDetailPopup({super.key, required this.job});

  @override
  State<EmployerDetailPopup> createState() => _EmployerDetailPopupState();
}

class _EmployerDetailPopupState extends State<EmployerDetailPopup>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _recruiterName;
  String? _description;
  String? _address;
  String? _companySize;
  String? _phone;
  String? _email;
  String? _website;
  String? _industry;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fetchEmployerDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployerDetails() async {
    final employerUserId = widget.job.employerUserId;
    if (employerUserId == null) {
      _loadFallbackData();
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('employers')
          .select('*, users(u_name)')
          .eq('u_id', employerUserId)
          .maybeSingle();

      if (response != null && mounted) {
        final userData = response['users'] as Map<String, dynamic>?;
        setState(() {
          _recruiterName = userData != null ? userData['u_name'] as String? : null;
          _description = response['e_company_description'] as String?;
          _address = response['e_company_address'] as String?;
          _companySize = response['e_company_size'] as String?;
          _phone = response['e_phone'] as String? ?? widget.job.employerCompanyPhone;
          _email = response['e_email'] as String? ?? widget.job.employerCompanyEmail;
          _website = response['e_website'] as String? ?? widget.job.employerWebsite;
          _industry = response['e_industry'] as String? ?? widget.job.employerIndustry;
          _isLoading = false;
        });
        _fadeController.forward();
      } else {
        _loadFallbackData();
      }
    } catch (_) {
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    if (!mounted) return;
    setState(() {
      _phone = widget.job.employerCompanyPhone;
      _email = widget.job.employerCompanyEmail;
      _website = widget.job.employerWebsite;
      _industry = widget.job.employerIndustry;
      _isLoading = false;
    });
    _fadeController.forward();
  }

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchEmail(String email) async {
    final loc = AppLocalizations.of(context);
    final Uri url = Uri.parse(
      'mailto:$email?subject=${loc.emailSubjectQuery}: ${widget.job.title}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWebsite(String website) async {
    var urlStr = website.trim();
    if (!urlStr.startsWith('http://') && !urlStr.startsWith('https://')) {
      urlStr = 'https://$urlStr';
    }
    final Uri url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(String text, String successMsg) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _navigateToChat() {
    final employerUserId = widget.job.employerUserId;
    final loc = AppLocalizations.of(context);
    if (employerUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.employerAccountNotFound),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pop(context); // Close the bottom sheet
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // ── Drag Handle & Header ──
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Spacer to balance close button
                Text(
                  AppLocalizations.of(context).employerDetail,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          Expanded(
            child: _isLoading ? _buildSkeletonLoader() : _buildContent(),
          ),

          // ── Bottom Action Sticky Button ──
          if (!_isLoading) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo skeleton
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          // Title skeleton
          Container(
            width: 180,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 32),
          // Info skeleton blocks
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.divider,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final loc = AppLocalizations.of(context);
    final companyColor = Color(int.parse(widget.job.logoColor));
    final hasDesc = _description != null && _description!.isNotEmpty;

    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Employer Visual Identity Header ──
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: companyColor.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CompanyLogo(
                      imageUrl: widget.job.logoUrl,
                      fallbackText: widget.job.logoText,
                      backgroundColor: companyColor,
                      width: 84,
                      height: 84,
                      borderRadius: 20,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.job.company,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  if (_recruiterName != null && _recruiterName!.isNotEmpty) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'HR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _recruiterName!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context).activeNow,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Info Grid / List ──
            Text(
              AppLocalizations.of(context).contactInfo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 14),

            // Lĩnh vực hoạt động
            if (_industry != null && _industry!.isNotEmpty)
              _buildDetailItem(
                icon: Icons.business_rounded,
                iconColor: AppColors.primary,
                label: loc.industryLabel,
                content: _industry!,
              ),

            // Quy mô công ty
            if (_companySize != null && _companySize!.isNotEmpty)
              _buildDetailItem(
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFF8B5CF6),
                label: loc.companySize,
                content: _companySize!,
              ),

            // Địa chỉ công ty
            if (_address != null && _address!.isNotEmpty)
              _buildDetailItem(
                icon: Icons.location_on_rounded,
                iconColor: AppColors.error,
                label: loc.addressLabel,
                content: _address!,
                onAction: () => _copyToClipboard(_address!, loc.copyAddressSuccess),
                actionIcon: Icons.copy_rounded,
              ),

            // Website công ty
            if (_website != null && _website!.isNotEmpty)
              _buildDetailItem(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF0369A1),
                label: loc.websiteLabel,
                content: _website!,
                onAction: () => _launchWebsite(_website!),
                actionIcon: Icons.open_in_new_rounded,
              ),

            // Số điện thoại liên hệ
            if (_phone != null && _phone!.isNotEmpty)
              _buildDetailItem(
                icon: Icons.phone_in_talk_rounded,
                iconColor: AppColors.success,
                label: loc.phoneLabel,
                content: _phone!,
                onAction: () => _launchPhone(_phone!),
                actionIcon: Icons.phone_forwarded_rounded,
              ),

            // Email tuyển dụng
            if (_email != null && _email!.isNotEmpty)
              _buildDetailItem(
                icon: Icons.alternate_email_rounded,
                iconColor: const Color(0xFFE11D48),
                label: loc.emailLabel,
                content: _email!,
                onAction: () => _launchEmail(_email!),
                actionIcon: Icons.mail_rounded,
              ),

            const SizedBox(height: 20),

            // ── Company Description / About ──
            if (hasDesc) ...[
              const Divider(color: AppColors.divider, height: 32),
              Text(
                AppLocalizations.of(context).about,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  _description!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String content,
    VoidCallback? onAction,
    IconData? actionIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onAction != null && actionIcon != null) ...[
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(actionIcon, color: AppColors.textSecondary, size: 16),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: _navigateToChat,
          icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
          label: Text(
            AppLocalizations.of(context).chatWithEmployer,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
