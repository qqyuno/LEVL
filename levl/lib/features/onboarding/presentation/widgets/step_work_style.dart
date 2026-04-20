import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'step_shell.dart';

/// Step 5: Как ты работаешь?
class StepWorkStyle extends ConsumerWidget {
  const StepWorkStyle({super.key});

  static const _styles = <_WorkStyleOption>[
    _WorkStyleOption(
      key: 'sprinter',
      title: 'Спринтер',
      description: 'Короткие мощные рывки. Интенсивно, потом отдых.',
      icon: Icons.bolt_rounded,
    ),
    _WorkStyleOption(
      key: 'marathon',
      title: 'Марафонец',
      description: 'Стабильно, день за днём. Темп важнее скорости.',
      icon: Icons.timeline_rounded,
    ),
    _WorkStyleOption(
      key: 'chaos',
      title: 'Хаотичный',
      description: 'Когда приходит вдохновение — делаю всё сразу.',
      icon: Icons.waves_rounded,
    ),
    _WorkStyleOption(
      key: 'structured',
      title: 'Структурный',
      description: 'По плану. Шаг за шагом. Предсказуемо.',
      icon: Icons.view_agenda_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingNotifierProvider).workStyle;

    return StepShell(
      chapter: '05',
      title: 'Как ты работаешь?',
      subtitle:
          'Система подстроит ритм под твой стиль — не будет заставлять тебя быть тем, кем ты не являешься.',
      child: Column(
        children: _styles.map((style) {
          final isActive = selected == style.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WorkStyleCard(
              option: style,
              isActive: isActive,
              onTap: () {
                HapticFeedback.selectionClick();
                ref
                    .read(onboardingNotifierProvider.notifier)
                    .setWorkStyle(style.key);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WorkStyleOption {
  final String key;
  final String title;
  final String description;
  final IconData icon;

  const _WorkStyleOption({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _WorkStyleCard extends StatelessWidget {
  final _WorkStyleOption option;
  final bool isActive;
  final VoidCallback onTap;

  const _WorkStyleCard({
    required this.option,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.textPrimary : AppColors.divider,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.surface.withValues(alpha: 0.12)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                size: 22,
                color:
                    isActive ? AppColors.surface : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.surface
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isActive
                          ? AppColors.surface.withValues(alpha: 0.7)
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
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.surface : Colors.transparent,
                border: Border.all(
                  color: isActive
                      ? AppColors.surface
                      : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.textPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
