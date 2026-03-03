import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_applications.dart';

class ApplicationDetailPage extends StatelessWidget {
  final MockApplication application;

  const ApplicationDetailPage({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Application Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Job Info Card ──
            _buildJobCard(),

            const SizedBox(height: 16),

            // ── Application Status ──
            _buildStatusCard(),

            const SizedBox(height: 16),

            // ── Timeline ──
            _buildTimeline(),

            // ── Interview Schedule (only for interview stage) ──
            if (application.status == ApplicationStatus.interview &&
                application.interviewSchedule != null) ...[
              const SizedBox(height: 16),
              _buildInterviewCard(),
            ],

            // ── Cover Letter (if not empty) ──
            if (application.coverLetter.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCoverLetterCard(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Job Info Card ──────────────────────────────────────────
  Widget _buildJobCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Color(int.parse(application.logoColor)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                application.logoText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  application.company,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        application.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Card ────────────────────────────────────────────
  Widget _buildStatusCard() {
    final (Color bg, Color fg) = _statusColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon, color: fg, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Application Status',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  application.statusLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              application.appliedTimeAgo,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Timeline ───────────────────────────────────────────────
  Widget _buildTimeline() {
    final steps = _timelineSteps;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isLast = i == steps.length - 1;
            return _TimelineItem(
              step: step,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  // ── Interview Card ─────────────────────────────────────────
  Widget _buildInterviewCard() {
    final s = application.interviewSchedule!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE7F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_rounded,
                    size: 18, color: Color(0xFF6A1B9A)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Interview Schedule',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),

          // Details
          _interviewRow(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.primary,
            label: 'Date',
            value: s.formattedDate,
          ),
          const SizedBox(height: 12),
          _interviewRow(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.orange,
            label: 'Time',
            value: s.formattedTime,
          ),
          const SizedBox(height: 12),
          _interviewRow(
            icon: _interviewTypeIcon(s.interviewType),
            iconColor: const Color(0xFF6A1B9A),
            label: 'Type',
            value: s.interviewType,
          ),
          const SizedBox(height: 12),
          _interviewRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.error,
            label: 'Location',
            value: s.location,
          ),
          const SizedBox(height: 12),
          _interviewRow(
            icon: Icons.person_rounded,
            iconColor: AppColors.success,
            label: 'Contact',
            value: s.contactPerson,
          ),

          if (s.note != null && s.note!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFFF9A825)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_month_rounded, size: 16),
              label: const Text(
                'Add to Calendar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interviewRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _interviewTypeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('video') || t.contains('call')) return Icons.videocam_rounded;
    if (t.contains('phone')) return Icons.phone_rounded;
    if (t.contains('on-site') || t.contains('office')) return Icons.business_rounded;
    return Icons.meeting_room_rounded;
  }

  // ── Cover Letter Card ──────────────────────────────────────
  Widget _buildCoverLetterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cover Letter',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            application.coverLetter,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  (Color, Color) get _statusColors {
    switch (application.status) {
      case ApplicationStatus.pending:
        return (const Color(0xFFFFF3E0), const Color(0xFFE65100));
      case ApplicationStatus.reviewing:
        return (const Color(0xFFE3F2FD), const Color(0xFF1565C0));
      case ApplicationStatus.interview:
        return (const Color(0xFFEDE7F6), const Color(0xFF6A1B9A));
      case ApplicationStatus.hired:
        return (const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case ApplicationStatus.rejected:
        return (const Color(0xFFFFEBEE), const Color(0xFFC62828));
      case ApplicationStatus.withdrawn:
        return (const Color(0xFFF5F5F5), const Color(0xFF616161));
    }
  }

  IconData get _statusIcon {
    switch (application.status) {
      case ApplicationStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ApplicationStatus.reviewing:
        return Icons.find_in_page_rounded;
      case ApplicationStatus.interview:
        return Icons.event_available_rounded;
      case ApplicationStatus.hired:
        return Icons.check_circle_rounded;
      case ApplicationStatus.rejected:
        return Icons.cancel_rounded;
      case ApplicationStatus.withdrawn:
        return Icons.remove_circle_outline_rounded;
    }
  }

  List<_TimelineStep> get _timelineSteps {
    final allSteps = [
      _TimelineStep(
        label: 'Applied',
        sublabel: application.appliedTimeAgo,
        icon: Icons.send_rounded,
        state: _StepState.done,
      ),
      _TimelineStep(
        label: 'Under Review',
        sublabel: 'HR is reviewing your profile',
        icon: Icons.manage_search_rounded,
        state: _stepStateFor(ApplicationStatus.reviewing),
      ),
      _TimelineStep(
        label: 'Interview',
        sublabel: application.status == ApplicationStatus.interview
            ? application.interviewSchedule != null
                ? application.interviewSchedule!.formattedDate
                : 'Scheduled'
            : 'Pending',
        icon: Icons.event_rounded,
        state: _stepStateFor(ApplicationStatus.interview),
      ),
      _TimelineStep(
        label: 'Decision',
        sublabel: application.status == ApplicationStatus.hired
            ? 'Congratulations! You\'re hired'
            : application.status == ApplicationStatus.rejected
                ? 'Not selected this time'
                : 'Awaiting final decision',
        icon: application.status == ApplicationStatus.hired
            ? Icons.celebration_rounded
            : application.status == ApplicationStatus.rejected
                ? Icons.cancel_rounded
                : Icons.gavel_rounded,
        state: application.status == ApplicationStatus.hired ||
                application.status == ApplicationStatus.rejected
            ? _StepState.done
            : _StepState.upcoming,
      ),
    ];

    // For withdrawn, show only Applied + Withdrawn
    if (application.status == ApplicationStatus.withdrawn) {
      return [
        allSteps[0],
        _TimelineStep(
          label: 'Withdrawn',
          sublabel: 'Application withdrawn by candidate',
          icon: Icons.remove_circle_outline_rounded,
          state: _StepState.done,
        ),
      ];
    }

    return allSteps;
  }

  _StepState _stepStateFor(ApplicationStatus target) {
    final order = [
      ApplicationStatus.pending,
      ApplicationStatus.reviewing,
      ApplicationStatus.interview,
      ApplicationStatus.hired,
    ];
    final currentIdx = order.indexOf(application.status);
    final targetIdx = order.indexOf(target);

    if (application.status == ApplicationStatus.rejected) {
      // Rejected: completed up to reviewing
      if (target == ApplicationStatus.reviewing) return _StepState.done;
      return _StepState.upcoming;
    }

    if (currentIdx == -1 || targetIdx == -1) return _StepState.upcoming;
    if (targetIdx < currentIdx) return _StepState.done;
    if (targetIdx == currentIdx) return _StepState.active;
    return _StepState.upcoming;
  }
}

// ── Timeline enums & widget ────────────────────────────────────
enum _StepState { done, active, upcoming }

class _TimelineStep {
  final String label;
  final String sublabel;
  final IconData icon;
  final _StepState state;

  const _TimelineStep({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.state,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDone = step.state == _StepState.done;
    final isActive = step.state == _StepState.active;

    final Color dotColor = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.border;

    final Color lineColor = isDone ? AppColors.success : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: dot + vertical line ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Dot / icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.success.withValues(alpha: 0.12)
                        : isActive
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.lightBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isActive ? 2 : 1.5,
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : step.icon,
                    size: 16,
                    color: dotColor,
                  ),
                ),
                // Vertical line (except last)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Right: label + sublabel ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDone || isActive
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.sublabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDone
                          ? AppColors.textSecondary
                          : isActive
                              ? AppColors.primary
                              : AppColors.textHint,
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
}
