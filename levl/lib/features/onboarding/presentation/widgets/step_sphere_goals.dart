import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'step_shell.dart';

/// Step 4: Цели в выбранных сферах
class StepSphereGoals extends ConsumerStatefulWidget {
  const StepSphereGoals({super.key});

  @override
  ConsumerState<StepSphereGoals> createState() => _StepSphereGoalsState();
}

class _StepSphereGoalsState extends ConsumerState<StepSphereGoals> {
  final _controllers = <String, TextEditingController>{};
  final _focusNodes = <String, FocusNode>{};

  TextEditingController _controllerFor(String key, String initialText) {
    return _controllers.putIfAbsent(key, () {
      final c = TextEditingController(text: initialText);
      c.addListener(() {
        ref.read(onboardingNotifierProvider.notifier).setSphereGoal(key, c.text);
      });
      return c;
    });
  }

  FocusNode _focusFor(String key) {
    return _focusNodes.putIfAbsent(key, () {
      final node = FocusNode();
      node.addListener(() => setState(() {}));
      return node;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingNotifierProvider);
    final selectedSpheres = data.spheres;
    final allSpheres = Sphere.all;

    // Remove controllers for deselected spheres
    _controllers.keys
        .where((k) => !selectedSpheres.contains(k))
        .toList()
        .forEach((k) {
      _controllers[k]!.dispose();
      _controllers.remove(k);
      _focusNodes[k]?.dispose();
      _focusNodes.remove(k);
    });

    return StepShell(
      chapter: '04',
      title: 'Что именно?',
      subtitle:
          'Для каждой сферы — конкретная цель. Коротко. Одно предложение. Оно станет направлением.',
      footer: const StepQuote('Конкретная цель — половина пути.'),
      child: Column(
        children: [
          for (final key in selectedSpheres)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SphereGoalCard(
                sphere: allSpheres.firstWhere((s) => s.key == key),
                controller: _controllerFor(key, data.sphereGoals[key] ?? ''),
                focusNode: _focusFor(key),
                hint: _hintFor(key),
              ),
            ),
        ],
      ),
    );
  }

  static String _hintFor(String key) => switch (key) {
        'discipline' => 'Например: выстроить утренний ритуал',
        'knowledge' => 'Например: прочитать 12 книг за год',
        'relations' => 'Например: ужинать с семьёй без телефона',
        'energy' => 'Например: бегать 3 раза в неделю',
        'will' => 'Например: довести проект до запуска',
        'wisdom' => 'Например: медитировать по 10 минут в день',
        _ => 'Опиши цель',
      };
}

class _SphereGoalCard extends StatelessWidget {
  final Sphere sphere;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;

  const _SphereGoalCard({
    required this.sphere,
    required this.controller,
    required this.focusNode,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    final hasValue = controller.text.trim().length >= 3;
    final color = sphere.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused
              ? color.withValues(alpha: 0.6)
              : hasValue
                  ? color.withValues(alpha: 0.3)
                  : AppColors.divider,
          width: focused ? 1.4 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Left color bar
          Positioned(
            left: 0,
            top: 14,
            bottom: 14,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          sphere.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      sphere.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    if (hasValue)
                      Icon(Icons.check_circle_rounded,
                          size: 16,
                          color: color.withValues(alpha: 0.8)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: 2,
                  maxLength: 150,
                  textInputAction: TextInputAction.next,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textDisabled,
                      height: 1.4,
                    ),
                    isCollapsed: true,
                    counterText: '',
                    border: InputBorder.none,
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
