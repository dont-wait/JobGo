import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:provider/provider.dart';

class CandidateInterviewDetailPage extends StatelessWidget {
  final InterviewScheduleModel schedule;

  const CandidateInterviewDetailPage({super.key, required this.schedule});

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
      case 'accepted': return 'Đã xác nhận tham gia';
      case 'rejected': return 'Đã từ chối';
      case 'reschedule': return 'Yêu cầu đổi lịch';
      default: return 'Chờ phản hồi';
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

            const SizedBox(height: 16),

            // Info card
            _buildInfoCard(
              title: 'Thông tin vị trí',
              children: [
                _buildRow(
                  icon: Icons.work_outline,
                  iconColor: AppColors.primary,
                  label: 'Vị trí',
                  value: schedule.jobTitle,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Thông tin lịch hẹn',
              children: [
                _buildRow(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.primary,
                  label: 'Ngày giờ',
                  value:
                      '${schedule.date.day}/${schedule.date.month}/${schedule.date.year} • '
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

            // Buttons phản hồi nếu pending
            if (schedule.status == 'pending') ...[
              const SizedBox(height: 24),
              const Text(
                'Phản hồi lịch hẹn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _respond(context, 'rejected'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text(
                        'Từ chối',
                        style: TextStyle(color: Colors.red),
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
                      label: const Text(
                        'Đổi lịch',
                        style: TextStyle(color: Colors.orange),
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
                      label: const Text('Đồng ý'),
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
    );
  }

  Future<void> _respond(BuildContext context, String status) async {
    try {
      await context.read<InterviewProvider>().updateScheduleStatus(
        scheduleId: schedule.id,
        status: status,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'accepted'
                  ? 'Đã xác nhận lịch phỏng vấn!'
                  : status == 'rejected'
                      ? 'Đã từ chối lịch phỏng vấn'
                      : 'Đã yêu cầu đổi lịch',
            ),
            backgroundColor:
                status == 'accepted' ? Colors.green : Colors.orange,
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

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
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
}