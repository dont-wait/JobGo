import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../data/mockdata/mock_interview.dart';
import '../../../widgets/employer/interview_schedule/interview_card.dart';

class InterviewSchedulePage extends StatelessWidget {
  const InterviewSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Lịch hẹn phỏng vấn"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView.builder(
        itemCount: mockInterviewSchedules.length,
        itemBuilder: (context, index) {
          final schedule = mockInterviewSchedules[index];
          return InterviewCard(schedule: schedule);
        },
      ),
    );
  }
}