import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/quest_model.dart';
import '../../../dashboard/presentation/providers/quest_provider.dart';
import '../widgets/journey_map.dart';
import '../widgets/places_section.dart';

class LifeMapPage extends ConsumerWidget {
  const LifeMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests =
        ref.watch(questNotifierProvider).valueOrNull ?? const <Quest>[];
    const total = 5;
    final completed = quests
        .where((quest) => quest.status == QuestStatus.completed)
        .length
        .clamp(0, total);
    final progress = completed / total;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _MapHeader(
                completed: completed,
                total: total,
                progress: progress,
              ),
            ),
            SliverToBoxAdapter(child: JourneyMap(completed: completed)),
            const SliverToBoxAdapter(child: PlacesSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final chapter = _weekOfYear(DateTime.now()).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ГЛАВА $chapter  /  НЕДЕЛЯ',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Точка опоры',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '$completed из $total узлов пройдено',
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  int _weekOfYear(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    return ((dayOfYear - 1) / 7).floor() + 1;
  }
}
