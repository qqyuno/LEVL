import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

/// Step 4: Цели в выбранных сферах
class StepSphereGoals extends ConsumerStatefulWidget {
  const StepSphereGoals({super.key});

  @override
  ConsumerState<StepSphereGoals> createState() => _StepSphereGoalsState();
}

class _StepSphereGoalsState extends ConsumerState<StepSphereGoals> {
  final _controllers = <String, TextEditingController>{};

  TextEditingController _controllerFor(String key, String initialText) {
    return _controllers.putIfAbsent(key, () {
      final c = TextEditingController(text: initialText);
      c.addListener(() {
        ref.read(onboardingNotifierProvider.notifier).setSphereGoal(key, c.text);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingNotifierProvider);
    final selectedSpheres = data.spheres;
    const allSpheres = Sphere.all;

    // Remove controllers for deselected spheres
    _controllers.keys
        .where((k) => !selectedSpheres.contains(k))
        .toList()
        .forEach((k) {
      _controllers[k]!.dispose();
      _controllers.remove(k);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Цели в сферах',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Чего хочешь достичь в каждой сфере? Коротко и честно.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ...selectedSpheres.map((key) {
            final sphere = allSpheres.firstWhere((s) => s.key == key);
            final controller = _controllerFor(key, data.sphereGoals[key] ?? '');
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(sphere.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        sphere.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 2,
                    maxLength: 150,
                    textInputAction: TextInputAction.next,
                    controller: controller,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: _hintFor(key),
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 14, color: AppColors.textDisabled),
                      counterStyle: GoogleFonts.dmSans(
                          fontSize: 11, color: AppColors.textDisabled),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '«Конкретная цель — половина пути.»',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _hintFor(String key) => switch (key) {
        'discipline' => 'Выстроить утренний ритуал',
        'knowledge' => 'Прочитать 12 книг за год',
        'relations' => 'Проводить больше времени с семьёй',
        'energy' => 'Бегать 3 раза в неделю',
        'will' => 'Довести проект до конца',
        'wisdom' => 'Медитировать каждый день',
        _ => 'Опиши цель',
      };
}
