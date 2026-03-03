import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';

class CandidateResponseCard extends StatelessWidget {
  final String candidateName;
  final String message;
  final DateTime responseDate;
  final bool accepted; // true = đồng ý tham gia, false = từ chối

  const CandidateResponseCard({
    super.key,
    required this.candidateName,
    required this.message,
    required this.responseDate,
    required this.accepted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: accepted ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accepted ? AppColors.success : AppColors.error,
          width: 1.2,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accepted ? AppColors.success : AppColors.error,
          child: Icon(
            accepted ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          candidateName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              "${responseDate.day}/${responseDate.month}/${responseDate.year} "
              "${responseDate.hour}:${responseDate.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}