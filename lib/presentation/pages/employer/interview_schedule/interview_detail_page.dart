import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import 'package:jobgo/presentation/pages/employer/interview_schedule/edit_interview_page.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:provider/provider.dart';

class InterviewDetailPage extends StatelessWidget {
  final InterviewScheduleModel schedule;

  const InterviewDetailPage({super.key, required this.schedule});

  Color get _statusColor {
    switch (schedule.status) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'reschedule': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String get _statusText {
    switch (schedule.status) {
      case 'accepted': return 'Ứng viên đã xác nhận';
      case 'rejected': return 'Ứng viên đã từ chối';
      case 'reschedule': return 'Ứng viên yêu cầu đổi lịch';
      default: return 'Chờ phản hồi từ ứng viên';
    }
  }

  IconData get _statusIcon {
    switch (schedule.status) {
      case 'accepted': return Icons.check_circle_outline;
      case 'rejected': return Icons.cancel_outlined;
      case 'reschedule': return Icons.schedule;
      default: return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Chi tiết lịch hẹn'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditInterviewPage(schedule: schedule),
                ),
              );
              if (context.mounted) {
                context.read<InterviewProvider>().loadSchedules();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon, color: _statusColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin ứng viên'),
                  _buildRow(
                    icon: Icons.person_outline,
                    iconColor: AppColors.primary,
                    label: 'Ứng viên',
                    value: schedule.candidateName,
                  ),
                  _buildRow(
                    icon: Icons.work_outline,
                    iconColor: AppColors.primary,
                    label: 'Vị trí',
                    value: schedule.jobTitle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // ✅ Thêm sau Container thông tin lịch hẹn
            if (schedule.status == 'reschedule' && schedule.requestedDate != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Ứng viên yêu cầu đổi lịch',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ngày/giờ đề xuất: '
                      '${schedule.requestedDate!.day}/${schedule.requestedDate!.month}/${schedule.requestedDate!.year} • '
                      '${schedule.requestedDate!.hour}:${schedule.requestedDate!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _rejectReschedule(context),
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmReschedule(context),
                            icon: const Icon(Icons.check),
                            label: const Text('Xác nhận'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin lịch hẹn'),
                  _buildRow(
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.primary,
                    label: 'Ngày giờ',
                    value: '${schedule.date.day}/${schedule.date.month}/${schedule.date.year} • '
                        '${schedule.date.hour}:${schedule.date.minute.toString().padLeft(2, '0')}',
                  ),
                  _buildRow(
                    icon: Icons.videocam_outlined,
                    iconColor: Colors.blueAccent,
                    label: 'Hình thức',
                    value: schedule.type,
                  ),
                  _buildRow(
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.redAccent,
                    label: 'Địa điểm',
                    value: schedule.location.isNotEmpty
                        ? schedule.location
                        : 'Chưa có',
                  ),
                  _buildRow(
                    icon: Icons.person_outline,
                    iconColor: Colors.blueAccent,
                    label: 'Người liên hệ',
                    value: schedule.contactPerson.isNotEmpty
                        ? schedule.contactPerson
                        : 'N/A',
                  ),
                  if (schedule.note.isNotEmpty)
                    _buildRow(
                      icon: Icons.note_alt_outlined,
                      iconColor: Colors.orange,
                      label: 'Ghi chú',
                      value: schedule.note,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _confirmReschedule(BuildContext context) async {
    try {
      await context.read<InterviewProvider>().confirmReschedule(schedule.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xác nhận đổi lịch!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _rejectReschedule(BuildContext context) async {
    try {
      await context.read<InterviewProvider>().rejectReschedule(schedule.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã từ chối yêu cầu đổi lịch'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
  
}