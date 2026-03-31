import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/presentation/providers/application_provider.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ApplyJobPage extends StatefulWidget {
  final JobModel job;

  const ApplyJobPage({super.key, required this.job});

  @override
  State<ApplyJobPage> createState() => _ApplyJobPageState();
}

class _ApplyJobPageState extends State<ApplyJobPage> {
  int _currentStep = 0; // 0 = Step 1, 1 = Step 2, 2 = Success
  int _selectedCvIndex = 0;
  final _coverLetterController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    final profile = context.read<ProfileProvider>().candidate;
    if (profile == null || (profile.resumes ?? []).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm CV vào hồ sơ trước khi ứng tuyển'),
        ),
      );
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _goBack() => setState(() => _currentStep = 0);

  Future<void> _submit() async {
    final profile = context.read<ProfileProvider>().candidate;
    if (profile == null) return;

    final resumes = profile.resumes ?? [];
    if (resumes.isEmpty) return;

    setState(() => _isSubmitting = true);

    final success = await context.read<ApplicationProvider>().applyToJob(
      jobId: int.parse(widget.job.id),
      candidateId: profile.cId,
      coverLetter: _coverLetterController.text,
      cvUrl: resumes[_selectedCvIndex],
    );

    setState(() => _isSubmitting = false);

    if (success) {
      setState(() => _currentStep = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ứng tuyển thất bại, vui lòng thử lại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 2) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _isSubmitting
              ? null
              : (_currentStep == 1 ? _goBack : () => Navigator.pop(context)),
        ),
        title: const Text(
          'Apply for Job',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isSubmitting)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(child: _currentStep == 0 ? _buildStep1() : _buildStep2()),
          if (_currentStep == 0) _buildNextButton(),
        ],
      ),
    );
  }

  // ── Step Indicator ──
  Widget _buildStepIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _currentStep == 0 ? 0.5 : 1.0,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 3,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentStep == 0 ? 'STEP 1 OF 2' : 'Step 2 of 2',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _currentStep == 0
                      ? AppColors.textPrimary
                      : AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _currentStep == 0 ? 'Resume Selection' : 'FINAL REVIEW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _currentStep == 0
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  letterSpacing: _currentStep == 1 ? 0.5 : 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────
  // STEP 1: Select CV
  // ─────────────────────────────
  Widget _buildStep1() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.candidate;
        final resumes = profile?.resumes ?? [];

        if (resumes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No CV found in your profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please upload a CV to your profile before applying.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to profile edit or close and tell user
                      Navigator.pop(context);
                    },
                    child: const Text('Go to Profile'),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select CV',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose the resume you'd like to use for this application.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ...resumes.asMap().entries.map((entry) {
                final index = entry.key;
                final cvUrl = entry.value;
                final isSelected = _selectedCvIndex == index;

                // Trích xuất tên file từ URL
                String fileName = 'Resume_${index + 1}.pdf';
                try {
                  final uri = Uri.parse(cvUrl);
                  if (uri.pathSegments.isNotEmpty) {
                    fileName = uri.pathSegments.last;
                  }
                } catch (_) {}

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCvIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Ready to apply',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────
  // STEP 2: Final Review
  // ─────────────────────────────
  Widget _buildStep2() {
    final profile = context.read<ProfileProvider>().candidate;
    final resumes = profile?.resumes ?? [];
    final selectedCvUrl = resumes.isNotEmpty ? resumes[_selectedCvIndex] : '';

    String fileName = 'Selected_Resume.pdf';
    try {
      final uri = Uri.parse(selectedCvUrl);
      if (uri.pathSegments.isNotEmpty) {
        fileName = uri.pathSegments.last;
      }
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(int.parse(widget.job.logoColor)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      widget.job.logoText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.job.company} • ${widget.job.location}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cover Letter
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cover Letter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Optional',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _coverLetterController,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText:
                    "Introduce yourself to the hiring manager. Highlight your relevant skills and why you're a great fit for this role...",
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                  height: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
                counterText: "", // Hide default counter
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: ValueListenableBuilder(
                valueListenable: _coverLetterController,
                builder: (context, value, child) {
                  return Text(
                    '${value.text.length}/500',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Review Selected CV
          const Text(
            'Review Selected CV',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFE53935),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Attached to application',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Change CV
          if (!_isSubmitting)
            GestureDetector(
              onTap: _goBack,
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Change CV',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_rounded, size: 20),
              label: Text(
                _isSubmitting ? 'Submitting...' : 'Submit Application',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8630A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: const Color(
                  0xFFE8630A,
                ).withValues(alpha: 0.6),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: RichText(
              text: const TextSpan(
                text: 'By submitting, you agree to our ',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────
  // STEP 3: Success Screen
  // ─────────────────────────────
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.06),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8630A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 20,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              const Text(
                'Application Sent\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Your application for '),
                    TextSpan(
                      text: widget.job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: ' at '),
                    TextSpan(
                      text: widget.job.company,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: ' has been received.'),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // View Application Status → navigate to ApplicationsPage
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                      (route) => false,
                      arguments: UserRole.candidate,
                    );
                    // Open application history tab by navigating to main with correct index if possible
                    // For now, just go to main
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: const Text(
                    'View Application Status',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8630A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main',
                    (route) => false,
                    arguments: UserRole.candidate,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Nút Next cố định ở dưới Step 1 ──
  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _goToStep2,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Next'),
          ),
        ),
      ),
    );
  }
}
