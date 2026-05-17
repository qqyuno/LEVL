import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../models/avatar_config.dart';

/// Renders a DiceBear avatar wrapped in LEVL identity layers:
/// background, aura, frame and earned badge.
class AvatarWidget extends StatelessWidget {
  final AvatarConfig config;
  final double size;
  final int streak;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    required this.config,
    this.size = 120,
    this.streak = 0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final url = config.toUrl(size: size.toInt().clamp(64, 512));
    final frame = _frameStyle(config.frameId, streak);
    final aura = _auraStyle(config.auraId, streak);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (showBorder && aura.color != Colors.transparent)
            Container(
              width: size * 0.98,
              height: size * 0.98,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: aura.color.withValues(alpha: aura.opacity),
                    blurRadius: aura.blur,
                    spreadRadius: aura.spread,
                  ),
                ],
              ),
            ),
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(showBorder ? frame.width : 0),
            decoration: showBorder
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: frame.gradient,
                    border: frame.gradient == null
                        ? Border.all(color: frame.color, width: frame.width)
                        : null,
                    boxShadow: frame.shadow,
                  )
                : null,
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: _backgroundDecoration(config.backgroundId),
                  ),
                  SvgPicture.network(
                    url,
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) => Center(
                      child: SizedBox(
                        width: size * 0.12,
                        height: size * 0.12,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  if (config.backgroundId == 'signal')
                    CustomPaint(painter: _SignalPainter()),
                ],
              ),
            ),
          ),
          if (showBorder && config.badgeId != 'none')
            Positioned(
              right: size * 0.04,
              bottom: size * 0.04,
              child: _Badge(id: config.badgeId, size: size * 0.24),
            ),
        ],
      ),
    );
  }

  BoxDecoration _backgroundDecoration(String id) {
    return switch (id) {
      'paper' => const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF0F0ED)],
          ),
        ),
      'gold' => const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [Color(0xFFFFF4C8), Color(0xFFF0F0ED)],
          ),
        ),
      'night' => const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF222222), Color(0xFF0A0A0A)],
          ),
        ),
      'signal' => const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8DB), Color(0xFFEAF4EF)],
          ),
        ),
      _ => BoxDecoration(
          color: Color(int.parse('FF${config.bgColor}', radix: 16)),
        ),
    };
  }

  _FrameStyle _frameStyle(String id, int streak) {
    if (id == 'flame' || (id == 'system' && streak >= 7)) {
      return _FrameStyle(
        width: 4,
        color: AppColors.warning,
        gradient: const SweepGradient(
          colors: [
            Color(0xFFB8962E),
            Color(0xFFFF6B35),
            Color(0xFFB8962E),
          ],
        ),
        shadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.24),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      );
    }

    return switch (id) {
      'none' => const _FrameStyle(width: 0, color: Colors.transparent),
      'gold' => _FrameStyle(
          width: 4,
          color: AppColors.gold,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD4AF4A), Color(0xFF8B6A15)],
          ),
          shadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.26),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
      'black' => const _FrameStyle(width: 4, color: AppColors.textPrimary),
      _ => const _FrameStyle(width: 3, color: AppColors.divider),
    };
  }

  _AuraStyle _auraStyle(String id, int streak) {
    if (id == 'none' && streak >= 30) {
      return const _AuraStyle(
        color: AppColors.gold,
        opacity: 0.26,
        blur: 24,
        spread: 4,
      );
    }
    if (id == 'none' && streak >= 7) {
      return const _AuraStyle(
        color: AppColors.sphereDiscipline,
        opacity: 0.2,
        blur: 18,
        spread: 2,
      );
    }

    return switch (id) {
      'focus' => const _AuraStyle(
          color: AppColors.sphereKnowledge,
          opacity: 0.18,
          blur: 20,
          spread: 2,
        ),
      'gold' => const _AuraStyle(
          color: AppColors.gold,
          opacity: 0.28,
          blur: 24,
          spread: 3,
        ),
      'flame' => const _AuraStyle(
          color: AppColors.warning,
          opacity: 0.28,
          blur: 26,
          spread: 4,
        ),
      'storm' => const _AuraStyle(
          color: AppColors.sphereWill,
          opacity: 0.24,
          blur: 28,
          spread: 4,
        ),
      _ => const _AuraStyle(
          color: Colors.transparent,
          opacity: 0,
          blur: 0,
          spread: 0,
        ),
    };
  }
}

class _Badge extends StatelessWidget {
  final String id;
  final double size;

  const _Badge({required this.id, required this.size});

  @override
  Widget build(BuildContext context) {
    final icon = switch (id) {
      'level' => Icons.bolt_rounded,
      'streak' => Icons.local_fire_department_rounded,
      'system' => Icons.auto_awesome_rounded,
      _ => Icons.check_rounded,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: size * 0.09),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.48, color: AppColors.gold),
    );
  }
}

class _SignalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.2 + i * 0.15);
      canvas.drawLine(Offset(-10, y), Offset(size.width + 10, y - 22), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FrameStyle {
  final double width;
  final Color color;
  final Gradient? gradient;
  final List<BoxShadow>? shadow;

  const _FrameStyle({
    required this.width,
    required this.color,
    this.gradient,
    this.shadow,
  });
}

class _AuraStyle {
  final Color color;
  final double opacity;
  final double blur;
  final double spread;

  const _AuraStyle({
    required this.color,
    required this.opacity,
    required this.blur,
    required this.spread,
  });
}
