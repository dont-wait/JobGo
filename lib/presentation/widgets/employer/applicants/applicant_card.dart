import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/main.dart';
import 'package:jobgo/presentation/pages/main/app_shell.dart';
import 'package:jobgo/presentation/pages/employer/messages/employer_messages_page.dart';
import 'package:jobgo/presentation/widgets/employer/applicants/candidate_profile_page.dart';

class ApplicantCard extends StatelessWidget {
  final JobApplicantModel application;
  final VoidCallback? onApplicationChanged;

  const ApplicantCard({
    super.key,
    required this.application,
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
    final candidate = application.candidate;

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
                        Text(
                          candidate.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
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
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeColor,
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          application.matchLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
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
                        ),
                      ),
                    );
                    if (updated == true) {
                      onApplicationChanged?.call();
                    }
                  },
                  child: const Text('View Profile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final rootNavigator = navigatorKey.currentState;
                    if (rootNavigator == null) return;

                    rootNavigator.popUntil((route) => route.isFirst);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final shellContext = navigatorKey.currentContext;
                      if (shellContext != null &&
                          AppShell.goToMessages(shellContext)) {
                        return;
                      }

                      rootNavigator.push(
                        MaterialPageRoute(
                          builder: (_) => const EmployerMessagesPage(),
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.message, size: 18),
                  label: const Text('Message'),
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
