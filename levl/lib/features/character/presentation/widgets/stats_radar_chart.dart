import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Data for one stat axis on the radar chart.
class StatAxis {
  final String label;
  final IconData icon;
  final Color color;
  final int value; // 0-100

  const StatAxis({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
  });
}

/// Hexagonal radar chart for 6 character stats.
/// Pure CustomPainter — no external packages.
class StatsRadarChart extends StatelessWidget {
  final List<StatAxis> stats;
  final double size;

  const StatsRadarChart({
    super.key,
    required this.stats,
    this.size = 260,
  }) : assert(stats.length == 6, 'Radar chart requires exactly 6 stats');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radar chart
          CustomPaint(
            size: Size(size, size),
            painter: _RadarPainter(stats: stats),
          ),
          // Labels around the chart
          ..._buildLabels(),
        ],
      ),
    );
  }

  List<Widget> _buildLabels() {
    final radius = size / 2;
    final labelRadius = radius * 0.92;
    const angleOffset = -pi / 2; // start from top

    return List.generate(6, (i) {
      final angle = angleOffset + (2 * pi * i / 6);
      final dx = labelRadius * cos(angle);
      final dy = labelRadius * sin(angle);

      return Positioned(
        left: radius + dx - 28,
        top: radius + dy - 22,
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(stats[i].icon, size: 16, color: stats[i].color),
              const SizedBox(height: 2),
              Text(
                '${stats[i].value}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: stats[i].color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _RadarPainter extends CustomPainter {
  final List<StatAxis> stats;

  _RadarPainter({required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.7; // leave room for labels
    const angleOffset = -pi / 2;

    // Draw grid rings (20, 40, 60, 80, 100)
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var ring = 1; ring <= 5; ring++) {
      final ringRadius = maxRadius * ring / 5;
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = angleOffset + (2 * pi * i / 6);
        final point = Offset(
          center.dx + ringRadius * cos(angle),
          center.dy + ringRadius * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines
    final axisPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    for (var i = 0; i < 6; i++) {
      final angle = angleOffset + (2 * pi * i / 6);
      final end = Offset(
        center.dx + maxRadius * cos(angle),
        center.dy + maxRadius * sin(angle),
      );
      canvas.drawLine(center, end, axisPaint);
    }

    // Draw stat polygon (filled)
    final dataPath = Path();
    final dataPoints = <Offset>[];

    for (var i = 0; i < 6; i++) {
      final angle = angleOffset + (2 * pi * i / 6);
      final value = stats[i].value.clamp(0, 100) / 100;
      final point = Offset(
        center.dx + maxRadius * value * cos(angle),
        center.dy + maxRadius * value * sin(angle),
      );
      dataPoints.add(point);
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    // Fill
    final fillPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(dataPath, strokePaint);

    // Draw data points with sphere colors
    for (var i = 0; i < 6; i++) {
      final dotPaint = Paint()
        ..color = stats[i].color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dataPoints[i], 4, dotPaint);

      final dotBorderPaint = Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(dataPoints[i], 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.stats != stats;
  }
}
