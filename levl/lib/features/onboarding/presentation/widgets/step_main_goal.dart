import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'step_shell.dart';

/// Step 6: Куда через год?
class StepMainGoal extends ConsumerStatefulWidget {
  const StepMainGoal({super.key});

  @override
  ConsumerState<StepMainGoal> createState() => _StepMainGoalState();
}

class _StepMainGoalState extends ConsumerState<StepMainGoal> {
  static const _maxLength = 300;
  final _focus = FocusNode();
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(onboardingNotifierProvider).mainGoal;
    _ctrl = TextEditingController(text: initial);
    _focus.addListener(() => setState(() {}));
    _ctrl.addListener(() {
      ref
          .read(onboardingNotifierProvider.notifier)
          .setMainGoal(_ctrl.text);
      setState(() {}); // refresh counter + status
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final length = _ctrl.text.length;
    final focused = _focus.hasFocus;
    final hasEnough = length >= 3;

    return StepShell(
      chapter: '06',
      title: 'Куда через год?',
      subtitle:
          'Одна главная цель. Не три. Не пять. Самая важная — та, что изменит всё остальное.',
      footer: const StepQuote('Путь в тысячу ли начинается с первого шага.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizon marker
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ГОРИЗОНТ — 12 МЕСЯЦЕВ',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: focused
                    ? AppColors.gold
                    : hasEnough
                        ? AppColors.gold.withValues(alpha: 0.35)
                        : AppColors.divider,
                width: focused ? 1.4 : 1,
              ),
              boxShadow: focused
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  maxLines: 5,
                  minLines: 3,
                  maxLength: _maxLength,
                  textInputAction: TextInputAction.done,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Запустить свой продукт и уволиться с работы.',
                    hintStyle: GoogleFonts.dmSerifDisplay(
                      fontSize: 20,
                      color: AppColors.textDisabled,
                      height: 1.4,
                    ),
                    counterText: '',
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      hasEnough
                          ? Icons.auto_awesome_rounded
                          : Icons.circle_outlined,
                      size: 14,
                      color: hasEnough
                          ? AppColors.gold
                          : AppColors.textDisabled,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasEnough ? 'Зафиксировано' : 'Минимум 3 символа',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: hasEnough
                            ? AppColors.gold
                            : AppColors.textDisabled,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$length/$_maxLength',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textDisabled,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
