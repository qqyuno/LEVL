import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/avatar_config.dart';

class PremiumFaceAvatarWidget extends StatefulWidget {
  final AvatarConfig config;
  final double size;
  final int level;
  final int streak;
  final bool compact;
  final bool showFrame;

  const PremiumFaceAvatarWidget({
    super.key,
    this.config = const AvatarConfig(),
    this.size = 220,
    this.level = 1,
    this.streak = 0,
    this.compact = false,
    this.showFrame = true,
  });

  @override
  State<PremiumFaceAvatarWidget> createState() =>
      _PremiumFaceAvatarWidgetState();
}

class _PremiumFaceAvatarWidgetState extends State<PremiumFaceAvatarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _life;

  @override
  void initState() {
    super.initState();
    _life = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _life,
        builder: (context, _) {
          final t = _life.value;
          final cycle = t * math.pi * 2;
          final breath = math.sin(cycle);
          final slowBreath = math.sin(cycle * 0.48 + 0.8);
          final look = math.sin(cycle * 0.42) * 0.72 +
              math.sin(cycle * 1.13 + 1.7) * 0.28;
          final idleTilt = math.sin(cycle * 0.27 + 0.4) * 0.006;
          final depthTurn = math.sin(cycle * 0.20 + 1.1) * 0.012 + look * 0.004;
          final settle = math.sin(cycle * 0.73 + 2.2) * 0.5;
          final pulse = (math.sin(t * math.pi * 2 + math.pi / 3) + 1) / 2;

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: DecoratedBox(
              decoration: widget.showFrame
                  ? BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(widget.compact ? 24 : 32),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: _stateColor().withValues(
                            alpha: 0.10 + pulse * 0.08,
                          ),
                          blurRadius: widget.compact ? 18 : 30,
                          spreadRadius: widget.compact ? 1 : 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    )
                  : const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.compact ? 24 : 32),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.background),
                    ),
                    CustomPaint(
                      painter: _PremiumFaceStagePainter(
                        color: _stateColor(),
                        pulse: pulse,
                        level: widget.level,
                        streak: widget.streak,
                      ),
                    ),
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0008)
                        ..rotateY(depthTurn)
                        ..rotateZ(idleTilt),
                      child: Transform.translate(
                        offset: Offset(look * 1.5, breath * 1.4 + settle * 0.2),
                        child: Transform.scale(
                          scale: 1.014 + breath * 0.003 + slowBreath * 0.002,
                          child: Image.asset(
                            _assetPath(),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: _FaceLifePainter(
                        time: t,
                        look: look,
                        breath: breath,
                        skin: const Color(0xFFC89268),
                        compact: widget.compact,
                        stateColor: _stateColor(),
                      ),
                    ),
                    if (!widget.compact)
                      Positioned(
                        right: 14,
                        bottom: 14,
                        child: _StatusSignal(
                          color: _stateColor(),
                          streak: widget.streak,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _stateColor() {
    if (widget.streak >= 14) return AppColors.sphereWill;
    if (widget.streak >= 7) return AppColors.warning;
    if (widget.level >= 5) return AppColors.gold;
    return AppColors.sphereKnowledge;
  }

  String _assetPath() {
    const styles = ['volume', 'crop', 'sidepart', 'buzz'];
    const colors = ['dark', 'brown', 'chestnut'];
    final style = styles[widget.config.hair % styles.length];
    final color =
        colors[widget.config.hairColor.clamp(0, colors.length - 1).toInt()];
    return 'assets/character_v2/faces/levl_face_male_${style}_$color.png';
  }
}

class _PremiumFaceStagePainter extends CustomPainter {
  final Color color;
  final double pulse;
  final int level;
  final int streak;

  _PremiumFaceStagePainter({
    required this.color,
    required this.pulse,
    required this.level,
    required this.streak,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.49);
    final ring = Paint()
      ..color = color.withValues(alpha: 0.10 + pulse * 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, size.shortestSide * 0.38, ring);

    if (level >= 3 || streak >= 7) {
      final arc = Paint()
        ..color = AppColors.gold.withValues(alpha: 0.18 + pulse * 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCenter(
        center: center,
        width: size.shortestSide * 0.84,
        height: size.shortestSide * 0.84,
      );
      canvas.drawArc(rect, -math.pi * 0.78, math.pi * 0.35, false, arc);
      canvas.drawArc(rect, math.pi * 0.32, math.pi * 0.22, false, arc);
    }

    final floor = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.86),
        width: size.width * 0.58,
        height: size.height * 0.08,
      ),
      floor,
    );
  }

  @override
  bool shouldRepaint(covariant _PremiumFaceStagePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pulse != pulse ||
        oldDelegate.level != level ||
        oldDelegate.streak != streak;
  }
}

class _FaceLifePainter extends CustomPainter {
  final double time;
  final double look;
  final double breath;
  final Color skin;
  final bool compact;
  final Color stateColor;

  _FaceLifePainter({
    required this.time,
    required this.look,
    required this.breath,
    required this.skin,
    required this.compact,
    required this.stateColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blink = _blinkAmount();
    _drawEyeGlints(canvas, size, 1 - blink);
    _drawAttentionPulse(canvas, size);

    if (blink <= 0.02) return;

    final y = size.height * 0.397;
    final left = Offset(size.width * 0.417 + look * 1.7, y);
    final right = Offset(size.width * 0.587 + look * 1.7, y);
    final lidPaint = Paint()
      ..color = skin.withValues(alpha: 0.58 * blink)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, compact ? 1.5 : 2.2);
    final linePaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.40 * blink)
      ..strokeWidth = compact ? 1.2 : 1.7
      ..strokeCap = StrokeCap.round;

    for (final eye in [left, right]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: eye,
            width: size.width * 0.072,
            height: size.height * 0.021 * blink,
          ),
          const Radius.circular(999),
        ),
        lidPaint,
      );
      canvas.drawLine(
        Offset(eye.dx - size.width * 0.030, eye.dy),
        Offset(eye.dx + size.width * 0.030, eye.dy + blink),
        linePaint,
      );
    }
  }

  double _blinkAmount() {
    final primary = _blinkPulse((time + 0.02) % 1.0, 0.82, 0.055);
    final secondary = _blinkPulse((time + 0.41) % 1.0, 0.91, 0.035) * 0.72;
    return math.max(primary, secondary);
  }

  double _blinkPulse(double x, double start, double width) {
    if (x < start || x > start + width) return 0;
    return math.sin(((x - start) / width).clamp(0.0, 1.0) * math.pi);
  }

  void _drawEyeGlints(Canvas canvas, Size size, double eyeOpen) {
    if (eyeOpen <= 0.12) return;
    final dx = look * size.width * 0.006;
    final dy = math.sin(time * math.pi * 2 * 0.61) * size.height * 0.001;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 + 0.14 * eyeOpen);
    canvas.drawCircle(
      Offset(size.width * 0.438 + dx, size.height * 0.383 + dy),
      compact ? 0.9 : 1.2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.605 + dx, size.height * 0.383 + dy),
      compact ? 0.9 : 1.2,
      paint,
    );
  }

  void _drawAttentionPulse(Canvas canvas, Size size) {
    if (compact) return;

    final alpha = (0.020 + (breath + 1) * 0.006).clamp(0.0, 0.04);
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.08),
        radius: 0.56,
        colors: [
          stateColor.withValues(alpha: alpha),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceLifePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.look != look ||
        oldDelegate.breath != breath ||
        oldDelegate.compact != compact ||
        oldDelegate.skin != skin ||
        oldDelegate.stateColor != stateColor;
  }
}

class _StatusSignal extends StatelessWidget {
  final Color color;
  final int streak;

  const _StatusSignal({required this.color, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: Icon(
        streak >= 7 ? Icons.local_fire_department_rounded : Icons.bolt_rounded,
        color: color,
        size: 17,
      ),
    );
  }
}
