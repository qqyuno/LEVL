import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/avatar_config.dart';

/// Renders a DiceBear Notionists SVG avatar with optional streak aura.
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
    final auraColor = _auraColor(streak);
    final url = config.toUrl(size: size.toInt().clamp(64, 512));

    return Container(
      width: size,
      height: size,
      decoration: showBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: auraColor,
                width: streak >= 7 ? 3.0 : 2.0,
              ),
              boxShadow: streak >= 7
                  ? [
                      BoxShadow(
                        color: auraColor.withAlpha(60),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            )
          : null,
      child: ClipOval(
        child: ColoredBox(
          color: Color(int.parse('FF${config.bgColor}', radix: 16)),
          child: SvgPicture.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => SizedBox(
              width: size,
              height: size,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _auraColor(int streak) {
    if (streak >= 100) return const Color(0xFFFF6B35);
    if (streak >= 30) return const Color(0xFFB8962E);
    if (streak >= 7) return const Color(0xFF4A90D9);
    return const Color(0xFFE2E2DE);
  }
}
