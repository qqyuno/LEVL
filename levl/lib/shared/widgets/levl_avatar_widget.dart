import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/avatar_config.dart';

class LevlAvatarWidget extends StatefulWidget {
  final AvatarConfig config;
  final double width;
  final double height;
  final int level;
  final int streak;
  final bool interactive;
  final bool showStage;
  final bool compact;
  final ValueChanged<int>? onAngleChanged;

  const LevlAvatarWidget({
    super.key,
    required this.config,
    this.width = 220,
    this.height = 300,
    this.level = 1,
    this.streak = 0,
    this.interactive = false,
    this.showStage = true,
    this.compact = false,
    this.onAngleChanged,
  });

  @override
  State<LevlAvatarWidget> createState() => _LevlAvatarWidgetState();
}

class _LevlAvatarWidgetState extends State<LevlAvatarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _life;
  late int _angle;
  double _dragDx = 0;

  @override
  void initState() {
    super.initState();
    _angle = widget.config.viewAngle
        .clamp(0, AvatarConfig.viewAngleCount - 1)
        .toInt();
    _life = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant LevlAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.viewAngle != widget.config.viewAngle) {
      _angle = widget.config.viewAngle
          .clamp(0, AvatarConfig.viewAngleCount - 1)
          .toInt();
    }
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  void _turn(int delta) {
    final next = (_angle + delta) % AvatarConfig.viewAngleCount;
    setState(
        () => _angle = next < 0 ? next + AvatarConfig.viewAngleCount : next);
    widget.onAngleChanged?.call(_angle);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
      animation: _life,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _LevlAvatarPainter(
            config: widget.config,
            life: _life.value,
            angle: _angle,
            level: widget.level,
            streak: widget.streak,
            showStage: widget.showStage,
            compact: widget.compact,
          ),
        );
      },
    );

    child = SizedBox(width: widget.width, height: widget.height, child: child);

    if (!widget.interactive) return RepaintBoundary(child: child);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        _dragDx += details.delta.dx;
        if (_dragDx.abs() < 26) return;
        _turn(_dragDx < 0 ? 1 : -1);
        _dragDx = 0;
      },
      onHorizontalDragEnd: (_) => _dragDx = 0,
      child: RepaintBoundary(child: child),
    );
  }
}

class _LevlAvatarPainter extends CustomPainter {
  final AvatarConfig config;
  final double life;
  final int angle;
  final int level;
  final int streak;
  final bool showStage;
  final bool compact;

  _LevlAvatarPainter({
    required this.config,
    required this.life,
    required this.angle,
    required this.level,
    required this.streak,
    required this.showStage,
    required this.compact,
  });

  static const _skinTones = [
    Color(0xFFE8C5A6),
    Color(0xFFD9B28F),
    Color(0xFFC89268),
    Color(0xFFA56E4B),
    Color(0xFF7A4B34),
    Color(0xFFF0D6BF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (showStage) _drawStage(canvas, size);

    final stateColor = _stateColor();
    final breath = math.sin(life * math.pi * 2);
    final pulse = (math.sin(life * math.pi * 2 + math.pi / 4) + 1) / 2;
    final blink = _blinkAmount();
    final look = math.sin(life * math.pi * 2 * 0.5) * 0.9;
    final isBack = angle == 4;
    final isSide = angle == 2;
    final yaw = switch (angle) {
      1 => -0.34,
      2 => -0.58,
      3 => 0.34,
      4 => 0.08,
      _ => 0.0,
    };

    final scale = math.min(size.width / 220, size.height / 300);
    final baseHeight = compact ? 260.0 : 282.0;

    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.53);
    canvas.scale(scale);
    canvas.translate(0, -baseHeight / 2);

    _drawAura(canvas, stateColor, pulse, breath);
    _drawShadow(canvas, breath);
    _drawLegs(canvas, yaw, breath, isSide);
    _drawTorso(canvas, yaw, breath, stateColor, isSide, isBack);
    _drawArms(canvas, yaw, breath, stateColor, isSide, isBack);
    _drawHead(canvas, yaw, breath, blink, look, isSide, isBack);
    _drawAccessory(canvas, yaw, breath, stateColor, isSide, isBack);

    canvas.restore();
  }

  void _drawStage(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surface,
          AppColors.background,
        ],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.deflate(1), Radius.circular(compact ? 18 : 30)),
      bg,
    );

    final linePaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final baseY = size.height * 0.82;
    canvas.drawLine(
      Offset(size.width * 0.18, baseY),
      Offset(size.width * 0.82, baseY),
      linePaint,
    );

    if (streak > 0 || level >= 3) {
      final gold = Paint()
        ..color = AppColors.gold.withValues(alpha: level >= 3 ? 0.12 : 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.44),
          size.shortestSide * 0.33, gold);
    }
  }

  void _drawAura(Canvas canvas, Color stateColor, double pulse, double breath) {
    final auraPaint = Paint()
      ..color = stateColor.withValues(alpha: 0.10 + pulse * 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;
    final glow = Paint()
      ..color = stateColor.withValues(alpha: 0.08 + pulse * 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final height = 230 + breath * 3;
    final width = 112 + pulse * 8;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 128), width: width, height: 26),
      glow,
    );

    if (config.auraId != 'none' || config.expression != 0 || streak >= 7) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(0, 118 + breath), width: width, height: height),
        auraPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(0, 118 + breath),
            width: width + 22,
            height: height + 16),
        -math.pi * 0.72,
        math.pi * 0.32,
        false,
        auraPaint..strokeWidth = 2.2,
      );
    }
  }

  void _drawShadow(Canvas canvas, double breath) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.13 - breath * 0.01)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 253), width: 94, height: 18),
      paint,
    );
  }

  void _drawLegs(Canvas canvas, double yaw, double breath, bool isSide) {
    final pants = _pantsColor();
    final outline = _darken(pants, 0.2);
    final legW = _bodyProfile().legWidth * (isSide ? 0.72 : 1);
    final gap = isSide ? 4.0 : 16.0;
    final hipY = 137.0 + breath * 0.8;
    const footY = 250.0;

    final leftX = -gap;
    final rightX = gap;
    _drawLeg(
        canvas, Offset(leftX - yaw * 7, hipY), footY, legW, pants, outline);
    if (!isSide) {
      _drawLeg(
          canvas, Offset(rightX - yaw * 4, hipY), footY, legW, pants, outline);
    }

    _drawShoe(canvas, Offset(leftX - yaw * 7, footY), isSide ? -1 : 0);
    if (!isSide) _drawShoe(canvas, Offset(rightX - yaw * 4, footY), 1);
  }

  void _drawLeg(Canvas canvas, Offset hip, double footY, double legW,
      Color color, Color outline) {
    final path = Path()
      ..moveTo(hip.dx - legW, hip.dy)
      ..cubicTo(hip.dx - legW * 0.95, hip.dy + 34, hip.dx - legW * 0.72,
          footY - 44, hip.dx - legW * 0.52, footY)
      ..lineTo(hip.dx + legW * 0.58, footY)
      ..cubicTo(hip.dx + legW * 0.72, footY - 46, hip.dx + legW * 0.85,
          hip.dy + 34, hip.dx + legW, hip.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = outline.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawShoe(Canvas canvas, Offset ankle, int side) {
    final color = _shoeColor();
    final width = config.shoes == 2 ? 30.0 : 25.0;
    final height = config.shoes == 2 ? 9.5 : 8.0;
    final xShift = side == 0 ? 0 : side * 4.5;
    final rect = Rect.fromCenter(
      center: Offset(ankle.dx + xShift, ankle.dy + 2),
      width: width,
      height: height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = color,
    );
    canvas.drawLine(
      Offset(rect.left + 4, rect.center.dy + 1),
      Offset(rect.right - 5, rect.center.dy + 1),
      Paint()
        ..color = _lighten(color, 0.25).withValues(alpha: 0.45)
        ..strokeWidth = 1,
    );
  }

  void _drawTorso(
    Canvas canvas,
    double yaw,
    double breath,
    Color stateColor,
    bool isSide,
    bool isBack,
  ) {
    final profile = _bodyProfile();
    final shoulder = profile.shoulder * (isSide ? 0.58 : 1.0);
    final waist = profile.waist * (isSide ? 0.60 : 1.0);
    final topY = 82.0 - breath * 1.8;
    final bottomY = 151.0 + breath * 0.9;
    final centerShift = yaw * 10;
    final topColor = _topColor();

    final base = Path()
      ..moveTo(centerShift - shoulder, topY)
      ..cubicTo(centerShift - shoulder * 0.86, topY + 28, centerShift - waist,
          bottomY - 26, centerShift - waist * 0.86, bottomY)
      ..lineTo(centerShift + waist * 0.86, bottomY)
      ..cubicTo(
          centerShift + waist,
          bottomY - 26,
          centerShift + shoulder * 0.86,
          topY + 28,
          centerShift + shoulder,
          topY)
      ..close();

    canvas.drawShadow(base, Colors.black.withValues(alpha: 0.18), 6, false);
    canvas.drawPath(base, Paint()..color = topColor);

    final highlight = Paint()
      ..color = _lighten(topColor, 0.12).withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(base, highlight);

    if (config.top == 0 || config.top == 3 || config.top == 4) {
      _drawLapels(canvas, centerShift, topY, bottomY, stateColor, isBack);
    } else if (config.top == 1) {
      _drawOvershirt(canvas, centerShift, topY, bottomY);
    } else if (config.top == 2) {
      _drawHoodie(canvas, centerShift, topY, bottomY);
    } else {
      _drawTee(canvas, centerShift, topY, bottomY);
    }
  }

  void _drawLapels(Canvas canvas, double cx, double topY, double bottomY,
      Color stateColor, bool isBack) {
    if (isBack) return;
    final stroke = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final accent = Paint()
      ..color = stateColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final left = Path()
      ..moveTo(cx - 9, topY + 7)
      ..lineTo(cx - 26, topY + 24)
      ..lineTo(cx - 7, bottomY - 10);
    final right = Path()
      ..moveTo(cx + 9, topY + 7)
      ..lineTo(cx + 26, topY + 24)
      ..lineTo(cx + 7, bottomY - 10);
    canvas.drawPath(left, stroke);
    canvas.drawPath(right, stroke);
    canvas.drawLine(
        Offset(cx + 20, topY + 34), Offset(cx + 33, topY + 34), accent);
  }

  void _drawOvershirt(Canvas canvas, double cx, double topY, double bottomY) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx, topY + 8), Offset(cx, bottomY - 6), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx + 18, topY + 42), width: 18, height: 11),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
  }

  void _drawHoodie(Canvas canvas, double cx, double topY, double bottomY) {
    final hood = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, topY + 13), width: 50, height: 32),
      math.pi * 0.08,
      math.pi * 0.84,
      false,
      hood,
    );
    final cord = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.55)
      ..strokeWidth = 1.1;
    canvas.drawLine(
        Offset(cx - 6, topY + 25), Offset(cx - 10, topY + 52), cord);
    canvas.drawLine(
        Offset(cx + 6, topY + 25), Offset(cx + 10, topY + 52), cord);
  }

  void _drawTee(Canvas canvas, double cx, double topY, double bottomY) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawLine(
        Offset(cx - 20, topY + 28), Offset(cx + 20, topY + 28), paint);
  }

  void _drawArms(
    Canvas canvas,
    double yaw,
    double breath,
    Color stateColor,
    bool isSide,
    bool isBack,
  ) {
    final topColor = _darken(_topColor(), 0.03);
    final skin = _skinColor();
    final shoulderY = 88.0 - breath * 1.5;
    final handY = 158.0 + breath;
    final shoulder = _bodyProfile().shoulder * (isSide ? 0.58 : 1.0);
    final leftX = -shoulder + yaw * 2;
    final rightX = shoulder + yaw * 10;

    _drawArm(canvas, Offset(leftX, shoulderY), Offset(leftX - 12, handY),
        topColor, skin);
    if (!isSide) {
      _drawArm(canvas, Offset(rightX, shoulderY), Offset(rightX + 13, handY),
          topColor, skin);
    }

    if (!isBack && (config.accessory == 0 || config.accessory == 2)) {
      final watchX = rightX + 13;
      canvas.drawCircle(Offset(watchX, handY - 5), 4.2,
          Paint()..color = AppColors.textPrimary);
      canvas.drawCircle(
          Offset(watchX, handY - 5), 2.1, Paint()..color = stateColor);
    }
  }

  void _drawArm(
      Canvas canvas, Offset shoulder, Offset hand, Color sleeve, Color skin) {
    final path = Path()
      ..moveTo(shoulder.dx - 8, shoulder.dy)
      ..cubicTo(shoulder.dx - 15, shoulder.dy + 24, hand.dx - 10, hand.dy - 22,
          hand.dx - 7, hand.dy)
      ..lineTo(hand.dx + 8, hand.dy)
      ..cubicTo(hand.dx + 8, hand.dy - 23, shoulder.dx + 13, shoulder.dy + 28,
          shoulder.dx + 8, shoulder.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = sleeve);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hand.dx + 1, hand.dy + 4), width: 15, height: 11),
      Paint()..color = skin,
    );
  }

  void _drawHead(
    Canvas canvas,
    double yaw,
    double breath,
    double blink,
    double look,
    bool isSide,
    bool isBack,
  ) {
    final skin = _skinColor();
    final headCenter = Offset(yaw * 12, 47 - breath * 2.2);
    final headW = _headWidth(isSide);
    final headH = _headHeight();

    final neck = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(headCenter.dx, 75 - breath), width: 19, height: 24),
      const Radius.circular(8),
    );
    canvas.drawRRect(neck, Paint()..color = _darken(skin, 0.04));

    final headPath = _headPath(headCenter, headW, headH, isSide);
    canvas.drawShadow(headPath, Colors.black.withValues(alpha: 0.12), 4, false);
    canvas.drawPath(headPath, Paint()..color = skin);

    _drawHair(canvas, headCenter, headW, headH, isSide, isBack);

    if (isBack) {
      _drawEarOrHairBack(canvas, headCenter, headW, headH);
      return;
    }

    _drawFace(canvas, headCenter, headW, headH, yaw, blink, look, isSide);
  }

  Path _headPath(Offset center, double w, double h, bool isSide) {
    final jaw = switch (config.faceShape % AvatarConfig.faceShapeCount) {
      1 => 0.72,
      2 => 0.55,
      3 => 0.84,
      4 => 0.62,
      _ => 0.68,
    };
    final sideNose = isSide ? 7.0 : 0.0;
    return Path()
      ..moveTo(center.dx - w * 0.43, center.dy - h * 0.28)
      ..cubicTo(
          center.dx - w * 0.48,
          center.dy - h * 0.05,
          center.dx - w * 0.40,
          center.dy + h * 0.30,
          center.dx - w * jaw * 0.24,
          center.dy + h * 0.47)
      ..cubicTo(
          center.dx - w * 0.12,
          center.dy + h * 0.57,
          center.dx + w * 0.18,
          center.dy + h * 0.57,
          center.dx + w * jaw * 0.25,
          center.dy + h * 0.45)
      ..cubicTo(
          center.dx + w * 0.48 + sideNose,
          center.dy + h * 0.25,
          center.dx + w * 0.46 + sideNose,
          center.dy - h * 0.12,
          center.dx + w * 0.32,
          center.dy - h * 0.33)
      ..cubicTo(
          center.dx + w * 0.13,
          center.dy - h * 0.54,
          center.dx - w * 0.22,
          center.dy - h * 0.52,
          center.dx - w * 0.43,
          center.dy - h * 0.28)
      ..close();
  }

  void _drawHair(
      Canvas canvas, Offset c, double w, double h, bool isSide, bool isBack) {
    final hairColor = _hairColor();
    final variant = config.hair % 6;
    final paint = Paint()..color = hairColor;
    Path hair;

    if (variant == 1) {
      hair = Path()
        ..moveTo(c.dx - w * 0.50, c.dy - h * 0.24)
        ..cubicTo(c.dx - w * 0.28, c.dy - h * 0.65, c.dx + w * 0.32,
            c.dy - h * 0.62, c.dx + w * 0.47, c.dy - h * 0.18)
        ..cubicTo(c.dx + w * 0.18, c.dy - h * 0.32, c.dx - w * 0.10,
            c.dy - h * 0.20, c.dx - w * 0.50, c.dy - h * 0.24)
        ..close();
    } else if (variant == 2) {
      hair = Path()
        ..moveTo(c.dx - w * 0.48, c.dy - h * 0.18)
        ..cubicTo(c.dx - w * 0.34, c.dy - h * 0.62, c.dx + w * 0.40,
            c.dy - h * 0.67, c.dx + w * 0.50, c.dy - h * 0.15)
        ..lineTo(c.dx + w * 0.44, c.dy + h * 0.34)
        ..cubicTo(c.dx + w * 0.24, c.dy + h * 0.13, c.dx - w * 0.30,
            c.dy + h * 0.04, c.dx - w * 0.48, c.dy - h * 0.18)
        ..close();
    } else if (variant == 3) {
      hair = Path()
        ..moveTo(c.dx - w * 0.52, c.dy - h * 0.18)
        ..cubicTo(c.dx - w * 0.42, c.dy - h * 0.55, c.dx + w * 0.39,
            c.dy - h * 0.58, c.dx + w * 0.50, c.dy - h * 0.15)
        ..cubicTo(c.dx + w * 0.40, c.dy - h * 0.22, c.dx + w * 0.12,
            c.dy - h * 0.08, c.dx - w * 0.04, c.dy - h * 0.22)
        ..cubicTo(c.dx - w * 0.22, c.dy - h * 0.06, c.dx - w * 0.39,
            c.dy - h * 0.12, c.dx - w * 0.52, c.dy - h * 0.18)
        ..close();
    } else if (variant == 4) {
      hair = Path()
        ..addOval(Rect.fromCenter(
            center: Offset(c.dx, c.dy - h * 0.22),
            width: w * 0.78,
            height: h * 0.42));
    } else if (variant == 5) {
      hair = Path()
        ..addOval(Rect.fromCenter(
            center: Offset(c.dx - 4, c.dy - h * 0.30),
            width: w * 0.95,
            height: h * 0.46));
    } else {
      hair = Path()
        ..moveTo(c.dx - w * 0.47, c.dy - h * 0.20)
        ..cubicTo(c.dx - w * 0.32, c.dy - h * 0.55, c.dx + w * 0.32,
            c.dy - h * 0.57, c.dx + w * 0.45, c.dy - h * 0.16)
        ..cubicTo(c.dx + w * 0.18, c.dy - h * 0.25, c.dx - w * 0.20,
            c.dy - h * 0.19, c.dx - w * 0.47, c.dy - h * 0.20)
        ..close();
    }

    canvas.drawPath(hair, paint);
    if (isBack || isSide) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(c.dx, c.dy - h * 0.04),
            width: w * 0.92,
            height: h * 0.75),
        math.pi * 0.72,
        math.pi * 0.56,
        false,
        Paint()
          ..color = _lighten(hairColor, 0.10).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawEarOrHairBack(Canvas canvas, Offset c, double w, double h) {
    canvas.drawLine(
      Offset(c.dx - w * 0.20, c.dy - h * 0.22),
      Offset(c.dx + w * 0.22, c.dy + h * 0.12),
      Paint()
        ..color = _lighten(_hairColor(), 0.16).withValues(alpha: 0.34)
        ..strokeWidth = 1.2,
    );
  }

  void _drawFace(
    Canvas canvas,
    Offset c,
    double w,
    double h,
    double yaw,
    double blink,
    double look,
    bool isSide,
  ) {
    final eyePaint = Paint()..color = AppColors.textPrimary;
    final browPaint = Paint()
      ..color = _darken(_hairColor(), 0.05)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final mouthPaint = Paint()
      ..color = const Color(0xFF7B3F36).withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final eyeY = c.dy - h * 0.04;
    final leftEye = Offset(c.dx - w * 0.16 + look + yaw * 4, eyeY);
    final rightEye =
        Offset(c.dx + w * 0.16 + look + yaw * 4, eyeY + yaw.abs() * 1.2);
    final eyeH = math.max(0.7, 3.8 * (1 - blink));
    final eyeW = isSide ? 4.2 : 6.8;

    if (isSide) {
      canvas.drawOval(
          Rect.fromCenter(center: rightEye, width: eyeW, height: eyeH),
          eyePaint);
      _drawBrow(canvas, rightEye.translate(-3, -8), 1, browPaint);
    } else {
      canvas.drawOval(
          Rect.fromCenter(center: leftEye, width: eyeW, height: eyeH),
          eyePaint);
      canvas.drawOval(
          Rect.fromCenter(center: rightEye, width: eyeW, height: eyeH),
          eyePaint);
      _drawBrow(canvas, leftEye.translate(0, -8), -1, browPaint);
      _drawBrow(canvas, rightEye.translate(0, -8), 1, browPaint);
    }

    final nose = Path()
      ..moveTo(c.dx + yaw * 9, c.dy + 1)
      ..quadraticBezierTo(
          c.dx + 4 + yaw * 12, c.dy + 10, c.dx + yaw * 6, c.dy + 14);
    canvas.drawPath(
      nose,
      Paint()
        ..color = _darken(_skinColor(), 0.18).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    _drawMouth(canvas, c, w, h, mouthPaint);

    if (config.beard >= 0) {
      final beard = Paint()..color = _hairColor().withValues(alpha: 0.18);
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(c.dx, c.dy + h * 0.24),
            width: w * 0.52,
            height: h * 0.28),
        0,
        math.pi,
        false,
        beard
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    }

    if (config.glasses >= 0) _drawGlasses(canvas, leftEye, rightEye, isSide);
  }

  void _drawBrow(Canvas canvas, Offset center, int side, Paint paint) {
    final mood = config.expression;
    final tilt = switch (mood) {
      1 => 1.5,
      2 => -0.8,
      3 => 2.1,
      4 => -1.4,
      _ => 0.0,
    };
    canvas.drawLine(
      Offset(center.dx - 5, center.dy + tilt * side),
      Offset(center.dx + 5, center.dy - tilt * side),
      paint,
    );
  }

  void _drawMouth(Canvas canvas, Offset c, double w, double h, Paint paint) {
    final y = c.dy + h * 0.23;
    final path = Path();
    switch (config.expression % AvatarConfig.expressionCount) {
      case 1:
        path
          ..moveTo(c.dx - 8, y + 3)
          ..quadraticBezierTo(c.dx, y - 1, c.dx + 8, y + 3);
        break;
      case 2:
        path
          ..moveTo(c.dx - 9, y)
          ..quadraticBezierTo(c.dx, y + 7, c.dx + 10, y);
        break;
      case 3:
        path
          ..moveTo(c.dx - 9, y + 2)
          ..lineTo(c.dx + 9, y + 2);
        break;
      case 4:
        path
          ..moveTo(c.dx - 7, y + 1)
          ..quadraticBezierTo(c.dx, y + 4, c.dx + 9, y - 1);
        break;
      default:
        path
          ..moveTo(c.dx - 7, y)
          ..quadraticBezierTo(c.dx, y + 2, c.dx + 8, y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawGlasses(
      Canvas canvas, Offset leftEye, Offset rightEye, bool isSide) {
    final paint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    if (!isSide) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: leftEye, width: 15, height: 9),
            const Radius.circular(5)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: rightEye, width: 15, height: 9),
            const Radius.circular(5)),
        paint,
      );
      canvas.drawLine(
          leftEye.translate(7, 0), rightEye.translate(-7, 0), paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: rightEye, width: 15, height: 9),
            const Radius.circular(5)),
        paint,
      );
    }
  }

  void _drawAccessory(
    Canvas canvas,
    double yaw,
    double breath,
    Color stateColor,
    bool isSide,
    bool isBack,
  ) {
    final id = config.accessory;
    if (id < 0) return;

    final paint = Paint()..color = AppColors.textPrimary;
    final accent = Paint()..color = stateColor;

    if (id == 1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(52 + yaw * 7, 150 + breath),
              width: 22,
              height: 36),
          const Radius.circular(5),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(52 + yaw * 7, 146 + breath),
              width: 16,
              height: 24),
          const Radius.circular(3),
        ),
        Paint()..color = AppColors.surfaceElevated,
      );
    } else if (id == 2) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(42 + yaw * 5, 176), width: 36, height: 45),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF242424),
      );
      canvas.drawLine(Offset(25 + yaw * 5, 155), Offset(44 + yaw * 5, 132),
          accent..strokeWidth = 2);
    } else if (id == 3) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(-45 + yaw * 5, 169), width: 42, height: 30),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFF363636),
      );
      canvas.drawLine(Offset(-63 + yaw * 5, 155), Offset(-27 + yaw * 5, 155),
          accent..strokeWidth = 1.4);
    } else if (id == 4 && !isBack) {
      canvas.drawCircle(Offset(28 + yaw * 10, 47 - breath * 2), 3.3, accent);
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(22 + yaw * 10, 48 - breath * 2),
            width: 18,
            height: 20),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..color = AppColors.textPrimary.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    } else if (id == 5) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(0, 76 - breath * 1.3), width: 30, height: 5),
          const Radius.circular(4),
        ),
        Paint()..color = stateColor.withValues(alpha: 0.76),
      );
    }
  }

  double _blinkAmount() {
    final x = (life * 2.0) % 1.0;
    if (x < 0.88) return 0;
    return math.sin(((x - 0.88) / 0.12).clamp(0.0, 1.0) * math.pi);
  }

  _BodyProfile _bodyProfile() {
    return switch (config.bodyType % AvatarConfig.bodyTypeCount) {
      0 => const _BodyProfile(shoulder: 35, waist: 22, legWidth: 9),
      2 => const _BodyProfile(shoulder: 43, waist: 27, legWidth: 11),
      3 => const _BodyProfile(shoulder: 38, waist: 30, legWidth: 12),
      _ => const _BodyProfile(shoulder: 39, waist: 24, legWidth: 10),
    };
  }

  double _headWidth(bool isSide) {
    final base = switch (config.faceShape % AvatarConfig.faceShapeCount) {
      1 => 42.0,
      2 => 36.0,
      3 => 45.0,
      4 => 39.0,
      _ => 40.0,
    };
    return isSide ? base * 0.72 : base;
  }

  double _headHeight() {
    return switch (config.faceShape % AvatarConfig.faceShapeCount) {
      1 => 51.0,
      2 => 48.0,
      3 => 47.0,
      4 => 53.0,
      _ => 50.0,
    };
  }

  Color _skinColor() =>
      _skinTones[config.skinTone.clamp(0, _skinTones.length - 1).toInt()];

  Color _hairColor() {
    return switch ((config.hair ~/ 8) % 6) {
      1 => const Color(0xFF6A4A35),
      2 => const Color(0xFF1C1C1C),
      3 => const Color(0xFF9A7854),
      4 => const Color(0xFF111111),
      5 => const Color(0xFF554139),
      _ => const Color(0xFF24211F),
    };
  }

  Color _topColor() {
    return switch (config.top % AvatarConfig.topCount) {
      1 => const Color(0xFF2C2D2B),
      2 => const Color(0xFF383A3C),
      3 => const Color(0xFF202733),
      4 => const Color(0xFF151515),
      5 => AppColors.surfaceElevated,
      _ => AppColors.textPrimary,
    };
  }

  Color _pantsColor() {
    return switch (config.pants % AvatarConfig.pantsCount) {
      1 => const Color(0xFF323437),
      2 => const Color(0xFF3C3B34),
      3 => const Color(0xFF262626),
      4 => const Color(0xFF57544F),
      _ => const Color(0xFF1E1E1E),
    };
  }

  Color _shoeColor() {
    return switch (config.shoes % AvatarConfig.shoesCount) {
      1 => const Color(0xFFF2F0EA),
      2 => const Color(0xFF161616),
      3 => const Color(0xFF5A4630),
      4 => AppColors.gold,
      _ => const Color(0xFF252525),
    };
  }

  Color _stateColor() {
    if (streak >= 14 || config.auraId == 'storm') return AppColors.sphereWill;
    if (streak >= 7 || config.auraId == 'flame') return AppColors.warning;
    if (config.auraId == 'gold') return AppColors.gold;
    if (config.auraId == 'focus') return AppColors.sphereKnowledge;

    return switch (config.expression % AvatarConfig.expressionCount) {
      1 => AppColors.sphereWisdom,
      2 => AppColors.gold,
      3 => AppColors.error,
      4 => AppColors.sphereDiscipline,
      _ => AppColors.textSecondary,
    };
  }

  Color _darken(Color color, double amount) =>
      Color.lerp(color, Colors.black, amount)!;
  Color _lighten(Color color, double amount) =>
      Color.lerp(color, Colors.white, amount)!;

  @override
  bool shouldRepaint(covariant _LevlAvatarPainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.life != life ||
        oldDelegate.angle != angle ||
        oldDelegate.level != level ||
        oldDelegate.streak != streak ||
        oldDelegate.showStage != showStage ||
        oldDelegate.compact != compact;
  }
}

class _BodyProfile {
  final double shoulder;
  final double waist;
  final double legWidth;

  const _BodyProfile({
    required this.shoulder,
    required this.waist,
    required this.legWidth,
  });
}
