import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import '../../core/theme/app_colors.dart';

part 'quest_model.freezed.dart';
part 'quest_model.g.dart';

enum QuestStatus { pending, completed, skipped }

enum QuestType { daily, main, side, epic }

enum QuestCategory { discipline, knowledge, relations, energy, will, wisdom }

enum QuestVerificationType { selfConfirm, timer }

enum QuestVerificationStatus { notStarted, inProgress, verified }

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
  QuestVerificationType verificationType = QuestVerificationType.selfConfirm;

  @Enumerated(EnumType.name)
  QuestVerificationStatus verificationStatus =
      QuestVerificationStatus.notStarted;

  DateTime? verificationStartedAt;
  DateTime? verifiedAt;

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
    @Default(QuestVerificationType.selfConfirm)
    QuestVerificationType verificationType,
    @Default(QuestVerificationStatus.notStarted)
    QuestVerificationStatus verificationStatus,
    DateTime? verificationStartedAt,
    DateTime? verifiedAt,
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
      id:
          json['id'] as String? ??
          '${userId}_${DateTime.now().toIso8601String()}_$orderId',
      userId: userId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      xpReward: json['xpReward'] as int? ?? 25,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
      isMainGoalTask: json['isMainGoalTask'] as bool? ?? false,
      successCriterion: json['successCriterion'] as String? ?? '',
      verificationType: switch (json['verificationType']) {
        'timer' => QuestVerificationType.timer,
        _ => QuestVerificationType.selfConfirm,
      },
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

  Duration verificationRemainingAt(DateTime now) {
    if (verificationType != QuestVerificationType.timer) {
      return Duration.zero;
    }
    final startedAt = verificationStartedAt;
    if (startedAt == null) return Duration(minutes: estimatedMinutes);
    final remaining = startedAt
        .add(Duration(minutes: estimatedMinutes))
        .difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool verificationReadyAt(DateTime now) {
    if (verificationType == QuestVerificationType.selfConfirm) return true;
    return verificationStatus == QuestVerificationStatus.inProgress &&
        verificationRemainingAt(now) == Duration.zero;
  }
}

extension QuestVerificationVisual on QuestVerificationType {
  String get label => switch (this) {
    QuestVerificationType.selfConfirm => 'Подтверждение',
    QuestVerificationType.timer => 'Таймер',
  };

  IconData get icon => switch (this) {
    QuestVerificationType.selfConfirm => Icons.verified_outlined,
    QuestVerificationType.timer => Icons.timer_outlined,
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
