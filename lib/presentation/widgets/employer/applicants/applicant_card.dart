import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/ai_cv_analysis_model.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/presentation/pages/common/chat_detail_page.dart';
import 'package:jobgo/presentation/widgets/employer/applicants/candidate_profile_page.dart';
import 'dart:math';

class ApplicantCard extends StatelessWidget {
  final JobApplicantModel application;
  final AiCvAnalysisModel? analysis;
  final VoidCallback? onAnalyze;
  final bool isAnalyzing;
  final VoidCallback? onApplicationChanged;

  const ApplicantCard({
    super.key,
    required this.application,
    this.analysis,
    this.onAnalyze,
    this.isAnalyzing = false,
    this.onApplicationChanged,
  });

  String get badgeText => application.statusLabel;

  Color get badgeColor {
    switch (application.status) {
      case ApplicationStatus.interview:
        return const Color(0xFFF59E0B);
      case ApplicationStatus.shortlisted:
        return const Color(0xFF8B5CF6);
      case ApplicationStatus.hired:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.reviewing:
        return const Color(0xFF8B5CF6);
      case ApplicationStatus.withdrawn:
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final candidate = application.candidate;
    final badgeMaxWidth = MediaQuery.sizeOf(context).width * 0.34;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(candidate.avatarUrl, candidate.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: badgeMaxWidth),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badgeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      application.appliedTimeAgo,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CandidateProfilePage(
                          candidate: candidate,
                          application: application,
                          initialAiAnalysis: analysis,
                        ),
                      ),
                    );
                    if (updated == true) {
                      onApplicationChanged?.call();
                    }
                  },
                  child: Text(loc.viewProfile),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final seed = application.candidate.displayName.isEmpty
                        ? 1
                        : application.candidate.displayName.codeUnits.reduce(
                            (a, b) => a + b,
                          );
                    final random = Random(seed);
                    final color = Color.fromARGB(
                      255,
                      80 + random.nextInt(140),
                      80 + random.nextInt(140),
                      80 + random.nextInt(140),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailPage(
                          otherUserId: application.candidate.uId,
                          otherUserName: application.candidate.displayName,
                          avatarColor: color,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message, size: 18),
                  label: Text(loc.message),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, String initials) {
    final imageUrl = avatarUrl?.trim() ?? '';

    if (imageUrl.isNotEmpty) {
      return CircleAvatar(radius: 28, backgroundImage: NetworkImage(imageUrl));
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
