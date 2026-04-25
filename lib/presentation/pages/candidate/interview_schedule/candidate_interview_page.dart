import 'package:flutter/material.dart';
import 'package:jobgo/presentation/pages/candidate/interview_schedule/candidate_interview_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';

class CandidateInterviewPage extends StatefulWidget {
  const CandidateInterviewPage({super.key});

  @override
  State<CandidateInterviewPage> createState() => _CandidateInterviewPageState();
}

class _CandidateInterviewPageState extends State<CandidateInterviewPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<InterviewProvider>().loadCandidateSchedules(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(loc.interviewScheduleTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<InterviewProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.candidateSchedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy,
                    size: 60,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.noInterviewsMessage,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: provider.candidateSchedules.length,
            itemBuilder: (context, index) {
              final schedule = provider.candidateSchedules[index];
              return _CandidateInterviewCard(schedule: schedule, loc: loc);
            },
          );
        },
      ),
    );
  }
}

class _CandidateInterviewCard extends StatelessWidget {
  final InterviewScheduleModel schedule;
  final AppLocalizations loc;

  const _CandidateInterviewCard({required this.schedule, required this.loc});

  Color get _statusColor {
    switch (schedule.status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'reschedule':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get _statusText {
    switch (schedule.status) {
      case 'accepted':
        return loc.statusAccepted;
      case 'rejected':
        return loc.statusRejected;
      case 'reschedule':
        return loc.statusReschedule;
      default:
        return loc.statusPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(  
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CandidateInterviewDetailPage(schedule: schedule),
        ),
      );
    },
    child:  Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: job title + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule.jobTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date
            _buildRow(
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.primary,
              text:
                  "${schedule.date.day}/${schedule.date.month}/${schedule.date.year} "
                  "${schedule.date.hour}:${schedule.date.minute.toString().padLeft(2, '0')}",
            ),
            const SizedBox(height: 8),

            // Type
            _buildRow(
              icon: Icons.videocam_outlined,
              iconColor: Colors.blueAccent,
              text: schedule.type,
            ),
            const SizedBox(height: 8),

            // Location
            _buildRow(
              icon: Icons.location_on_rounded,
              iconColor: Colors.redAccent,
              text: schedule.location.isNotEmpty
                  ? schedule.location
                  : loc.noLocationText,
            ),
            const SizedBox(height: 8),

            // Contact
            _buildRow(
              icon: Icons.person_outline,
              iconColor: Colors.blueAccent,
              text:
                  '${loc.contactLabel} ${schedule.contactPerson.isNotEmpty ? schedule.contactPerson : loc.notAvailable}',
            ),

            if (schedule.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildRow(
                icon: Icons.note_alt_outlined,
                iconColor: Colors.orange,
                text: schedule.note,
              ),
            ],

            // Buttons chỉ hiện khi status = pending
            if (schedule.status == 'pending') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _respond(context, 'rejected'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: Text(
                        loc.declineButton,
                        style: const TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _respond(context, 'reschedule'),
                      icon: const Icon(Icons.schedule, color: Colors.orange),
                      label: Text(
                        loc.rescheduleButton,
                        style: const TextStyle(color: Colors.orange),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _respond(context, 'accepted'),
                      icon: const Icon(Icons.check),
                      label: Text(loc.acceptButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    )   );
  }

  Future<void> _respond(BuildContext context, String status) async {
    try {
      await context.read<InterviewProvider>().updateScheduleStatus(
        scheduleId: schedule.id,
        status: status,
      );

      if (context.mounted) {
        final msg = status == 'accepted'
            ? loc.scheduleConfirmedMessage
            : status == 'rejected'
            ? loc.scheduleDeclinedMessage
            : loc.rescheduleRequestedMessage;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: status == 'accepted'
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${loc.errorMessage}$e')));
      }
    }
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
