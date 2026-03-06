import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/admin_stats_model.dart';

class GrowthChart extends StatelessWidget {
  final List<GrowthDataPoint> data;

  const GrowthChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Users', AppColors.primary),
              const SizedBox(width: 24),
              _buildLegendItem('Jobs', const Color(0xFF9B59B6)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Chart
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: Size.infinite,
              painter: _GrowthChartPainter(data),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<GrowthDataPoint> data;

  _GrowthChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final usersPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final jobsPaint = Paint()
      ..color = const Color(0xFF9B59B6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Calculate max value for scaling
    double maxUsers = data.map((d) => d.users).reduce((a, b) => a > b ? a : b);
    double maxJobs = data.map((d) => d.jobs).reduce((a, b) => a > b ? a : b);
    double maxValue = maxUsers > maxJobs ? maxUsers : maxJobs;

    // Calculate step
    final stepX = (size.width - 40) / (data.length - 1);

    // Draw users line
    final usersPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = 40 + i * stepX;
      final y = size.height - (data[i].users / maxValue * size.height);
      
      if (i == 0) {
        usersPath.moveTo(x, y);
      } else {
        usersPath.lineTo(x, y);
      }

      // Draw point
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = AppColors.primary,
      );
    }
    canvas.drawPath(usersPath, usersPaint);

    // Draw jobs line
    final jobsPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = 40 + i * stepX;
      final y = size.height - (data[i].jobs / maxValue * size.height);
      
      if (i == 0) {
        jobsPath.moveTo(x, y);
      } else {
        jobsPath.lineTo(x, y);
      }

      // Draw point
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = const Color(0xFF9B59B6),
      );
    }
    canvas.drawPath(jobsPath, jobsPaint);

    // Draw labels
    for (int i = 0; i < data.length; i++) {
      final x = 40 + i * stepX;
      
      textPainter.text = TextSpan(
        text: data[i].label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
