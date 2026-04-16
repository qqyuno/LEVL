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

  // Accumulated sphere XP (0 → ∞, no cap).
  // Ranks: Новичок(0) Ученик(150) Практик(400) Адепт(800) Мастер(1500) Легенда(3000+)
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
    @Default(0) int questsCompleted,
    @Default(30) int dailyMinutes,
    @Default([]) List<String> goals,
    @Default('') String lifeContext,
    @Default('') String mainGoal,
    @Default('') String workStyle,
    @Default(CharacterStats()) CharacterStats stats,
    @Default('') String characterStateJson,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

// Accumulated sphere XP per sphere (0 → ∞)
@freezed
class CharacterStats with _$CharacterStats {
  const factory CharacterStats({
    @Default(0) int discipline,
    @Default(0) int knowledge,
    @Default(0) int relations,
    @Default(0) int energy,
    @Default(0) int will,
    @Default(0) int wisdom,
  }) = _CharacterStats;

  factory CharacterStats.fromJson(Map<String, dynamic> json) =>
      _$CharacterStatsFromJson(json);
}

// ---------------------------------------------------------------------------
// XP & Level system
// Curve: xpToNextLevel(n) = 200 + (n-1) * 100
//   Level 1→2:  200 XP  (~2 days)
//   Level 5→6:  600 XP  (~6 days)
//   Level 10→11: 1100 XP (~11 days)
//   Level 20→21: 2100 XP (~21 days)
//   Level 30 reached after ~1 year of daily play
// ---------------------------------------------------------------------------

/// XP required to advance from [level] to [level+1].
int xpToNextLevel(int level) => 200 + (level - 1) * 100;

/// Total XP accumulated at the START of [level].
/// cumulativeXpForLevel(1) = 0
/// cumulativeXpForLevel(2) = 200
/// cumulativeXpForLevel(3) = 500  (200+300)
int cumulativeXpForLevel(int level) {
  if (level <= 1) return 0;
  final n = level - 1; // number of levels already completed
  // Sum of xpToNextLevel(k) for k=1..n = sum of (200 + (k-1)*100) = 200n + 100*n*(n-1)/2
  return 200 * n + 50 * n * (n - 1);
}

/// Derive the current level from total XP.
int levelFromXp(int totalXp) {
  if (totalXp <= 0) return 1;
  int level = 1;
  int remaining = totalXp;
  while (remaining >= xpToNextLevel(level)) {
    remaining -= xpToNextLevel(level);
    level++;
    if (level > 500) break; // safety cap
  }
  return level;
}

/// Progress within the current level (0.0 – 1.0) for the XP bar.
double levelProgress(int xp, int level) {
  final start = cumulativeXpForLevel(level);
  final needed = xpToNextLevel(level);
  return ((xp - start) / needed).clamp(0.0, 1.0);
}

/// XP earned within the current level.
int xpInCurrentLevel(int xp, int level) {
  return xp - cumulativeXpForLevel(level);
}

// ---------------------------------------------------------------------------
// Sphere rank system
// Thresholds (accumulated sphere XP):
//   Новичок  0-149
//   Ученик   150-399
//   Практик  400-799
//   Адепт    800-1499
//   Мастер   1500-2999
//   Легенда  3000+
//
// With 2 sphere quests/day at medium (17 sphere XP each):
//   Новичок→Ученик:   ~9 days
//   Ученик→Практик:   ~15 days
//   Практик→Адепт:    ~24 days
//   Адепт→Мастер:     ~41 days
//   Мастер→Легенда:   ~88 days  (~6 months total per sphere)
// ---------------------------------------------------------------------------

const List<int> _sphereThresholds = [0, 150, 400, 800, 1500, 3000];
const List<String> _sphereRankNames = [
  'Новичок', 'Ученик', 'Практик', 'Адепт', 'Мастер', 'Легенда',
];

/// Human-readable rank name for a given accumulated sphere XP value.
String sphereRankName(int sphereXp) {
  for (int i = _sphereThresholds.length - 1; i >= 0; i--) {
    if (sphereXp >= _sphereThresholds[i]) return _sphereRankNames[i];
  }
  return _sphereRankNames[0];
}

/// Progress within the current rank (0.0 – 1.0) for the progress bar.
double sphereRankProgress(int sphereXp) {
  for (int i = 0; i < _sphereThresholds.length - 1; i++) {
    if (sphereXp < _sphereThresholds[i + 1]) {
      final lo = _sphereThresholds[i];
      final hi = _sphereThresholds[i + 1];
      return (sphereXp - lo) / (hi - lo);
    }
  }
  return 1.0; // Легенда — max rank
}

/// Sphere XP needed to reach the next rank (0 if already at Легенда).
int sphereXpToNextRank(int sphereXp) {
  for (int i = 0; i < _sphereThresholds.length - 1; i++) {
    if (sphereXp < _sphereThresholds[i + 1]) {
      return _sphereThresholds[i + 1] - sphereXp;
    }
  }
  return 0;
}

/// Normalize sphere XP to 0.0–1.0 for the radar chart
/// (max = Легенда threshold = 3000).
double sphereNormalized(int sphereXp) =>
    (sphereXp / _sphereThresholds.last).clamp(0.0, 1.0);
