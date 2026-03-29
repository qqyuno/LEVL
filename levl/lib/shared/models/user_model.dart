import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

// --- Isar collection (local DB) ---
@Collection()
class UserProfileLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String supabaseId;

  late String name;
  late int level;
  late int xp;
  late int currentStreak;
  late int dailyMinutes;

  // Serialized as JSON string
  late String goalsJson;
  late String spheresJson;     // comma-separated sphere keys
  late String lifeContext;
  late String mainGoal;
  late String workStyle;
  late String characterStateJson;

  // Skill stats (0-100)
  late int statDiscipline;
  late int statKnowledge;
  late int statRelations;
  late int statEnergy;
  late int statWill;
  late int statWisdom;

  DateTime createdAt = DateTime.now();
  DateTime? lastActiveDate;
  bool syncedToSupabase = false;
}

// --- Freezed model (in-memory / UI state) ---
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(0) int currentStreak,
    @Default(30) int dailyMinutes,
    @Default([]) List<String> goals,
    @Default('') String lifeContext,
    @Default('') String mainGoal,
    @Default('') String workStyle,
    @Default(CharacterStats()) CharacterStats stats,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class CharacterStats with _$CharacterStats {
  const factory CharacterStats({
    @Default(10) int discipline,   // дисциплина
    @Default(10) int knowledge,    // знания
    @Default(10) int relations,    // отношения
    @Default(10) int energy,       // энергия
    @Default(10) int will,         // воля
    @Default(10) int wisdom,       // мудрость
  }) = _CharacterStats;

  factory CharacterStats.fromJson(Map<String, dynamic> json) =>
      _$CharacterStatsFromJson(json);
}

// XP required per level (each level = 100 XP)
// Level formula: level = floor(xp / 100) + 1
// Level N starts at (N-1)*100 XP and ends at N*100 XP
int xpForLevel(int level) => level * 100;

// Progress to next level (0.0 - 1.0)
double levelProgress(int xp, int level) {
  final levelStartXp = (level - 1) * 100; // XP where current level began
  final levelEndXp = level * 100;         // XP where next level begins
  return ((xp - levelStartXp) / (levelEndXp - levelStartXp)).clamp(0.0, 1.0);
}
