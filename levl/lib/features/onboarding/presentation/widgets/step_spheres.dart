import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

/// Step 3: Какие сферы хочешь развить?
class StepSpheres extends ConsumerWidget {
  const StepSpheres({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingNotifierProvider).spheres;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Какие сферы хочешь развить?',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выбери от 2 до 4 направлений. Система построит путь вокруг них.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ...Sphere.all.map((sphere) {
            final isActive = selected.contains(sphere.key);
            final isDisabled = !isActive && selected.length >= 4;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: isDisabled
                    ? null
                    : () => ref.read(onboardingNotifierProvider.notifier).toggleSphere(sphere.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.textPrimary
                        : isDisabled
                            ? AppColors.surface.withValues(alpha: 0.5)
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? AppColors.textPrimary
                          : isDisabled
                              ? AppColors.divider.withValues(alpha: 0.5)
                              : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        sphere.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        sphere.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? AppColors.surface
                              : isDisabled
                                  ? AppColors.textDisabled
                                  : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (isActive)
                        const Icon(Icons.check_rounded, color: AppColors.surface, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${selected.length}/4 выбрано',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
