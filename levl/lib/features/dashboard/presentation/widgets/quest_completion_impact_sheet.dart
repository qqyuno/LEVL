import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/avatar_config.dart';
import '../../../../shared/models/quest_model.dart';
import '../../../../shared/widgets/premium_face_avatar_widget.dart';

Future<bool?> showQuestCompletionImpact(
  BuildContext context, {
  required Quest quest,
  required int completedBefore,
  required AvatarConfig avatarConfig,
  required int level,
  required int streak,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    barrierColor: AppColors.textPrimary.withValues(alpha: 0.28),
    builder: (_) => QuestCompletionImpactSheet(
      quest: quest,
      completedBefore: completedBefore,
      avatarConfig: avatarConfig,
      level: level,
      streak: streak,
    ),
  );
}

class QuestCompletionImpactSheet extends StatelessWidget {
  const QuestCompletionImpactSheet({
    super.key,
    required this.quest,
    required this.completedBefore,
    required this.avatarConfig,
    required this.level,
    required this.streak,
    this.animateAvatar = true,
  });

  static const totalRouteNodes = 5;

  final Quest quest;
  final int completedBefore;
  final AvatarConfig avatarConfig;
  final int level;
  final int streak;
  final bool animateAvatar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completedAfter = (completedBefore + 1).clamp(0, totalRouteNodes);
    final sphereGain = (quest.xpReward / 3).round().clamp(3, 67);
    final routeFinished = completedAfter >= totalRouteNodes;
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'СЛЕД ЗАФИКСИРОВАН',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Закрыть',
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  quest.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    height: 1.08,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 22),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.94, end: 1),
                  duration: animationsDisabled
                      ? Duration.zero
                      : const Duration(milliseconds: 520),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    alignment: Alignment.centerLeft,
                    child: child,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PremiumFaceAvatarWidget(
                        config: avatarConfig,
                        size: 118,
                        level: level,
                        streak: streak,
                        compact: true,
                        animate: animateAvatar,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ImpactLine(
                              icon: quest.category.icon,
                              color: quest.category.color,
                              label: quest.category.label,
                              value: '+$sphereGain',
                            ),
                            const SizedBox(height: 14),
                            _ImpactLine(
                              icon: Icons.bolt_rounded,
                              color: AppColors.gold,
                              label: 'Опыт',
                              value: '+${quest.xpReward} XP',
                            ),
                            const SizedBox(height: 14),
                            _ImpactLine(
                              icon: Icons.route_rounded,
                              color: AppColors.textPrimary,
                              label: 'Маршрут',
                              value: '$completedAfter/$totalRouteNodes',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  routeFinished ? 'СКРЫТЫЙ УЗЕЛ ОТКРЫТ' : 'МАРШРУТ НЕДЕЛИ',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: routeFinished
                        ? AppColors.gold
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _RouteProgress(
                  completedBefore: completedBefore,
                  completedAfter: completedAfter,
                  animationsDisabled: animationsDisabled,
                ),
                const SizedBox(height: 12),
                Text(
                  routeFinished
                      ? 'Пять подтверждённых действий собрали маршрут целиком.'
                      : 'Ещё одно реальное действие стало частью твоего пути.',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: Text(
                      'Посмотреть карту',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Продолжить день'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactLine extends StatelessWidget {
  const _ImpactLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RouteProgress extends StatelessWidget {
  const _RouteProgress({
    required this.completedBefore,
    required this.completedAfter,
    required this.animationsDisabled,
  });

  final int completedBefore;
  final int completedAfter;
  final bool animationsDisabled;

  @override
  Widget build(BuildContext context) {
    final before = completedBefore.clamp(
      0,
      QuestCompletionImpactSheet.totalRouteNodes,
    );
    final after = completedAfter.clamp(
      0,
      QuestCompletionImpactSheet.totalRouteNodes,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: before.toDouble(), end: after.toDouble()),
      duration: animationsDisabled
          ? Duration.zero
          : const Duration(milliseconds: 760),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final progress = (value / QuestCompletionImpactSheet.totalRouteNodes)
            .clamp(0.0, 1.0);
        return SizedBox(
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 2, color: AppColors.divider),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 3, color: AppColors.gold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  QuestCompletionImpactSheet.totalRouteNodes,
                  (index) {
                    final reached = value >= index + 1;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: reached ? AppColors.gold : AppColors.background,
                        border: Border.all(
                          color: reached ? AppColors.gold : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        reached ? Icons.check_rounded : Icons.circle_outlined,
                        size: reached ? 15 : 8,
                        color: reached
                            ? AppColors.surface
                            : AppColors.textDisabled,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
