import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'quest_model.freezed.dart';
part 'quest_model.g.dart';

enum QuestStatus { pending, completed, skipped }
enum QuestType { daily, main, side, epic }
enum QuestCategory { discipline, knowledge, relations, energy, will, wisdom }

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
  const factory Quest({
    required String id,
    required String userId,
    required String title,
    required String description,
    required String tip,
    required int xpReward,
    @Default(30) int estimatedMinutes,
    @Default(QuestStatus.pending) QuestStatus status,
    @Default(QuestDifficulty.medium) QuestDifficulty difficulty,
    @Default(QuestType.daily) QuestType type,
    @Default(QuestCategory.discipline) QuestCategory category,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Quest;

  factory Quest.fromJson(Map<String, dynamic> json) =>
      _$QuestFromJson(json);
}

// XP values by difficulty
extension QuestDifficultyXp on QuestDifficulty {
  int get baseXp => switch (this) {
    QuestDifficulty.trivial => 10,
    QuestDifficulty.easy    => 25,
    QuestDifficulty.medium  => 50,
    QuestDifficulty.hard    => 100,
    QuestDifficulty.epic    => 200,
  };

  int get skulls => switch (this) {
    QuestDifficulty.trivial => 1,
    QuestDifficulty.easy    => 2,
    QuestDifficulty.medium  => 3,
    QuestDifficulty.hard    => 4,
    QuestDifficulty.epic    => 5,
  };
}
