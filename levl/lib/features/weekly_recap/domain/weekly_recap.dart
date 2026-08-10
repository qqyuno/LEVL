import '../../../shared/models/quest_model.dart';

enum WeeklyRecapState { empty, inProgress, complete }

class WeeklyAction {
  const WeeklyAction({
    required this.category,
    required this.completedAt,
  });

  final QuestCategory category;
  final DateTime completedAt;
}

class WeeklyRecap {
  const WeeklyRecap({
    required this.state,
    required this.verifiedActions,
    required this.activeDays,
    required this.routeNodes,
    required this.strongestSphere,
    required this.observation,
  });

  static const routeLength = 5;

  final WeeklyRecapState state;
  final int verifiedActions;
  final int activeDays;
  final int routeNodes;
  final QuestCategory? strongestSphere;
  final String observation;
}

WeeklyRecap calculateWeeklyRecap(
  Iterable<WeeklyAction> actions, {
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final periodStart = today.subtract(const Duration(days: 6));
  final periodEnd = today.add(const Duration(days: 1));
  final recent = actions
      .where(
        (action) =>
            !action.completedAt.isBefore(periodStart) &&
            action.completedAt.isBefore(periodEnd),
      )
      .toList();

  final categoryCounts = <QuestCategory, int>{};
  final activeDays = <DateTime>{};
  for (final action in recent) {
    categoryCounts.update(
      action.category,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    final date = action.completedAt;
    activeDays.add(DateTime(date.year, date.month, date.day));
  }

  QuestCategory? strongestSphere;
  var strongestCount = 0;
  for (final category in QuestCategory.values) {
    final count = categoryCounts[category] ?? 0;
    if (count > strongestCount) {
      strongestSphere = category;
      strongestCount = count;
    }
  }

  final verified = recent.length;
  final nodes = verified.clamp(0, WeeklyRecap.routeLength);
  final state = switch (verified) {
    0 => WeeklyRecapState.empty,
    >= WeeklyRecap.routeLength => WeeklyRecapState.complete,
    _ => WeeklyRecapState.inProgress,
  };
  final observation = switch (state) {
    WeeklyRecapState.empty =>
      'Неделя ещё не требует итогов. Одного подтверждённого действия достаточно, чтобы появился первый след.',
    WeeklyRecapState.inProgress =>
      'Ритм уже виден: ${activeDays.length} ${_dayWord(activeDays.length)} с реальными действиями. Не ускоряйся, сохрани направление.',
    WeeklyRecapState.complete =>
      'Маршрут собран. Пять подтверждённых действий уже показывают изменение, которое можно продолжить на следующей неделе.',
  };

  return WeeklyRecap(
    state: state,
    verifiedActions: verified,
    activeDays: activeDays.length,
    routeNodes: nodes,
    strongestSphere: strongestSphere,
    observation: observation,
  );
}

String _dayWord(int value) {
  final mod100 = value % 100;
  if (mod100 >= 11 && mod100 <= 14) return 'дней';
  return switch (value % 10) {
    1 => 'день',
    2 || 3 || 4 => 'дня',
    _ => 'дней',
  };
}
