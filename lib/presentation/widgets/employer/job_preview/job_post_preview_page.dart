import 'package:flutter/material.dart';

import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/employer_job_model.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_benefits_grid.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_bottom_actions.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_company_header.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_salary_tags.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_section.dart';

class JobPostPreviewPage extends StatefulWidget {
  final EmployerJobModel job;
  final bool isEditing;
  final Future<bool> Function(bool publish) onSubmit;

  const JobPostPreviewPage({
    super.key,
    required this.job,
    required this.isEditing,
    required this.onSubmit,
  });

  @override
  State<JobPostPreviewPage> createState() => _JobPostPreviewPageState();
}

class _JobPostPreviewPageState extends State<JobPostPreviewPage> {
  bool _isSubmitting = false;

  String get _primaryActionLabel {
    if (widget.isEditing) {
      return widget.job.isDraft ? 'Publish Job' : 'Update Job';
    }
    return 'Confirm & Post';
  }

  Future<void> _submit(bool publish) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await widget.onSubmit(publish);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu tin tuyển dụng.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Review Job Changes' : 'Preview Job Post',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PreviewCompanyHeader(job: widget.job),
            const SizedBox(height: 20),
            PreviewSalaryTags(job: widget.job),
            const SizedBox(height: 24),
            PreviewSection(
              title: 'Job Description',
              icon: Icons.description_outlined,
              content: Text(
                widget.job.description.isEmpty
                    ? 'No description provided yet.'
                    : widget.job.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            PreviewSection(
              title: 'Requirements',
              icon: Icons.check_circle_outline,
              content: widget.job.requirementBullets.isEmpty
                  ? const Text(
                      'No requirements listed yet.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.job.requirementBullets
                          .map((item) => _BulletPoint(text: item))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 24),
            PreviewBenefitsGrid(benefits: widget.job.cleanedBenefits),
            const SizedBox(height: 40),
            PreviewBottomActions(
              onSaveDraft: () => _submit(false),
              onConfirm: () => _submit(true),
              onBackToEdit: _isSubmitting
                  ? () {}
                  : () => Navigator.pop(context),
              isBusy: _isSubmitting,
              saveDraftLabel: 'Save Draft',
              confirmLabel: _primaryActionLabel,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, color: AppColors.primary),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
