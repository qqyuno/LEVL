import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/quest_model.dart';
import '../../domain/weekly_recap.dart';

class WeeklyRecapContent extends StatelessWidget {
  const WeeklyRecapContent({
    super.key,
    required this.recap,
    required this.onPrimaryAction,
  });

  final WeeklyRecap recap;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final sphere = recap.strongestSphere;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ПОСЛЕДНИЕ 7 ДНЕЙ',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _title,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 34,
                  height: 1.02,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${recap.verifiedActions}',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 74,
                      height: 0.9,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        _actionLabel(recap.verifiedActions),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _RouteProgress(reached: recap.routeNodes),
              const SizedBox(height: 26),
              Container(height: 1, color: AppColors.divider),
              SizedBox(
                height: 88,
                child: Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        value: '${recap.activeDays}',
                        label: 'АКТИВНЫХ ДНЕЙ',
                      ),
                    ),
                    Container(width: 1, height: 42, color: AppColors.divider),
                    Expanded(
                      child: _Metric(
                        value: '${recap.routeNodes}/5',
                        label: 'УЗЛОВ ПУТИ',
                      ),
                    ),
                    Container(width: 1, height: 42, color: AppColors.divider),
                    Expanded(
                      child: _Metric(
                        icon: sphere?.icon,
                        iconColor: sphere?.color,
                        value: sphere?.label ?? 'Нет',
                        label: 'СИЛЬНАЯ СФЕРА',
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.divider),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 3, height: 64, color: AppColors.gold),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'НАБЛЮДЕНИЕ СИСТЕМЫ',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDisabled,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          recap.observation,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            height: 1.45,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: onPrimaryAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(_actionIcon, size: 18),
                  label: Text(
                    _actionText,
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _title => switch (recap.state) {
        WeeklyRecapState.empty => 'Неделя начинается с одного шага',
        WeeklyRecapState.inProgress => 'Из действий складывается направление',
        WeeklyRecapState.complete => 'Маршрут недели собран',
      };

  String get _actionText => recap.state == WeeklyRecapState.complete
      ? 'Открыть карту'
      : 'Перейти к действию';

  IconData get _actionIcon => recap.state == WeeklyRecapState.complete
      ? Icons.map_outlined
      : Icons.arrow_forward_rounded;
}

class _RouteProgress extends StatelessWidget {
  const _RouteProgress({required this.reached});

  final int reached;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 2, color: AppColors.divider),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (reached / WeeklyRecap.routeLength).clamp(0, 1),
              child: Container(height: 3, color: AppColors.gold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(WeeklyRecap.routeLength, (index) {
              final complete = index < reached;
              return Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: complete ? AppColors.gold : AppColors.background,
                  border: Border.all(
                    width: 2,
                    color: complete ? AppColors.gold : AppColors.divider,
                  ),
                ),
                child: Icon(
                  complete ? Icons.check_rounded : Icons.circle_outlined,
                  size: complete ? 15 : 7,
                  color: complete ? AppColors.surface : AppColors.textDisabled,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: iconColor),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 8,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

String _actionLabel(int value) {
  final mod100 = value % 100;
  final String word;
  if (mod100 >= 11 && mod100 <= 14) {
    word = 'подтверждённых действий';
  } else {
    word = switch (value % 10) {
      1 => 'подтверждённое действие',
      2 || 3 || 4 => 'подтверждённых действия',
      _ => 'подтверждённых действий',
    };
  }
  return word;
}
