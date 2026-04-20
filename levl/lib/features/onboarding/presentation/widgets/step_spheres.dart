import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

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
            'Что хочешь развить?',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выбери от 2 до 4 сфер. Система сфокусирует задачи на них.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ...Sphere.all.map((sphere) {
            final isActive = selected.contains(sphere.key);
            final isDisabled = !isActive && selected.length >= 4;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SphereCard(
                sphere: sphere,
                isActive: isActive,
                isDisabled: isDisabled,
                onTap: isDisabled
                    ? null
                    : () => ref
                        .read(onboardingNotifierProvider.notifier)
                        .toggleSphere(sphere.key),
              ),
            );
          }),
          const SizedBox(height: 12),
          Center(
            child: Text(
              selected.isEmpty
                  ? 'Выбери минимум 2'
                  : '${selected.length}/4 выбрано',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: selected.isEmpty
                    ? AppColors.textDisabled
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SphereCard extends StatelessWidget {
  final Sphere sphere;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _SphereCard({
    required this.sphere,
    required this.isActive,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = sphere.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.08)
              : isDisabled
                  ? AppColors.surface.withValues(alpha: 0.5)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.5)
                : isDisabled
                    ? AppColors.divider.withValues(alpha: 0.4)
                    : AppColors.divider,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Цветной иконка-бейдж
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.15)
                    : isDisabled
                        ? AppColors.divider.withValues(alpha: 0.5)
                        : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  sphere.icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: isDisabled ? null : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Название + описание
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sphere.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? color
                          : isDisabled
                              ? AppColors.textDisabled
                              : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sphere.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isDisabled
                          ? AppColors.textDisabled
                          : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Чекбокс
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color : Colors.transparent,
                border: Border.all(
                  color: isActive
                      ? color
                      : isDisabled
                          ? AppColors.divider.withValues(alpha: 0.4)
                          : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
