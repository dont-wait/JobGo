import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../data/mockdata/mock_interview.dart';


class InterviewCard extends StatelessWidget {
  final MockInterviewSchedule schedule;

  const InterviewCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề loại phỏng vấn
            Text(
              schedule.interviewType,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Thời gian
            Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  "${schedule.formattedDate} • ${schedule.formattedTime}",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Địa điểm
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    schedule.location,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Người liên hệ
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  "Liên hệ: ${schedule.contactPerson}",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),

            // Ghi chú
            if (schedule.note != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.note_alt, color: Colors.orangeAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ghi chú: ${schedule.note}",
                      style: const TextStyle(color: AppColors.textSecondary),
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
}