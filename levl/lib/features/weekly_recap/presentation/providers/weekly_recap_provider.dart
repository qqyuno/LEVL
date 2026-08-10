import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/supabase/isar_service.dart';
import '../../../../shared/models/quest_model.dart';
import '../../domain/weekly_recap.dart';

final weeklyRecapProvider = FutureProvider<WeeklyRecap>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final periodStart = today.subtract(const Duration(days: 6));
  final completed = await isar.questLocals
      .filter()
      .completedAtGreaterThan(periodStart, include: true)
      .findAll();

  return calculateWeeklyRecap(
    completed
        .where(
          (quest) =>
              quest.status == QuestStatus.completed &&
              quest.completedAt != null,
        )
        .map(
          (quest) => WeeklyAction(
            category: quest.category,
            completedAt: quest.completedAt!,
          ),
        ),
    now: now,
  );
});

class ReturnAfterAbsenceNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void show(int missedDays) {
    if (missedDays < 1) return;
    state = missedDays;
  }

  void dismiss() => state = null;
}

final returnAfterAbsenceProvider =
    NotifierProvider<ReturnAfterAbsenceNotifier, int?>(
  ReturnAfterAbsenceNotifier.new,
);
