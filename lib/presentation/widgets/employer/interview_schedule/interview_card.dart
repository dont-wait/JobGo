
import 'package:flutter/material.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import '../../../../core/configs/theme/app_colors.dart';

class InterviewCard extends StatelessWidget {
  final InterviewScheduleModel schedule;
  final VoidCallback? onTap; // thêm cái này để click
  final VoidCallback? onDelete; // nếu muốn có nút xóa sau này

  const InterviewCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // xử lý click ở đây
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.type,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        print("DELETE CLICKED");
                        onDelete?.call();
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Candidate + Job
              Text(
                "${schedule.candidateName} • ${schedule.jobTitle}",
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),

              const SizedBox(height: 14),

              // 🗓 Date + Time
              _buildRow(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                text:
                    "${schedule.date.day}/${schedule.date.month}/${schedule.date.year} • "
                    "${schedule.date.hour}:${schedule.date.minute.toString().padLeft(2, '0')}",
              ),

              const SizedBox(height: 8),

              //  Location
              _buildRow(
                icon: Icons.location_on_rounded,
                iconColor: Colors.redAccent,
                text: schedule.location.isNotEmpty
                    ? schedule.location
                    : 'No location',
              ),

              const SizedBox(height: 8),

              // Contact
              _buildRow(
                icon: Icons.person_outline,
                iconColor: Colors.blueAccent,
                text:
                    "Liên hệ: ${schedule.contactPerson.isNotEmpty ? schedule.contactPerson : 'N/A'}",
              ),

              // 📝 Note
              if (schedule.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildRow(
                  icon: Icons.note_alt_outlined,
                  iconColor: Colors.orange,
                  text: schedule.note,
                ),
              ],
            ],
          ),
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