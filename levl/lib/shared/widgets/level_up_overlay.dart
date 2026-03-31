import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';
import '../providers/level_up_provider.dart';

class LevelUpOverlay extends ConsumerWidget {
  const LevelUpOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newLevel = ref.watch(levelUpNotifierProvider);
    if (newLevel == null) return const SizedBox.shrink();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => ref.read(levelUpNotifierProvider.notifier).dismiss(),
        child: Container(
          color: Colors.black.withValues(alpha: 0.65),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gold rain — полный экран
              Lottie.asset(
                'assets/animations/lottie/level_up.json',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                repeat: false,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      const ['**'],
                      value: AppColors.gold,
                    ),
                  ],
                ),
                onLoaded: (composition) {
                  Future.delayed(
                    composition.duration + const Duration(milliseconds: 400),
                    () => ref.read(levelUpNotifierProvider.notifier).dismiss(),
                  );
                },
              ),

              // Текст поверх анимации
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'УРОВЕНЬ $newLevel',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 44,
                      color: AppColors.gold,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Система зафиксировала.',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'нажми, чтобы продолжить',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.white30,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
