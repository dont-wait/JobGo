import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_company_header.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_salary_tags.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_section.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_benefits_grid.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/preview_bottom_actions.dart';

class JobPostPreviewPage extends StatelessWidget {
  const JobPostPreviewPage({super.key});

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
          'Preview Job Post',
          style: TextStyle(
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
            onPressed: () {}, // TODO: Preview mode
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PreviewCompanyHeader(),
            const SizedBox(height: 20),
            const PreviewSalaryTags(),
            const SizedBox(height: 24),

            PreviewSection(
              title: 'Job Description',
              icon: Icons.description_outlined,
              content: const Text(
                'We are looking for a highly skilled Senior Flutter Developer to lead our mobile application development efforts...',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            PreviewSection(
              title: 'Requirements',
              icon: Icons.check_circle_outline,
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BulletPoint(
                    text:
                        '5+ years of experience in mobile development with 3+ years specifically in Flutter/Dart.',
                  ),
                  BulletPoint(
                    text:
                        'Strong knowledge of state management solutions like Riverpod or Bloc.',
                  ),
                  BulletPoint(
                    text:
                        'Experience with CI/CD pipelines and automated testing for mobile.',
                  ),
                  BulletPoint(
                    text:
                        'Published at least 3 high-quality apps on App Store and Play Store.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const PreviewBenefitsGrid(),
            const SizedBox(height: 40),

            const PreviewBottomActions(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

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
