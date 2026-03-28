# Plan 1.5 — Isar Setup + Base Models

**Phase:** 1 — Foundation
**Goal:** Подключить Isar, определить базовые модели UserProfile и Quest.

## Files to Create

### `lib/shared/models/user_profile.dart`
```dart
import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@Collection()
class UserProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String supabaseId; // UUID from Supabase auth

  late String name;
  List<String> goals = [];
  String lifeContext = '';
  String mainGoal = '';
  String workStyle = '';
  int dailyMinutes = 30;
  int level = 1;
  int xp = 0;
  int currentStreak = 0;
  DateTime? lastActiveDate;
  DateTime createdAt = DateTime.now();

  // Character customization state (JSON-like via Map)
  String characterStateJson = '{}';
}
```

### `lib/shared/models/quest.dart`
```dart
import 'package:isar/isar.dart';

part 'quest.g.dart';

enum QuestStatus { pending, completed, skipped }
enum QuestDifficulty { easy, medium, hard, epic }

@Collection()
class Quest {
  Id id = Isar.autoIncrement;

  @Index()
  late String supabaseId; // UUID from Supabase

  @Index()
  late String userId;

  late String title;
  late String description;
  late String category;
  late int xpReward;
  late String tip;

  @Enumerated(EnumType.name)
  QuestStatus status = QuestStatus.pending;

  @Enumerated(EnumType.name)
  QuestDifficulty difficulty = QuestDifficulty.medium;

  int estimatedMinutes = 30;
  DateTime createdAt = DateTime.now();
  DateTime? completedAt;

  // Sync state
  bool syncedToSupabase = false;
}
```

### `lib/core/supabase/isar_service.dart`
```dart
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/quest.dart';

part 'isar_service.g.dart';

@riverpod
Future<Isar> isar(IsarRef ref) async {
  final isar = await Isar.open([
    UserProfileSchema,
    QuestSchema,
  ]);
  return isar;
}
```

## Steps
1. Создать `lib/shared/models/user_profile.dart`
2. Создать `lib/shared/models/quest.dart`
3. Создать `lib/core/supabase/isar_service.dart`
4. Запустить генерацию кода:
```bash
cd levl
flutter pub run build_runner build --delete-conflicting-outputs
```
5. Убедиться что `user_profile.g.dart` и `quest.g.dart` сгенерированы

## Verification
- [ ] Оба `.g.dart` файла сгенерированы без ошибок
- [ ] `UserProfileSchema` и `QuestSchema` доступны
- [ ] `isar_service.dart` компилируется
- [ ] `Isar.open([UserProfileSchema, QuestSchema])` не выдаёт ошибок
- [ ] `flutter analyze` не показывает критических ошибок
