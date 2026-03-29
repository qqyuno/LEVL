import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

/// Step 4: Куда через год?
class StepMainGoal extends ConsumerWidget {
  const StepMainGoal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Куда через год?',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Опиши главную цель. Одну. Самую важную.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            maxLines: 4,
            maxLength: 300,
            textInputAction: TextInputAction.done,
            onChanged: (v) => ref.read(onboardingNotifierProvider.notifier).setMainGoal(v),
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Запустить свой продукт и уволиться с работы',
              hintStyle: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textDisabled),
              counterStyle: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '«Путь в тысячу ли начинается с первого шага.»',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textDisabled,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
