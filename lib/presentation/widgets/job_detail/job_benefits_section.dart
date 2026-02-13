import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

/// Section "Benefits" — lưới hiển thị phúc lợi công việc
class JobBenefitsSection extends StatelessWidget {
  final List<String> benefits;

  const JobBenefitsSection({
    super.key,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: benefits.map((b) => _BenefitChip(label: b)).toList(),
        ),
      ],
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final String label;

  const _BenefitChip({required this.label});

  /// Tự động chọn icon phù hợp dựa trên keyword trong tên benefit.
  /// Ví dụ: 'Health & Dental' → icon bệnh viện, 'Remote Work' → icon nhà,
  /// 'Stock Options' → icon trending up.
  /// Nếu không match keyword nào → fallback icon quà tặng.
  IconData get _icon {
    final lower = label.toLowerCase();
    if (lower.contains('health') || lower.contains('dental')) {
      return Icons.local_hospital_rounded;
    }
    if (lower.contains('remote')) return Icons.home_work_rounded;
    if (lower.contains('401k') || lower.contains('matching')) {
      return Icons.savings_rounded;
    }
    if (lower.contains('gym')) return Icons.fitness_center_rounded;
    if (lower.contains('stock')) return Icons.trending_up_rounded;
    if (lower.contains('learning') || lower.contains('budget')) {
      return Icons.school_rounded;
    }
    if (lower.contains('pto') || lower.contains('vacation')) {
      return Icons.beach_access_rounded;
    }
    if (lower.contains('home office') || lower.contains('stipend')) {
      return Icons.desktop_mac_rounded;
    }
    if (lower.contains('bonus')) return Icons.emoji_events_rounded;
    if (lower.contains('team') || lower.contains('event')) {
      return Icons.groups_rounded;
    }
    return Icons.card_giftcard_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
