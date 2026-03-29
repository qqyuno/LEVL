import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/step_life_context.dart';
import '../widgets/step_pain_points.dart';
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
  static const _totalSteps = 5;

  void _next() {
    final data = ref.read(onboardingNotifierProvider);
    if (!data.canProceed(_currentStep)) {
      _showValidationHint();
      return;
    }

    // Dismiss keyboard before page transition
    FocusScope.of(context).unfocus();

    if (_currentStep < _totalSteps - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      FocusScope.of(context).unfocus();
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _showValidationHint() {
    final messages = [
      'Расскажи немного о себе',
      'Выбери хотя бы одно',
      'Выбери стиль работы',
      'Напиши свою цель',
      '',
    ];
    if (messages[_currentStep].isEmpty) return;

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
    context.go(AppRoutes.dashboard);
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
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Progress bar + back button ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _currentStep > 0 ? _back : null,
                    child: AnimatedOpacity(
                      opacity: _currentStep > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.arrow_back_ios,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation(AppColors.textPrimary),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentStep + 1}/$_totalSteps',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
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
                  StepWorkStyle(),
                  StepMainGoal(),
                  StepDailyMinutes(),
                ],
              ),
            ),

            // --- Next button ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedOpacity(
                  opacity: canProceed ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _saving ? null : _next,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? 'Начать путь'
                                : 'Далее',
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
