import 'package:flutter_test/flutter_test.dart';
import 'package:levl/shared/models/quest_model.dart';

Quest _quest({
  QuestVerificationType verificationType = QuestVerificationType.selfConfirm,
  QuestVerificationStatus verificationStatus =
      QuestVerificationStatus.notStarted,
  DateTime? verificationStartedAt,
  int estimatedMinutes = 15,
  String successCriterion = 'Готов один конкретный результат.',
}) {
  return Quest(
    id: 'quest-1',
    userId: 'user-1',
    title: 'Сделай следующий шаг',
    description: 'Выполни одно конкретное действие по своей цели.',
    tip: 'Начни с минимальной версии.',
    xpReward: 25,
    estimatedMinutes: estimatedMinutes,
    successCriterion: successCriterion,
    verificationType: verificationType,
    verificationStatus: verificationStatus,
    verificationStartedAt: verificationStartedAt,
    createdAt: DateTime(2026, 7, 16),
  );
}

void main() {
  group('quest verification', () {
    test('uses the persisted Supabase id returned by the edge function', () {
      final quest = Quest.fromEdgeFunction(
        {
          'id': 'server-quest-7',
          'title': 'Сделай следующий шаг',
          'description': 'Выполни одно конкретное действие по своей цели.',
          'tip': 'Начни с минимальной версии.',
          'xpReward': 25,
        },
        '7',
        'user-1',
      );

      expect(quest.id, 'server-quest-7');
    });

    test('self confirmation is ready immediately', () {
      final quest = _quest();

      expect(quest.verificationReadyAt(DateTime(2026, 7, 16)), isTrue);
      expect(
        quest.verificationRemainingAt(DateTime(2026, 7, 16)),
        Duration.zero,
      );
    });

    test('timer cannot complete before it starts', () {
      final quest = _quest(verificationType: QuestVerificationType.timer);

      expect(quest.verificationReadyAt(DateTime(2026, 7, 16)), isFalse);
      expect(
        quest.verificationRemainingAt(DateTime(2026, 7, 16)),
        const Duration(minutes: 15),
      );
    });

    test('timer exposes remaining time while verification is running', () {
      final startedAt = DateTime(2026, 7, 16, 12);
      final quest = _quest(
        verificationType: QuestVerificationType.timer,
        verificationStatus: QuestVerificationStatus.inProgress,
        verificationStartedAt: startedAt,
      );

      expect(
        quest.verificationRemainingAt(
          startedAt.add(const Duration(minutes: 4, seconds: 30)),
        ),
        const Duration(minutes: 10, seconds: 30),
      );
      expect(
        quest.verificationReadyAt(startedAt.add(const Duration(minutes: 14))),
        isFalse,
      );
    });

    test('timer becomes ready only after its full duration', () {
      final startedAt = DateTime(2026, 7, 16, 12);
      final quest = _quest(
        verificationType: QuestVerificationType.timer,
        verificationStatus: QuestVerificationStatus.inProgress,
        verificationStartedAt: startedAt,
        estimatedMinutes: 10,
      );

      expect(
        quest.verificationReadyAt(startedAt.add(const Duration(minutes: 10))),
        isTrue,
      );
      expect(
        quest.verificationRemainingAt(
          startedAt.add(const Duration(minutes: 11)),
        ),
        Duration.zero,
      );
    });

    test('description is used when a legacy quest has no criterion', () {
      final quest = _quest(successCriterion: '');

      expect(
        quest.effectiveSuccessCriterion,
        'Выполни одно конкретное действие по своей цели.',
      );
    });
  });
}
