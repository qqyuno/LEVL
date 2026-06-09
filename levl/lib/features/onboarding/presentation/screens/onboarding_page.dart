import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/step_life_context.dart';
import '../widgets/step_pain_points.dart';
import '../widgets/step_spheres.dart';
import '../widgets/step_sphere_goals.dart';
import '../widgets/step_work_style.dart';
import '../widgets/step_main_goal.dart';
import '../widgets/step_daily_minutes.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _currentStep = 0;
  bool _saving = false;
  static const _totalSteps = 7;

  void _next() {
    final data = ref.read(onboardingNotifierProvider);
    if (!data.canProceed(_currentStep)) {
      _showValidationHint();
      return;
    }

    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();

    if (_currentStep < _totalSteps - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      HapticFeedback.selectionClick();
      FocusScope.of(context).unfocus();
      _controller.previousPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    }
  }

  void _showValidationHint() {
    HapticFeedback.lightImpact();
    final messages = [
      'Расскажи немного о себе',
      'Выбери хотя бы одно',
      'Выбери от 2 до 4 сфер',
      'Напиши цель для каждой сферы',
      'Выбери стиль работы',
      'Напиши свою цель',
      '',
    ];
    if (messages[_currentStep].isEmpty) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          messages[_currentStep],
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _finish() async {
    HapticFeedback.mediumImpact();
    final acceptedPrivacy = await _showPrivacyConsent();
    if (!acceptedPrivacy || !mounted) return;

    setState(() => _saving = true);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final error = await notifier.saveProfile();

    if (!mounted) return;

    if (error != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.dmSans(fontSize: 14)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(onboardingCompleteProvider.notifier).markComplete();
    await _showActivationSheet(ref.read(onboardingNotifierProvider));
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  Future<bool> _showPrivacyConsent() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Данные для персонализации',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'LEVL сохранит твои ответы, цели и прогресс, чтобы собрать персональные задачи и работу AI-наставника. Не вводи медицинские, финансовые, паспортные данные, пароли или seed-фразы.',
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Назад',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Понятно',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );

    return accepted ?? false;
  }

  Future<void> _showActivationSheet(OnboardingData data) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => _ActivationSheet(data: data),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingNotifierProvider);
    final canProceed = data.canProceed(_currentStep);
    final isFinal = _currentStep == _totalSteps - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- Segmented progress ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  _BackButton(
                    visible: _currentStep > 0,
                    onTap: _back,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: _SegmentedProgress(
                    total: _totalSteps,
                    current: _currentStep,
                  )),
                ],
              ),
            ),

            // --- Steps ---
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StepLifeContext(),
                  StepPainPoints(),
                  StepSpheres(),
                  StepSphereGoals(),
                  StepWorkStyle(),
                  StepMainGoal(),
                  StepDailyMinutes(),
                ],
              ),
            ),

            // --- Next button ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: _NextButton(
                label: isFinal ? 'Начать путь' : 'Далее',
                enabled: canProceed && !_saving,
                loading: _saving,
                isFinal: isFinal,
                onTap: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivationSheet extends StatelessWidget {
  final OnboardingData data;
  const _ActivationSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    final sphereLabels = data.spheres
        .map(_sphereLabel)
        .where((label) => label.isNotEmpty)
        .join(' / ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'СИСТЕМА СОБРАНА',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 2.6,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Твой первый день уже можно открыть.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 25,
                  color: AppColors.textPrimary,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Система будет давать три действия в день: коротко, по делу, с учетом цели и ресурса.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              _ReadoutRow(
                icon: Icons.stars_rounded,
                label: 'Цель',
                value: data.mainGoal,
                highlight: true,
              ),
              const SizedBox(height: 10),
              _ReadoutRow(
                icon: Icons.track_changes_rounded,
                label: 'Фокус',
                value: sphereLabels.isEmpty
                    ? 'Путь будет уточняться'
                    : sphereLabels,
              ),
              const SizedBox(height: 10),
              _ReadoutRow(
                icon: Icons.timer_outlined,
                label: 'Ресурс',
                value: '${data.dailyMinutes} минут в день',
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Открыть первый день',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _sphereLabel(String key) {
    for (final sphere in Sphere.all) {
      if (sphere.key == key) return sphere.label;
    }
    return '';
  }
}

class _ReadoutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _ReadoutRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.gold.withValues(alpha: 0.08)
            : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? AppColors.gold.withValues(alpha: 0.22)
              : AppColors.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: highlight ? AppColors.gold : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDisabled,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Segmented progress bar — 7 rounded dashes. Active step is bold, prior filled.
// ---------------------------------------------------------------------------
class _SegmentedProgress extends StatelessWidget {
  final int total;
  final int current;
  const _SegmentedProgress({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isPast = i < current;
        final isActive = i == current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              height: isActive ? 4 : 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive
                    ? AppColors.textPrimary
                    : isPast
                        ? AppColors.textPrimary.withValues(alpha: 0.55)
                        : AppColors.divider,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Back button with smooth fade
// ---------------------------------------------------------------------------
class _BackButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;
  const _BackButton({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !visible,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Next button — subtle gold flash on final step
// ---------------------------------------------------------------------------
class _NextButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final bool isFinal;
  final VoidCallback onTap;

  const _NextButton({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.isFinal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isFinal
        ? AppColors.gold
        : enabled
            ? AppColors.textPrimary
            : AppColors.textPrimary.withValues(alpha: 0.35);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isFinal && enabled
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onTap : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.surface,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isFinal
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: isFinal ? 18 : 14,
                          color: AppColors.surface,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
