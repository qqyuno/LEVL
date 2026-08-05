import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import '../../core/theme/app_colors.dart';

part 'quest_model.freezed.dart';
part 'quest_model.g.dart';

enum QuestStatus { pending, completed, skipped }

enum QuestType { daily, main, side, epic }

enum QuestCategory { discipline, knowledge, relations, energy, will, wisdom }

enum QuestActionType {
  routine,
  focus,
  movement,
  reflection,
  communication,
  result
}

enum QuestVerificationType { selfConfirm, timer, locationTimer }

enum QuestVerificationStatus { notStarted, inProgress, verified }

enum QuestProofType { none, text, link, image }

// Difficulty in skulls (1-5)
enum QuestDifficulty { trivial, easy, medium, hard, epic }

// --- Isar collection (local DB) ---
@Collection()
class QuestLocal {
  Id id = Isar.autoIncrement;

  @Index()
  late String supabaseId;

  @Index()
  late String userId;

  late String title;
  late String description;
  late String tip;
  late int xpReward;
  late int estimatedMinutes;
  late bool isMainGoalTask;
  String successCriterion = '';

  @Enumerated(EnumType.name)
  QuestActionType actionType = QuestActionType.routine;

  @Enumerated(EnumType.name)
  QuestVerificationType verificationType = QuestVerificationType.selfConfirm;

  int verificationMinutes = 0;
  String requiredPlaceType = '';
  int locationChecksPassed = 0;
  DateTime? lastLocationCheckAt;

  @Enumerated(EnumType.name)
  QuestProofType suggestedProofType = QuestProofType.none;

  String proofPrompt = '';

  @Enumerated(EnumType.name)
  QuestVerificationStatus verificationStatus =
      QuestVerificationStatus.notStarted;

  DateTime? verificationStartedAt;
  DateTime? verifiedAt;

  @Enumerated(EnumType.name)
  QuestProofType proofType = QuestProofType.none;

  String proofValue = '';
  String proofImageName = '';
  List<byte>? proofImageBytes;
  String proofStoragePath = '';
  DateTime? proofAddedAt;

  @Enumerated(EnumType.name)
  QuestStatus status = QuestStatus.pending;

  @Enumerated(EnumType.name)
  QuestDifficulty difficulty = QuestDifficulty.medium;

  @Enumerated(EnumType.name)
  QuestType type = QuestType.daily;

  @Enumerated(EnumType.name)
  QuestCategory category = QuestCategory.discipline;

  DateTime createdAt = DateTime.now();
  DateTime? completedAt;
  bool syncedToSupabase = false;
}

// --- Freezed model (in-memory / UI state) ---
@freezed
class Quest with _$Quest {
  const Quest._(); // enables methods on Freezed class

  const factory Quest({
    required String id,
    required String userId,
    required String title,
    required String description,
    required String tip,
    required int xpReward,
    @Default(30) int estimatedMinutes,
    @Default(false) bool isMainGoalTask,
    @Default('') String successCriterion,
    @Default(QuestActionType.routine) QuestActionType actionType,
    @Default(QuestVerificationType.selfConfirm)
    QuestVerificationType verificationType,
    @Default(0) int verificationMinutes,
    @Default('') String requiredPlaceType,
    @Default(0) int locationChecksPassed,
    DateTime? lastLocationCheckAt,
    @Default(QuestProofType.none) QuestProofType suggestedProofType,
    @Default('') String proofPrompt,
    @Default(QuestVerificationStatus.notStarted)
    QuestVerificationStatus verificationStatus,
    DateTime? verificationStartedAt,
    DateTime? verifiedAt,
    @Default(QuestProofType.none) QuestProofType proofType,
    @Default('') String proofValue,
    @Default('') String proofImageName,
    @Default('') String proofStoragePath,
    DateTime? proofAddedAt,
    @Default(QuestStatus.pending) QuestStatus status,
    @Default(QuestDifficulty.medium) QuestDifficulty difficulty,
    @Default(QuestType.daily) QuestType type,
    @Default(QuestCategory.discipline) QuestCategory category,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Quest;

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);

  /// Build a Quest from Edge Function JSON response
  factory Quest.fromEdgeFunction(
    Map<String, dynamic> json,
    String orderId,
    String userId,
  ) {
    return Quest(
      id: json['id'] as String? ??
          '${userId}_${DateTime.now().toIso8601String()}_$orderId',
      userId: userId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      xpReward: json['xpReward'] as int? ?? 25,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
      isMainGoalTask: json['isMainGoalTask'] as bool? ?? false,
      successCriterion: json['successCriterion'] as String? ?? '',
      actionType: QuestActionType.values.firstWhere(
        (type) => type.name == json['actionType'],
        orElse: () => QuestActionType.routine,
      ),
      verificationType: switch (json['verificationType']) {
        'timer' => QuestVerificationType.timer,
        'location_timer' => QuestVerificationType.locationTimer,
        _ => QuestVerificationType.selfConfirm,
      },
      verificationMinutes: json['verificationMinutes'] as int? ?? 0,
      requiredPlaceType: _safePlaceType(json['requiredPlaceType']),
      suggestedProofType: switch (json['suggestedProofType']) {
        'text' => QuestProofType.text,
        'link' => QuestProofType.link,
        'image' => QuestProofType.image,
        _ => QuestProofType.none,
      },
      proofPrompt: json['proofPrompt'] as String? ?? '',
      difficulty: QuestDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => QuestDifficulty.medium,
      ),
      category: QuestCategory.values.firstWhere(
        (c) => c.name == json['sphere'],
        orElse: () => QuestCategory.discipline,
      ),
      type: json['isMainGoalTask'] == true ? QuestType.main : QuestType.daily,
      createdAt: DateTime.now(),
    );
  }

  String get effectiveSuccessCriterion => successCriterion.trim().isNotEmpty
      ? successCriterion.trim()
      : description.trim();

  int get effectiveVerificationMinutes {
    if (!isTimedVerification) return 0;
    if (verificationMinutes > 0) return verificationMinutes;
    return estimatedMinutes.clamp(1, 90);
  }

  String get effectiveProofPrompt {
    if (proofPrompt.trim().isNotEmpty) return proofPrompt.trim();
    return switch (suggestedProofType) {
      QuestProofType.text => 'Коротко запиши, что получилось.',
      QuestProofType.link => 'Добавь ссылку на готовый результат.',
      QuestProofType.image => 'Добавь фото или скрин результата.',
      QuestProofType.none => '',
    };
  }

  Duration verificationRemainingAt(DateTime now) {
    if (!isTimedVerification) {
      return Duration.zero;
    }
    final startedAt = verificationStartedAt;
    if (startedAt == null) {
      return Duration(minutes: effectiveVerificationMinutes);
    }
    final remaining = startedAt
        .add(Duration(minutes: effectiveVerificationMinutes))
        .difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool verificationReadyAt(DateTime now) {
    if (verificationType == QuestVerificationType.selfConfirm) return true;
    final timerReady =
        verificationStatus == QuestVerificationStatus.inProgress &&
            verificationRemainingAt(now) == Duration.zero;
    if (verificationType == QuestVerificationType.locationTimer) {
      return timerReady && locationChecksPassed >= requiredLocationChecks;
    }
    return timerReady;
  }

  bool get isTimedVerification =>
      verificationType == QuestVerificationType.timer ||
      verificationType == QuestVerificationType.locationTimer;

  int get requiredLocationChecks {
    if (verificationType != QuestVerificationType.locationTimer) return 0;
    return effectiveVerificationMinutes >= 30 ? 3 : 2;
  }

  String get requiredPlaceLabel => switch (requiredPlaceType) {
        'home' => 'Дом',
        'work' => 'Работа',
        'training' => 'Тренировка',
        'focus' => 'Фокус',
        _ => 'Сохранённое место',
      };

  bool locationCheckpointAvailableAt(DateTime now) {
    if (verificationType != QuestVerificationType.locationTimer ||
        verificationStatus != QuestVerificationStatus.inProgress ||
        requiredLocationChecks < 3 ||
        locationChecksPassed != 1 ||
        verificationStartedAt == null) {
      return false;
    }
    final elapsed = now.difference(verificationStartedAt!);
    return elapsed >=
        Duration(minutes: (effectiveVerificationMinutes / 2).floor());
  }

  bool locationCheckSpacingReadyAt(DateTime now) {
    final lastCheck = lastLocationCheckAt;
    return lastCheck == null ||
        now.difference(lastCheck) >= const Duration(minutes: 1);
  }

  bool locationFinalCheckAvailableAt(DateTime now) {
    if (verificationType != QuestVerificationType.locationTimer ||
        verificationStatus != QuestVerificationStatus.inProgress) {
      return false;
    }
    return verificationRemainingAt(now) == Duration.zero &&
        locationChecksPassed == requiredLocationChecks - 1 &&
        locationCheckSpacingReadyAt(now);
  }
}

String _safePlaceType(Object? value) {
  const allowed = {'home', 'work', 'training', 'focus'};
  final normalized = value?.toString() ?? '';
  return allowed.contains(normalized) ? normalized : '';
}

extension QuestVerificationVisual on QuestVerificationType {
  String get label => switch (this) {
        QuestVerificationType.selfConfirm => 'Подтверждение',
        QuestVerificationType.timer => 'Таймер',
        QuestVerificationType.locationTimer => 'Место + таймер',
      };

  IconData get icon => switch (this) {
        QuestVerificationType.selfConfirm => Icons.verified_outlined,
        QuestVerificationType.timer => Icons.timer_outlined,
        QuestVerificationType.locationTimer => Icons.location_on_outlined,
      };
}

// XP values by difficulty
extension QuestDifficultyXp on QuestDifficulty {
  int get baseXp => switch (this) {
        QuestDifficulty.trivial => 10,
        QuestDifficulty.easy => 25,
        QuestDifficulty.medium => 50,
        QuestDifficulty.hard => 100,
        QuestDifficulty.epic => 200,
      };

  int get skulls => switch (this) {
        QuestDifficulty.trivial => 1,
        QuestDifficulty.easy => 2,
        QuestDifficulty.medium => 3,
        QuestDifficulty.hard => 4,
        QuestDifficulty.epic => 5,
      };
}

// Sphere visual mapping — icon + color for quest cards
extension QuestCategoryVisual on QuestCategory {
  IconData get icon => switch (this) {
        QuestCategory.discipline => Icons.bolt,
        QuestCategory.knowledge => Icons.menu_book,
        QuestCategory.relations => Icons.people,
        QuestCategory.energy => Icons.local_fire_department,
        QuestCategory.will => Icons.my_location,
        QuestCategory.wisdom => Icons.psychology,
      };

  Color get color => switch (this) {
        QuestCategory.discipline => AppColors.sphereDiscipline,
        QuestCategory.knowledge => AppColors.sphereKnowledge,
        QuestCategory.relations => AppColors.sphereRelations,
        QuestCategory.energy => AppColors.sphereEnergy,
        QuestCategory.will => AppColors.sphereWill,
        QuestCategory.wisdom => AppColors.sphereWisdom,
      };

  String get label => switch (this) {
        QuestCategory.discipline => 'Дисциплина',
        QuestCategory.knowledge => 'Знания',
        QuestCategory.relations => 'Отношения',
        QuestCategory.energy => 'Энергия',
        QuestCategory.will => 'Воля',
        QuestCategory.wisdom => 'Мудрость',
      };

  String get description => switch (this) {
        QuestCategory.discipline => 'Привычки, режим, обязательства',
        QuestCategory.knowledge => 'Обучение, навыки, рост',
        QuestCategory.relations => 'Семья, друзья, нетворкинг',
        QuestCategory.energy => 'Здоровье, спорт, сон',
        QuestCategory.will => 'Фокус, упорство, преодоление',
        QuestCategory.wisdom => 'Рефлексия, решения, интуиция',
      };
}
