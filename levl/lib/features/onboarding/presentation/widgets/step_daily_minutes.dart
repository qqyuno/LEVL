import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'step_shell.dart';

/// Step 7: Сколько времени в день?
class StepDailyMinutes extends ConsumerStatefulWidget {
  const StepDailyMinutes({super.key});

  @override
  ConsumerState<StepDailyMinutes> createState() => _StepDailyMinutesState();
}

class _StepDailyMinutesState extends ConsumerState<StepDailyMinutes> {
  int _lastTickedValue = -1;

  static String _label(int minutes) {
    if (minutes <= 15) return 'Лёгкий старт';
    if (minutes <= 30) return 'Золотая середина';
    if (minutes <= 60) return 'Серьёзный подход';
    if (minutes <= 90) return 'Амбициозно';
    return 'Максимум';
  }

  static String _sublabel(int minutes) {
    if (minutes <= 15) return 'Одна задача. Каждый день.';
    if (minutes <= 30) return 'Три задачи. Этого достаточно.';
    if (minutes <= 60) return 'Время для реального прогресса.';
    if (minutes <= 90) return 'Требует отдачи. Система требует тоже.';
    return 'Не обещай больше, чем сделаешь.';
  }

  @override
  Widget build(BuildContext context) {
    final minutes = ref.watch(onboardingNotifierProvider).dailyMinutes;

    return StepShell(
      chapter: '07',
      title: 'Сколько минут в день?',
      subtitle:
          'Будь честен. Лучше 15 минут каждый день, чем 2 часа раз в неделю.',
      scrollable: false,
      footer: const StepQuote('Дисциплина — свобода в миниатюре.'),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Giant numeric display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                child: child,
              ),
            ),
            child: Row(
              key: ValueKey(minutes),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$minutes',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 84,
                    height: 1.0,
                    color: AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    'мин',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              _label(minutes),
              key: ValueKey(_label(minutes)),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              _sublabel(minutes),
              key: ValueKey(_sublabel(minutes)),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Cinematic slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.textPrimary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.textPrimary,
              overlayColor: AppColors.textPrimary.withValues(alpha: 0.08),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
              activeTickMarkColor: AppColors.textPrimary,
              inactiveTickMarkColor: AppColors.divider,
            ),
            child: Slider(
              value: minutes.toDouble(),
              min: 15,
              max: 120,
              divisions: 7,
              onChanged: (v) {
                final rounded = v.round();
                if (rounded != _lastTickedValue) {
                  HapticFeedback.selectionClick();
                  _lastTickedValue = rounded;
                }
                ref
                    .read(onboardingNotifierProvider.notifier)
                    .setDailyMinutes(rounded);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '15 мин',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  '2 часа',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                    letterSpacing: 0.4,
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
