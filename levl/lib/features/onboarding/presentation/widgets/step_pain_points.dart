import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

/// Step 2: Что тормозит?
class StepPainPoints extends ConsumerWidget {
  const StepPainPoints({super.key});

  static const _options = [
    'Прокрастинация',
    'Нет энергии',
    'Нет плана',
    'Отвлекаюсь',
    'Перфекционизм',
    'Одиночество',
    'Стресс',
    'Нет мотивации',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final selected = data.painPoints.isEmpty
        ? <String>{}
        : data.painPoints.split(', ').toSet();

    void toggle(String option) {
      final updated = Set<String>.from(selected);
      if (updated.contains(option)) {
        updated.remove(option);
      } else {
        updated.add(option);
      }
      ref.read(onboardingNotifierProvider.notifier).setPainPoints(updated.join(', '));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Что тормозит?',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выбери то, что мешает двигаться вперёд. Можно несколько.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _options.map((option) {
              final isActive = selected.contains(option);
              return GestureDetector(
                onTap: () => toggle(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.textPrimary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppColors.textPrimary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    option,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.surface : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
