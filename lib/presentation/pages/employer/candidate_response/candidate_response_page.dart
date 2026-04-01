// import 'package:flutter/material.dart';
// import '../../../widgets/employer/candidate_response/candidate_respone_card.dart';
// import '../../../../core/configs/theme/app_colors.dart';
// import '../../../../core/enums/user_role.dart';
// import '../../../widgets/common/profile_avatar.dart';

// class CandidateResponsesPage extends StatelessWidget {
//   const CandidateResponsesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final responses = [
//       CandidateResponseCard(
//         candidateName: "Sarah Jenkins",
//         message: "Tôi xác nhận sẽ tham gia phỏng vấn vào ngày 7/3.",
//         responseDate: DateTime(2026, 3, 2, 14, 30),
//         accepted: true,
//       ),
//       CandidateResponseCard(
//         candidateName: "Michael Brown",
//         message: "Xin lỗi, tôi không thể tham gia vào lịch hẹn này.",
//         responseDate: DateTime(2026, 3, 2, 15, 10),
//         accepted: false,
//       ),
//       CandidateResponseCard(
//         candidateName: "Emily Davis",
//         message: "Có thể đổi lịch sang ngày khác không?",
//         responseDate: DateTime(2026, 3, 2, 16, 45),
//         accepted: false,
//       ),
//     ];

//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//       appBar: AppBar(
//         title: const Text("Thông báo phản hồi"),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.white,
//         automaticallyImplyLeading: false,
//         actions: const [
//           ProfileAvatar(role: UserRole.employer),
//         ],
//       ),
//       body: ListView(
//         children: responses.cast<Widget>(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

class CandidateResponsesPage extends StatefulWidget {
  const CandidateResponsesPage({super.key});

  @override
  State<CandidateResponsesPage> createState() => _CandidateResponsesPageState();
}

class _CandidateResponsesPageState extends State<CandidateResponsesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<InterviewProvider>().loadSchedules()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Thông báo phản hồi"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        actions: const [
          ProfileAvatar(role: UserRole.employer),
        ],
      ),
      body: Consumer<InterviewProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Chỉ hiện những lịch đã có phản hồi (không phải pending)
          final responded = provider.schedules
              .where((s) => s.status != 'pending')
              .toList();

          if (responded.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 60, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có phản hồi nào',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: responded.length,
            itemBuilder: (context, index) {
              final schedule = responded[index];
              return _ResponseCard(schedule: schedule);
            },
          );
        },
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  final InterviewScheduleModel schedule;

  const _ResponseCard({required this.schedule});

  Color get _statusColor {
    switch (schedule.status) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'reschedule': return Colors.orange;
      default: return Colors.grey;
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

  String get _statusText {
    switch (schedule.status) {
      case 'accepted': return 'Đã xác nhận tham gia';
      case 'rejected': return 'Đã từ chối';
      case 'reschedule': return 'Yêu cầu đổi lịch';
      default: return 'Chờ phản hồi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _statusColor.withOpacity(0.1),
          child: Icon(_statusIcon, color: _statusColor),
        ),
        title: Text(
          schedule.candidateName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              schedule.jobTitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            const SizedBox(height: 6),
            Text(
              "${schedule.date.day}/${schedule.date.month}/${schedule.date.year} "
              "${schedule.date.hour}:${schedule.date.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}