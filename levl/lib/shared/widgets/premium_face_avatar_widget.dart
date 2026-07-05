import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/avatar_config.dart';

const _normalizedEyeCenters = [
  Offset(0.420, 0.397),
  Offset(0.585, 0.397),
];

class PremiumFaceAvatarWidget extends StatefulWidget {
  final AvatarConfig config;
  final double size;
  final int level;
  final int streak;
  final bool compact;
  final bool showFrame;
  final bool animate;

  const PremiumFaceAvatarWidget({
    super.key,
    this.config = const AvatarConfig(),
    this.size = 220,
    this.level = 1,
    this.streak = 0,
    this.compact = false,
    this.showFrame = true,
    this.animate = true,
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
      duration: const Duration(milliseconds: 7200),
    );
    if (widget.animate) {
      _life.repeat();
    } else {
      _life.value = 0.18;
    }
  }

  @override
  void didUpdateWidget(covariant PremiumFaceAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == oldWidget.animate) return;
    if (widget.animate) {
      _life.repeat();
    } else {
      _life
        ..stop()
        ..value = 0.18;
    }
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
          final lookY = math.sin(cycle * 0.31 + 2.4) * 0.55 +
              math.sin(cycle * 0.91 + 0.3) * 0.16;
          final idleTilt = math.sin(cycle * 0.27 + 0.4) * 0.006;
          final depthTurn = math.sin(cycle * 0.20 + 1.1) * 0.012 + look * 0.004;
          final settle = math.sin(cycle * 0.73 + 2.2) * 0.5;
          final pulse = (math.sin(t * math.pi * 2 + math.pi / 3) + 1) / 2;
          final assetPath = _assetPath();
          final skinTone =
              widget.config.skinTone % AvatarConfig.premiumSkinToneCount;
          final skinMaskPath = _skinMaskAssetPath();

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: DecoratedBox(
              decoration: widget.showFrame
                  ? BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        widget.compact ? 24 : 32,
                      ),
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
                        time: t,
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
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: Image.asset(
                                  assetPath,
                                  key: ValueKey(assetPath),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  gaplessPlayback: true,
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: skinTone == 1
                                    ? const SizedBox.expand(
                                        key: ValueKey('skin-tone-natural'),
                                      )
                                    : _SkinToneOverlay(
                                        key: ValueKey(
                                          '$skinMaskPath-$skinTone',
                                        ),
                                        maskPath: skinMaskPath,
                                        skinTone: skinTone,
                                      ),
                              ),
                              CustomPaint(
                                painter: _EyeTintPainter(
                                  eyeColor: widget.config.eyeColor,
                                  compact: widget.compact,
                                ),
                              ),
                              CustomPaint(
                                painter: _BrowPainter(
                                  style: widget.config.brows,
                                  hairColor: widget.config.hairColor,
                                  compact: widget.compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: _FaceLifePainter(
                        time: t,
                        look: look,
                        lookY: lookY,
                        breath: breath,
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
                          pulse: pulse,
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
    final style = _hairStyleName();
    const colors = ['dark', 'brown', 'chestnut'];
    final color =
        colors[widget.config.hairColor.clamp(0, colors.length - 1).toInt()];
    return 'assets/character_v2/faces/levl_face_male_${style}_$color.png';
  }

  String _skinMaskAssetPath() {
    return 'assets/character_v2/faces/levl_face_skin_mask_${_hairStyleName()}.png';
  }

  String _hairStyleName() {
    const styles = ['volume', 'crop', 'sidepart', 'buzz', 'slickback', 'curly'];
    return styles[widget.config.hair % styles.length];
  }
}

class _SkinToneOverlay extends StatelessWidget {
  static const _solidMask = ColorFilter.matrix([
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    10,
    0,
  ]);

  final String maskPath;
  final int skinTone;

  const _SkinToneOverlay({
    super.key,
    required this.maskPath,
    required this.skinTone,
  });

  @override
  Widget build(BuildContext context) {
    final spec = switch (skinTone % AvatarConfig.premiumSkinToneCount) {
      0 => const (color: Color(0xFFFFEBE0), opacity: 0.24),
      2 => const (color: Color(0xFFAE6445), opacity: 0.20),
      _ => const (color: Color(0xFF4D2D24), opacity: 0.30),
    };

    return Opacity(
      opacity: spec.opacity,
      child: ColorFiltered(
        colorFilter: _solidMask,
        child: Image.asset(
          maskPath,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          color: spec.color,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _EyeTintPainter extends CustomPainter {
  final int eyeColor;
  final bool compact;

  _EyeTintPainter({required this.eyeColor, required this.compact});

  @override
  void paint(Canvas canvas, Size size) {
    if (eyeColor == 0) return;

    const colors = [Color(0xFF6A4A32), Color(0xFF4F8098), Color(0xFF527956)];
    final tint = colors[eyeColor.clamp(0, colors.length - 1).toInt()];
    final radiusX = size.shortestSide * 0.0120;
    final radiusY = size.shortestSide * 0.0093;
    final fill = Paint()
      ..color = tint.withValues(alpha: compact ? 0.72 : 0.78)
      ..blendMode = BlendMode.color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.18);
    final light = Paint()
      ..color = tint.withValues(alpha: compact ? 0.18 : 0.22)
      ..blendMode = BlendMode.screen;
    final colorLift = Paint()
      ..color = tint.withValues(alpha: compact ? 0.24 : 0.28)
      ..blendMode = BlendMode.srcOver;
    final pupil = Paint()
      ..color = const Color(0xFF171413).withValues(alpha: 0.72)
      ..blendMode = BlendMode.srcOver;

    for (final normalized in _normalizedEyeCenters) {
      final center = Offset(
        size.width * normalized.dx,
        size.height * normalized.dy,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radiusX * 2,
          height: radiusY * 2,
        ),
        fill,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radiusX * 1.68,
          height: radiusY * 1.62,
        ),
        colorLift,
      );
      canvas.drawCircle(center, size.shortestSide * 0.0038, pupil);
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(-radiusX * 0.18, -radiusY * 0.14),
          width: radiusX * 0.82,
          height: radiusY * 0.72,
        ),
        light,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EyeTintPainter oldDelegate) {
    return oldDelegate.eyeColor != eyeColor || oldDelegate.compact != compact;
  }
}

class _BrowPainter extends CustomPainter {
  final int style;
  final int hairColor;
  final bool compact;

  _BrowPainter({
    required this.style,
    required this.hairColor,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final browStyle = style % AvatarConfig.premiumBrowStyleCount;
    if (browStyle == 0) return;

    const colors = [Color(0xFF171311), Color(0xFF2B201A), Color(0xFF3A2419)];
    final color = colors[hairColor.clamp(0, colors.length - 1).toInt()];
    final thickness = switch (browStyle) {
      1 => 0.0062,
      2 => 0.0090,
      _ => 0.0070,
    };
    final base = Paint()
      ..color = color.withValues(alpha: compact ? 0.30 : 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * thickness
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.multiply
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.16);

    for (final isLeft in [true, false]) {
      canvas.drawPath(_browPath(size, browStyle, isLeft), base);
      _drawBrowHairs(canvas, size, browStyle, isLeft, color);
    }
  }

  Path _browPath(Size size, int browStyle, bool isLeft) {
    final outerX = isLeft ? 0.356 : 0.644;
    final innerX = isLeft ? 0.480 : 0.520;
    final direction = isLeft ? 1.0 : -1.0;
    final (outerY, crestY, innerY) = switch (browStyle) {
      1 => (0.362, 0.358, 0.358),
      2 => (0.368, 0.344, 0.350),
      _ => (0.354, 0.346, 0.369),
    };

    return Path()
      ..moveTo(size.width * outerX, size.height * outerY)
      ..cubicTo(
        size.width * (outerX + direction * 0.035),
        size.height * crestY,
        size.width * (innerX - direction * 0.028),
        size.height * crestY,
        size.width * innerX,
        size.height * innerY,
      );
  }

  void _drawBrowHairs(
    Canvas canvas,
    Size size,
    int browStyle,
    bool isLeft,
    Color color,
  ) {
    final direction = isLeft ? 1.0 : -1.0;
    final startX = isLeft ? 0.368 : 0.632;
    final count = browStyle == 2 ? 10 : 8;
    final hair = Paint()
      ..color = color.withValues(alpha: compact ? 0.30 : 0.36)
      ..strokeWidth = math.max(0.58, size.shortestSide * 0.0023)
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.multiply;

    for (var i = 0; i < count; i++) {
      final progress = i / (count - 1);
      final x = startX + direction * progress * 0.096;
      final y = switch (browStyle) {
        1 => 0.360 - math.sin(progress * math.pi) * 0.004,
        2 => 0.364 - math.sin(progress * math.pi) * 0.018,
        _ => 0.354 + progress * 0.014 - math.sin(progress * math.pi) * 0.008,
      };
      final lift = (0.003 + (1 - progress) * 0.004) * size.height;
      canvas.drawLine(
        Offset(size.width * x, size.height * y),
        Offset(size.width * (x + direction * 0.004), size.height * y - lift),
        hair,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BrowPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.hairColor != hairColor ||
        oldDelegate.compact != compact;
  }
}

class _PremiumFaceStagePainter extends CustomPainter {
  final Color color;
  final double pulse;
  final double time;
  final int level;
  final int streak;

  _PremiumFaceStagePainter({
    required this.color,
    required this.pulse,
    required this.time,
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
    _drawFocusMotes(canvas, size, center);

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

  void _drawFocusMotes(Canvas canvas, Size size, Offset center) {
    final radius = size.shortestSide * 0.41;
    final motePaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final phase = time * math.pi * 2 + i * math.pi * 0.68;
      final moteRadius = radius * (0.86 + i * 0.055);
      final position = center +
          Offset(
            math.cos(phase * (0.34 + i * 0.04)) * moteRadius,
            math.sin(phase * (0.28 + i * 0.03)) * moteRadius * 0.72,
          );
      final alpha = 0.08 + pulse * 0.05 + i * 0.012;
      motePaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(
        position,
        size.shortestSide * (0.008 + i * 0.002),
        motePaint,
      );

      linePaint.color = color.withValues(alpha: alpha * 0.46);
      canvas.drawLine(
        position,
        position + Offset(math.cos(phase) * 9, math.sin(phase) * 5),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumFaceStagePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pulse != pulse ||
        oldDelegate.time != time ||
        oldDelegate.level != level ||
        oldDelegate.streak != streak;
  }
}

class _FaceLifePainter extends CustomPainter {
  final double time;
  final double look;
  final double lookY;
  final double breath;
  final bool compact;
  final Color stateColor;

  _FaceLifePainter({
    required this.time,
    required this.look,
    required this.lookY,
    required this.breath,
    required this.compact,
    required this.stateColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawEyeGlints(canvas, size);
    _drawAttentionPulse(canvas, size);
  }

  void _drawEyeGlints(Canvas canvas, Size size) {
    final dx = look * size.width * 0.006;
    final dy = lookY * size.height * 0.003 +
        math.sin(time * math.pi * 2 * 0.61) * size.height * 0.001;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.26);
    for (final normalized in _normalizedEyeCenters) {
      final center = Offset(
        size.width * normalized.dx + dx - size.width * 0.0035,
        size.height * normalized.dy + dy - size.height * 0.0025,
      );
      canvas.drawCircle(center, compact ? 0.75 : 1.0, paint);
    }
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
        oldDelegate.lookY != lookY ||
        oldDelegate.breath != breath ||
        oldDelegate.compact != compact ||
        oldDelegate.stateColor != stateColor;
  }
}

class _StatusSignal extends StatelessWidget {
  final Color color;
  final int streak;
  final double pulse;

  const _StatusSignal({
    required this.color,
    required this.streak,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final isStreaking = streak >= 7;
    return Transform.scale(
      scale: 1 + pulse * (isStreaking ? 0.045 : 0.026),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.background, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.14 + pulse * 0.18),
              blurRadius: isStreaking ? 16 : 10,
              spreadRadius: isStreaking ? 1.5 : 0.5,
            ),
          ],
        ),
        child: Icon(
          isStreaking
              ? Icons.local_fire_department_rounded
              : Icons.bolt_rounded,
          color: color,
          size: 17,
        ),
      ),
    );
  }
}
