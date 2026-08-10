import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levl/features/weekly_recap/domain/weekly_recap.dart';
import 'package:levl/features/weekly_recap/presentation/widgets/weekly_recap_content.dart';
import 'package:levl/shared/models/quest_model.dart';

void main() {
  testWidgets('renders all weekly recap states on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final recap in _states) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyRecapContent(
              recap: recap,
              onPrimaryAction: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('ПОСЛЕДНИЕ 7 ДНЕЙ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

const _states = [
  WeeklyRecap(
    state: WeeklyRecapState.empty,
    verifiedActions: 0,
    activeDays: 0,
    routeNodes: 0,
    strongestSphere: null,
    observation: 'Одного действия достаточно, чтобы появился первый след.',
  ),
  WeeklyRecap(
    state: WeeklyRecapState.inProgress,
    verifiedActions: 3,
    activeDays: 2,
    routeNodes: 3,
    strongestSphere: QuestCategory.energy,
    observation: 'Ритм уже виден. Сохрани направление.',
  ),
  WeeklyRecap(
    state: WeeklyRecapState.complete,
    verifiedActions: 7,
    activeDays: 5,
    routeNodes: 5,
    strongestSphere: QuestCategory.discipline,
    observation: 'Маршрут собран и готов к продолжению.',
  ),
];
