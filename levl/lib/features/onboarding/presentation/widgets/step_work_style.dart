import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

/// Step 3: Как ты работаешь?
class StepWorkStyle extends ConsumerWidget {
  const StepWorkStyle({super.key});

  static const _styles = {
    'sprinter': 'Спринтер — короткие мощные рывки',
    'marathon': 'Марафонец — стабильно и долго',
    'chaos': 'Хаотичный — когда приходит вдохновение',
    'structured': 'Структурный — по плану, шаг за шагом',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingNotifierProvider).workStyle;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Как ты работаешь?',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выбери стиль, который больше похож на тебя.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ..._styles.entries.map((e) {
            final isActive = selected == e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => ref.read(onboardingNotifierProvider.notifier).setWorkStyle(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.textPrimary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? AppColors.textPrimary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    e.value,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.surface : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
