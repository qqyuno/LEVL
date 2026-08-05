import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class JourneyMap extends StatelessWidget {
  const JourneyMap({super.key, required this.completed});

  final int completed;

  static const _nodes = <_NodeData>[
    _NodeData('База', 'Начать день осознанно', Icons.home_outlined,
        AppColors.sphereDiscipline),
    _NodeData('Фокус', 'Главное действие дня',
        Icons.center_focus_strong_outlined, AppColors.sphereWill),
    _NodeData('Движение', 'Энергия через действие',
        Icons.directions_run_outlined, AppColors.sphereEnergy),
    _NodeData('Связи', 'Выйти к людям', Icons.people_outline,
        AppColors.sphereRelations),
    _NodeData('Восстановление', 'Закрыть день без шума', Icons.bedtime_outlined,
        AppColors.sphereWisdom),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = completed.clamp(0, _nodes.length - 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SizedBox(
        height: 570,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final points = _points(constraints.maxWidth);
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RoutePainter(
                      points: points,
                      completedSegments: completed,
                    ),
                  ),
                ),
                for (var index = 0; index < _nodes.length; index++)
                  Positioned(
                    left: points[index].dx - 35,
                    top: points[index].dy - 35,
                    child: _MapNode(
                      data: _nodes[index],
                      state: index < completed
                          ? _NodeState.completed
                          : index == activeIndex
                              ? _NodeState.active
                              : _NodeState.locked,
                      alignRight: index.isOdd,
                    ),
                  ),
                Positioned(
                  right: 8,
                  bottom: 2,
                  child: _SecretNode(unlocked: completed >= _nodes.length),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Offset> _points(double width) => [
        Offset(width * .25, 54),
        Offset(width * .70, 150),
        Offset(width * .30, 260),
        Offset(width * .72, 370),
        Offset(width * .30, 480),
      ];
}

enum _NodeState { completed, active, locked }

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.data,
    required this.state,
    required this.alignRight,
  });

  final _NodeData data;
  final _NodeState state;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final isLocked = state == _NodeState.locked;
    final isActive = state == _NodeState.active;
    final color = isLocked ? AppColors.textDisabled : data.color;

    return SizedBox.square(
      dimension: 70,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (isActive)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: color.withValues(alpha: .22), width: 7),
              ),
            ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isLocked ? AppColors.surfaceElevated : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.textPrimary : AppColors.divider,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Icon(
              state == _NodeState.completed ? Icons.check : data.icon,
              color: color,
              size: 23,
            ),
          ),
          Positioned(
            left: alignRight ? -142 : 62,
            width: 150,
            child: Column(
              crossAxisAlignment: alignRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  textAlign: alignRight ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLocked
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLocked ? 'Закрыто' : data.subtitle,
                  textAlign: alignRight ? TextAlign.right : TextAlign.left,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.25,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecretNode extends StatelessWidget {
  const _SecretNode({required this.unlocked});

  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          unlocked ? 'Найден скрытый узел' : 'Скрытый узел',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: unlocked ? AppColors.gold : AppColors.textDisabled,
          ),
        ),
        const SizedBox(width: 7),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? AppColors.gold : AppColors.surfaceElevated,
          ),
          child: Icon(
            unlocked ? Icons.auto_awesome : Icons.lock_outline,
            size: 16,
            color: unlocked ? AppColors.surface : AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

class _NodeData {
  const _NodeData(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.points, required this.completedSegments});

  final List<Offset> points;
  final int completedSegments;

  @override
  void paint(Canvas canvas, Size size) {
    final pending = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final passed = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(start.dx, (start.dy + end.dy) / 2, end.dx,
            (start.dy + end.dy) / 2, end.dx, end.dy);
      _drawDashed(canvas, path, index < completedSegments ? passed : pending);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += 14) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 8, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.completedSegments != completedSegments ||
      oldDelegate.points != points;
}
