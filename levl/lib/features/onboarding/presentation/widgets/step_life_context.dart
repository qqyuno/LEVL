import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

/// Step 1: Где ты сейчас?
class StepLifeContext extends ConsumerWidget {
  const StepLifeContext({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Где ты сейчас?',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Опиши свою текущую ситуацию. Работа, учёба, рутина — всё что важно.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            maxLines: 5,
            maxLength: 500,
            textInputAction: TextInputAction.done,
            onChanged: (v) => ref.read(onboardingNotifierProvider.notifier).setLifeContext(v),
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Работаю дизайнером, устал от рутины...',
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
        ],
      ),
    );
  }
}
