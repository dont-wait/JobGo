import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class ViewsStatisticsChart extends StatelessWidget {
  final List<double> weeklyData;

  const ViewsStatisticsChart({
    super.key,
    this.weeklyData = const [250, 650, 400, 500, 350, 200, 800],
  });

  @override
  Widget build(BuildContext context) {
    double maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
    double minValue = weeklyData.reduce((a, b) => a < b ? a : b);
    double range = maxValue - minValue;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Views Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Total reach this week',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Views',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1,240',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '0.44% ↑ WOW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: _buildLineChart(weeklyData, maxValue, minValue, range),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    List<double> data,
    double maxValue,
    double minValue,
    double range,
  ) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    
    return Stack(
      children: [
        // Line chart with area fill
        Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: CustomPaint(
            painter: LineChartPainter(
              data: data,
              maxValue: maxValue,
              minValue: minValue,
              range: range,
            ),
            child: Container(),
          ),
        ),
        // Day labels
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                days.length,
                (index) => Text(
                  days[index],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double minValue;
  final double range;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (data.isEmpty) return;

    final points = <Offset>[];
    final width = size.width;
    final height = size.height;

    // Calculate points
    for (int i = 0; i < data.length; i++) {
      final x = (width / (data.length - 1)) * i;
      final normalizedValue = (data[i] - minValue) / (range > 0 ? range : 1);
      final y = height - (normalizedValue * height * 0.85);
      points.add(Offset(x, y));
    }

    // Draw filled area under curve with gradient
    if (points.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(points[0].dx, points[0].dy);

      // Draw smooth curve using Catmull-Rom spline
      _drawCatmullRomSpline(fillPath, points, false);

      // Close the path to create fill area
      fillPath.lineTo(points.last.dx, height);
      fillPath.lineTo(points.first.dx, height);
      fillPath.close();

      // Draw gradient fill
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4DA3E0).withOpacity(0.25),
          const Color(0xFF4DA3E0).withOpacity(0.05),
          const Color(0xFF4DA3E0).withOpacity(0.02),
        ],
        stops: const [0.0, 0.6, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, width, height),
        );

      canvas.drawPath(fillPath, paint);
    }

    // Draw smooth line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      _drawCatmullRomSpline(path, points, false);

      canvas.drawPath(path, linePaint);
    }
  }

  void _drawCatmullRomSpline(Path path, List<Offset> points, bool closed) {
    if (points.length < 2) return;

    final n = points.length;

    for (int i = 0; i < n - 1; i++) {
      // Get four points for Catmull-Rom calculation
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < n ? points[i + 2] : points[i + 1];

      // Draw quadratic bezier curves with multiple segments
      const segments = 20;
      for (int j = 0; j < segments; j++) {
        final t1 = j / segments;
        final t2 = (j + 1) / segments;

        final point1 = _catmullRom(p0, p1, p2, p3, t1);
        final point2 = _catmullRom(p0, p1, p2, p3, t2);

        path.lineTo(point2.dx, point2.dy);
      }
    }
  }

  Offset _catmullRom(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;

    // Catmull-Rom basis functions
    final a0 = -0.5 * t3 + t2 - 0.5 * t;
    final a1 = 1.5 * t3 - 2.5 * t2 + 1.0;
    final a2 = -1.5 * t3 + 2.0 * t2 + 0.5 * t;
    final a3 = 0.5 * t3 - 0.5 * t2;

    final x = a0 * p0.dx + a1 * p1.dx + a2 * p2.dx + a3 * p3.dx;
    final y = a0 * p0.dy + a1 * p1.dy + a2 * p2.dy + a3 * p3.dy;

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

