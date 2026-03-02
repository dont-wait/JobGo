import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_jobs.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_info_grid.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_description_section.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_requirements_section.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_benefits_section.dart';
import 'package:jobgo/presentation/widgets/candidate/job_detail/job_apply_button.dart';
import 'package:jobgo/presentation/pages/candidate/apply_job/apply_job_route.dart';

/// Trang chi tiết công việc
class JobDetailPage extends StatelessWidget {
  final MockJob job;

  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Job Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              job.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: job.isBookmarked ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () {
              // TODO: Implement bookmark toggle
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: () {
              // TODO: Implement share
            },
          ),
        ],
      ),
      // Layout: Column chứa 2 phần:
      // 1. Expanded(SingleChildScrollView) → nội dung scroll được
      // 2. JobApplyButton → cố định ở dưới, không scroll theo
      // Cách này đảm bảo nút Apply luôn hiển thị bất kể nội dung dài bao nhiêu.
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: Logo + Title + Company + Location ──
                  _buildHeader(),

                  const SizedBox(height: 20),

                  // ── Badge (nếu có) ──
                  // Dùng collection-if + spread (...[]) để chèn nhiều widget
                  // có điều kiện vào Column.children.
                  // Nếu không dùng spread, phải wrap trong Column/Widget khác.
                  if (job.badge != null) ...[
                    _buildBadge(),
                    const SizedBox(height: 16),
                  ],

                  // ── Applicants count (nếu có) ──
                  if (job.applicants != null) ...[
                    _buildApplicantsInfo(),
                    const SizedBox(height: 20),
                  ],

                  // ── Info Grid: Salary / Job Type / Posted ──
                  JobInfoGrid(
                    salary: job.salary,
                    jobType: job.type,
                    postedTime: job.postedTime,
                  ),

                  const SizedBox(height: 24),

                  // ── Tags (nếu có) ──
                  if (job.tags != null && job.tags!.isNotEmpty) ...[
                    _buildTags(),
                    const SizedBox(height: 24),
                  ],

                  // ── About the Role ──
                  if (job.description != null && job.description!.isNotEmpty) ...[
                    JobDescriptionSection(description: job.description!),
                    const SizedBox(height: 24),
                  ],

                  // ── Requirements ──
                  if (job.requirements != null &&
                      job.requirements!.isNotEmpty) ...[
                    JobRequirementsSection(requirements: job.requirements!),
                    const SizedBox(height: 24),
                  ],

                  // ── Benefits ──
                  if (job.benefits != null && job.benefits!.isNotEmpty) ...[
                    JobBenefitsSection(benefits: job.benefits!),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // ── Apply Button cố định ở dưới ──
          JobApplyButton(
            onPressed: () => navigateToApply(context, job),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Center(
          child: CompanyLogo(
            imageUrl: job.logoUrl,
            fallbackText: job.logoText,
            // logoColor lưu dạng String '0xFF1A3A4A' (hex ARGB)
            // để hỗ trợ const constructor → parse thành Color khi render.
            backgroundColor: Color(int.parse(job.logoColor)),
            width: 72,
            height: 72,
            borderRadius: 18,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),

        // Job Title
        Center(
          child: Text(
            job.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),

        // Company Name
        Center(
          child: Text(
            job.company,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Location
        if (job.location.isNotEmpty)
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
                  job.location,
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

  /// Badge hiển thị trạng thái đặc biệt của công việc.
  /// - 'URGENT' → nền đỏ nhạt, chữ đỏ (cảnh báo khẩn cấp)
  /// - Các badge khác (TOP TALENT...) → nền xanh nhạt, chữ xanh primary
  Widget _buildBadge() {
    final isUrgent = job.badge!.toUpperCase() == 'URGENT';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isUrgent
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          job.badge!,
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
          // Xử lý số nhiều tiếng Anh: 1 applicant / 5 applicants
          '${job.applicants} applicant${job.applicants! > 1 ? 's' : ''} so far',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: job.tags!.map((tag) {
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
}
