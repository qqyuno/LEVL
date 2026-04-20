import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'step_shell.dart';

class StepSpheres extends ConsumerWidget {
  const StepSpheres({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingNotifierProvider).spheres;

    return StepShell(
      chapter: '03',
      title: 'Что будешь развивать?',
      subtitle:
          'От 2 до 4 сфер. Система сфокусирует задачи вокруг них — и не распылит.',
      footer: Text(
        selected.isEmpty
            ? 'Минимум 2'
            : selected.length < 2
                ? 'Ещё одна'
                : '${selected.length}/4 выбрано',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          color: selected.length >= 2
              ? AppColors.textSecondary
              : AppColors.textDisabled,
          letterSpacing: 0.3,
        ),
      ),
      child: Column(
        children: List.generate(Sphere.all.length, (i) {
          final sphere = Sphere.all[i];
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
                  : () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(onboardingNotifierProvider.notifier)
                          .toggleSphere(sphere.key);
                    },
            ),
          );
        }),
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
        duration: const Duration(milliseconds: 200),
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
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
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
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
