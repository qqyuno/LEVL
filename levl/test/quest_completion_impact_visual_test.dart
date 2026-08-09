import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levl/features/dashboard/presentation/widgets/quest_completion_impact_sheet.dart';
import 'package:levl/shared/models/avatar_config.dart';
import 'package:levl/shared/models/quest_model.dart';

void main() {
  testWidgets('renders completion impact on a mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: QuestCompletionImpactSheet(
            quest: Quest(
              id: 'preview',
              userId: 'preview',
              title: 'Провести 25 минут без отвлечений',
              description: 'Закрыть один конкретный этап основной цели.',
              tip: '',
              xpReward: 45,
              category: QuestCategory.will,
              createdAt: DateTime(2026, 8, 9),
            ),
            completedBefore: 2,
            avatarConfig: const AvatarConfig(hair: 2, hairColor: 0),
            level: 4,
            streak: 6,
            animateAvatar: false,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('СЛЕД ЗАФИКСИРОВАН'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
    expect(find.text('Посмотреть карту'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
