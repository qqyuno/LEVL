import 'package:flutter_test/flutter_test.dart';
import 'package:levl/shared/models/quest_model.dart';

Quest _quest({
  QuestVerificationType verificationType = QuestVerificationType.selfConfirm,
  QuestVerificationStatus verificationStatus =
      QuestVerificationStatus.notStarted,
  DateTime? verificationStartedAt,
  int estimatedMinutes = 15,
  int verificationMinutes = 0,
  String requiredPlaceType = '',
  int locationChecksPassed = 0,
  DateTime? lastLocationCheckAt,
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
    verificationMinutes: verificationMinutes,
    requiredPlaceType: requiredPlaceType,
    locationChecksPassed: locationChecksPassed,
    lastLocationCheckAt: lastLocationCheckAt,
    verificationStatus: verificationStatus,
    verificationStartedAt: verificationStartedAt,
    createdAt: DateTime(2026, 7, 16),
  );
}

void main() {
  group('quest verification', () {
    test('proof is optional by default', () {
      final quest = _quest();

      expect(quest.proofType, QuestProofType.none);
      expect(quest.proofValue, isEmpty);
      expect(quest.proofStoragePath, isEmpty);
      expect(quest.proofAddedAt, isNull);
    });

    test('copyWith keeps an attached text result', () {
      final addedAt = DateTime(2026, 7, 27, 12);
      final quest = _quest().copyWith(
        proofType: QuestProofType.text,
        proofValue: 'Готов первый экран прототипа',
        proofAddedAt: addedAt,
      );

      expect(quest.proofType, QuestProofType.text);
      expect(quest.proofValue, 'Готов первый экран прототипа');
      expect(quest.proofAddedAt, addedAt);
    });

    test('uses the persisted Supabase id returned by the edge function', () {
      final quest = Quest.fromEdgeFunction(
        {
          'id': 'server-quest-7',
          'title': 'Сделай следующий шаг',
          'description': 'Выполни одно конкретное действие по своей цели.',
          'tip': 'Начни с минимальной версии.',
          'xpReward': 25,
          'actionType': 'reflection',
          'verificationType': 'self_confirm',
          'verificationMinutes': 0,
          'suggestedProofType': 'text',
          'proofPrompt': 'Запиши один вывод.',
        },
        '7',
        'user-1',
      );

      expect(quest.id, 'server-quest-7');
      expect(quest.actionType, QuestActionType.reflection);
      expect(quest.suggestedProofType, QuestProofType.text);
      expect(quest.effectiveProofPrompt, 'Запиши один вывод.');
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

    test('timer uses verification duration instead of total estimate', () {
      final startedAt = DateTime(2026, 7, 16, 12);
      final quest = _quest(
        verificationType: QuestVerificationType.timer,
        verificationStatus: QuestVerificationStatus.inProgress,
        verificationStartedAt: startedAt,
        estimatedMinutes: 30,
        verificationMinutes: 12,
      );

      expect(quest.effectiveVerificationMinutes, 12);
      expect(
        quest.verificationRemainingAt(
          startedAt.add(const Duration(minutes: 5)),
        ),
        const Duration(minutes: 7),
      );
    });

    test('maps a location timer returned by the edge function', () {
      final quest = Quest.fromEdgeFunction(
        {
          'id': 'gym-quest',
          'title': 'Проведи тренировку в зале',
          'description': 'Выполни тренировку в сохранённом зале.',
          'tip': 'Начни с разминки.',
          'verificationType': 'location_timer',
          'verificationMinutes': 20,
          'requiredPlaceType': 'training',
        },
        '1',
        'user-1',
      );

      expect(quest.verificationType, QuestVerificationType.locationTimer);
      expect(quest.requiredPlaceType, 'training');
      expect(quest.requiredLocationChecks, 2);
      expect(quest.requiredPlaceLabel, 'Тренировка');
    });

    test('location timer needs both elapsed time and final place check', () {
      final startedAt = DateTime(2026, 8, 5, 12);
      final unfinished = _quest(
        verificationType: QuestVerificationType.locationTimer,
        verificationStatus: QuestVerificationStatus.inProgress,
        verificationStartedAt: startedAt,
        verificationMinutes: 20,
        requiredPlaceType: 'training',
        locationChecksPassed: 1,
        lastLocationCheckAt: startedAt,
      );
      final finishedAt = startedAt.add(const Duration(minutes: 20));

      expect(unfinished.verificationReadyAt(finishedAt), isFalse);
      expect(unfinished.locationFinalCheckAvailableAt(finishedAt), isTrue);
      expect(
        unfinished.copyWith(locationChecksPassed: 2).verificationReadyAt(
              finishedAt,
            ),
        isTrue,
      );
    });

    test('long location timer exposes a midpoint checkpoint', () {
      final startedAt = DateTime(2026, 8, 5, 12);
      final quest = _quest(
        verificationType: QuestVerificationType.locationTimer,
        verificationStatus: QuestVerificationStatus.inProgress,
        verificationStartedAt: startedAt,
        verificationMinutes: 60,
        requiredPlaceType: 'training',
        locationChecksPassed: 1,
        lastLocationCheckAt: startedAt,
      );

      expect(quest.requiredLocationChecks, 3);
      expect(
        quest.locationCheckpointAvailableAt(
          startedAt.add(const Duration(minutes: 29)),
        ),
        isFalse,
      );
      expect(
        quest.locationCheckpointAvailableAt(
          startedAt.add(const Duration(minutes: 30)),
        ),
        isTrue,
      );
    });

    test('location checks cannot be repeated immediately', () {
      final lastCheck = DateTime(2026, 8, 5, 12);
      final quest = _quest(
        verificationType: QuestVerificationType.locationTimer,
        lastLocationCheckAt: lastCheck,
      );

      expect(
        quest.locationCheckSpacingReadyAt(
          lastCheck.add(const Duration(seconds: 59)),
        ),
        isFalse,
      );
      expect(
        quest.locationCheckSpacingReadyAt(
          lastCheck.add(const Duration(minutes: 1)),
        ),
        isTrue,
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
