import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'step_shell.dart';

/// Step 1: Где ты сейчас?
class StepLifeContext extends ConsumerStatefulWidget {
  const StepLifeContext({super.key});

  @override
  ConsumerState<StepLifeContext> createState() => _StepLifeContextState();
}

class _StepLifeContextState extends ConsumerState<StepLifeContext> {
  static const _maxLength = 500;
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(onboardingNotifierProvider).lifeContext;
    final length = value.length;

    return StepShell(
      chapter: '01',
      title: 'Где ты сейчас?',
      subtitle: 'Работа, учёба, рутина. Что держит тебя в этой точке.',
      footer: const StepQuote('Честность — отправная точка.'),
      child: _ContextField(
        focus: _focus,
        initialValue: value,
        length: length,
        maxLength: _maxLength,
        onChanged: (v) => ref
            .read(onboardingNotifierProvider.notifier)
            .setLifeContext(v),
      ),
    );
  }
}

class _ContextField extends StatefulWidget {
  final FocusNode focus;
  final String initialValue;
  final int length;
  final int maxLength;
  final ValueChanged<String> onChanged;

  const _ContextField({
    required this.focus,
    required this.initialValue,
    required this.length,
    required this.maxLength,
    required this.onChanged,
  });

  @override
  State<_ContextField> createState() => _ContextFieldState();
}

class _ContextFieldState extends State<_ContextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.focus,
      builder: (context, _) {
        final focused = widget.focus.hasFocus;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: focused
                      ? AppColors.textPrimary
                      : AppColors.divider,
                  width: focused ? 1.2 : 1,
                ),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _ctrl,
                    focusNode: widget.focus,
                    maxLines: 6,
                    minLines: 4,
                    maxLength: widget.maxLength,
                    textInputAction: TextInputAction.newline,
                    onChanged: widget.onChanged,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.55,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Работаю дизайнером. Устал от рутины. Хочу вырасти, но не знаю с чего начать…',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.textDisabled,
                        height: 1.55,
                      ),
                      counterText: '',
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        widget.length >= 3
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 14,
                        color: widget.length >= 3
                            ? AppColors.success
                            : AppColors.textDisabled,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.length >= 3 ? 'Система услышала' : 'Минимум 3 символа',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: widget.length >= 3
                              ? AppColors.textSecondary
                              : AppColors.textDisabled,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.length}/${widget.maxLength}',
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
        );
      },
    );
  }
}
