import 'package:flutter_test/flutter_test.dart';
import 'package:levl/features/weekly_recap/domain/weekly_recap.dart';
import 'package:levl/shared/models/quest_model.dart';

void main() {
  final now = DateTime(2026, 8, 10, 18);

  test('builds an intentional empty week', () {
    final recap = calculateWeeklyRecap(const [], now: now);

    expect(recap.state, WeeklyRecapState.empty);
    expect(recap.verifiedActions, 0);
    expect(recap.routeNodes, 0);
    expect(recap.strongestSphere, isNull);
  });

  test('summarizes an in-progress week and strongest sphere', () {
    final recap = calculateWeeklyRecap([
      WeeklyAction(category: QuestCategory.energy, completedAt: now),
      WeeklyAction(
        category: QuestCategory.energy,
        completedAt: now.subtract(const Duration(days: 1)),
      ),
      WeeklyAction(
        category: QuestCategory.knowledge,
        completedAt: now.subtract(const Duration(days: 1)),
      ),
      WeeklyAction(
        category: QuestCategory.will,
        completedAt: now.subtract(const Duration(days: 8)),
      ),
    ], now: now);

    expect(recap.state, WeeklyRecapState.inProgress);
    expect(recap.verifiedActions, 3);
    expect(recap.activeDays, 2);
    expect(recap.strongestSphere, QuestCategory.energy);
  });

  test('caps a complete route at five nodes', () {
    final recap = calculateWeeklyRecap(
      List.generate(
        7,
        (index) => WeeklyAction(
          category: QuestCategory.discipline,
          completedAt: now.subtract(Duration(days: index % 4)),
        ),
      ),
      now: now,
    );

    expect(recap.state, WeeklyRecapState.complete);
    expect(recap.verifiedActions, 7);
    expect(recap.routeNodes, WeeklyRecap.routeLength);
  });
}
