import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'step_shell.dart';

/// Step 2: Что тормозит?
class StepPainPoints extends ConsumerWidget {
  const StepPainPoints({super.key});

  static const _options = <_PainOption>[
    _PainOption('Прокрастинация', Icons.schedule_rounded),
    _PainOption('Нет энергии', Icons.battery_0_bar_rounded),
    _PainOption('Нет плана', Icons.map_outlined),
    _PainOption('Отвлекаюсь', Icons.blur_on_rounded),
    _PainOption('Перфекционизм', Icons.tune_rounded),
    _PainOption('Одиночество', Icons.person_outline_rounded),
    _PainOption('Стресс', Icons.cloud_outlined),
    _PainOption('Нет мотивации', Icons.bolt_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final selected = data.painPoints.isEmpty
        ? <String>{}
        : data.painPoints.split(', ').toSet();

    void toggle(String option) {
      HapticFeedback.selectionClick();
      final updated = Set<String>.from(selected);
      if (updated.contains(option)) {
        updated.remove(option);
      } else {
        updated.add(option);
      }
      ref
          .read(onboardingNotifierProvider.notifier)
          .setPainPoints(updated.join(', '));
    }

    return StepShell(
      chapter: '02',
      title: 'Что тормозит?',
      subtitle:
          'Выбери честно — Система использует это, чтобы не ставить задачи, которые ты не начнёшь.',
      footer: Text(
        selected.isEmpty
            ? 'Выбери хотя бы одно'
            : '${selected.length} выбрано',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _options.map((opt) {
          final active = selected.contains(opt.label);
          return _PainChip(
            option: opt,
            active: active,
            onTap: () => toggle(opt.label),
          );
        }).toList(),
      ),
    );
  }
}

class _PainOption {
  final String label;
  final IconData icon;
  const _PainOption(this.label, this.icon);
}

class _PainChip extends StatelessWidget {
  final _PainOption option;
  final bool active;
  final VoidCallback onTap;

  const _PainChip({
    required this.option,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? AppColors.textPrimary : AppColors.divider,
            width: 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 15,
              color: active ? AppColors.surface : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: active ? AppColors.surface : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
