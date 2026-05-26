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
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        title: Text(
          loc.interviewScheduleTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                    Icons.event_busy_rounded,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.noInterviewsMessage,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'reschedule':
        return AppColors.warning;
      default:
        return AppColors.textHint;
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
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _statusColor.withOpacity(0.5)),
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

              const SizedBox(height: 16),

              // Date
              _buildRow(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                text:
                    "${schedule.date.day}/${schedule.date.month}/${schedule.date.year} • "
                    "${schedule.date.hour}:${schedule.date.minute.toString().padLeft(2, '0')}",
              ),
              const SizedBox(height: 10),

              // Type
              _buildRow(
                icon: Icons.videocam_outlined,
                iconColor: Colors.blueAccent,
                text: schedule.type,
              ),
              const SizedBox(height: 10),

              // Location
              _buildRow(
                icon: Icons.location_on_rounded,
                iconColor: Colors.redAccent,
                text: schedule.location.isNotEmpty
                    ? schedule.location
                    : loc.noLocationText,
              ),
              const SizedBox(height: 10),

              // Contact
              _buildRow(
                icon: Icons.person_outline,
                iconColor: Colors.teal,
                text:
                    '${loc.contactLabel} ${schedule.contactPerson.isNotEmpty ? schedule.contactPerson : loc.notAvailable}',
              ),

              if (schedule.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildRow(
                  icon: Icons.note_alt_outlined,
                  iconColor: AppColors.warning,
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
                        icon: const Icon(Icons.close, color: AppColors.error, size: 16),
                        label: Text(
                          loc.declineButton,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _respond(context, 'reschedule'),
                        icon: const Icon(Icons.schedule, color: AppColors.warning, size: 16),
                        label: Text(
                          loc.rescheduleButton,
                          style: const TextStyle(color: AppColors.warning, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.warning),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _respond(context, 'accepted'),
                        icon: const Icon(Icons.check, size: 16),
                        label: Text(
                          loc.acceptButton,
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _respond(BuildContext context, String status) async {
    if (status == 'reschedule') {
      await _showRescheduleDialog(context);
      return;
    }

    try {
      await context.read<InterviewProvider>().updateScheduleStatus(
        scheduleId: schedule.id,
        status: status,
      );

      if (context.mounted) {
        final msg = status == 'accepted'
            ? loc.scheduleConfirmedMessage
            : loc.scheduleDeclinedMessage;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: status == 'accepted' ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.errorMessage}$e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showRescheduleDialog(BuildContext context) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Yêu cầu đổi lịch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn ngày và giờ mới bạn muốn phỏng vấn:',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                ),
                title: Text(
                  selectedDate == null
                      ? 'Chọn ngày'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selectedDate == null ? AppColors.textHint : AppColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                ),
                title: Text(
                  selectedTime == null
                      ? 'Chọn giờ'
                      : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selectedTime == null ? AppColors.textHint : AppColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setDialogState(() => selectedTime = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Hủy',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: selectedDate == null || selectedTime == null
                  ? null
                  : () async {
                      final requestedDate = DateTime(
                        selectedDate!.year, selectedDate!.month, selectedDate!.day,
                        selectedTime!.hour, selectedTime!.minute,
                      );
                      Navigator.pop(ctx);
                      try {
                        await context.read<InterviewProvider>().requestReschedule(
                          scheduleId: schedule.id,
                          requestedDate: requestedDate,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã gửi yêu cầu đổi lịch!'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Gửi yêu cầu'),
            ),
          ],
        ),
      ),
    );
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
