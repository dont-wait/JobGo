import 'package:flutter/material.dart';
import 'package:jobgo/presentation/widgets/employer/candidate_respone/candidate_respone_card.dart';
import '../../../../core/configs/theme/app_colors.dart';


class CandidateResponsesPage extends StatelessWidget {
  const CandidateResponsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responses = [
      CandidateResponseCard(
        candidateName: "Sarah Jenkins",
        message: "Tôi xác nhận sẽ tham gia phỏng vấn vào ngày 7/3.",
        responseDate: DateTime(2026, 3, 2, 14, 30),
        accepted: true,
      ),
      CandidateResponseCard(
        candidateName: "Michael Brown",
        message: "Xin lỗi, tôi không thể tham gia vào lịch hẹn này.",
        responseDate: DateTime(2026, 3, 2, 15, 10),
        accepted: false,
      ),
      CandidateResponseCard(
        candidateName: "Emily Davis",
        message: "Có thể đổi lịch sang ngày khác không?",
        responseDate: DateTime(2026, 3, 2, 16, 45),
        accepted: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Thông báo phản hồi"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        children: responses,
      ),
    );
  }
}