import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

/// Step 5: Сколько времени в день?
class StepDailyMinutes extends ConsumerWidget {
  const StepDailyMinutes({super.key});

  static String _label(int minutes) {
    if (minutes <= 15) return 'Лёгкий старт';
    if (minutes <= 30) return 'Золотая середина';
    if (minutes <= 60) return 'Серьёзный подход';
    if (minutes <= 90) return 'Амбициозно';
    return 'Максимум';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = ref.watch(onboardingNotifierProvider).dailyMinutes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Сколько времени в день?',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Сколько минут ты готов уделять задачам. Честно.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

          // Minutes display
          Center(
            child: Text(
              '$minutes мин',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 48,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _label(minutes),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.textPrimary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.textPrimary,
              overlayColor: AppColors.textPrimary.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: minutes.toDouble(),
              min: 15,
              max: 120,
              divisions: 7,
              onChanged: (v) {
                ref.read(onboardingNotifierProvider.notifier).setDailyMinutes(v.round());
              },
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15 мин', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textDisabled)),
              Text('2 часа', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textDisabled)),
            ],
          ),

          const SizedBox(height: 48),
          Center(
            child: Text(
              '«Три задачи. Этого достаточно.»',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
