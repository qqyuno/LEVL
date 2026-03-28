# Plan 1.2 — pubspec.yaml + Dependencies

**Phase:** 1 — Foundation
**Goal:** Подключить все зависимости и настроить assets.

## Dependencies

### pubspec.yaml (полный)
```yaml
name: levl
description: Personal life progression system.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^14.0.0

  # Local database
  isar: 3.1.0+1
  isar_flutter_libs: 3.1.0+1

  # Backend
  supabase_flutter: ^2.5.0

  # UI
  google_fonts: ^7.0.0

  # Animations
  rive: ^0.13.0
  lottie: ^3.1.0

  # Utils
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code generation
  riverpod_generator: ^2.4.0
  isar_generator: 3.1.0+1
  build_runner: ^2.4.0

flutter:
  uses-material-design: true

  assets:
    - assets/character/
    - assets/animations/
    - .env
```

## Steps

### 1. Заменить pubspec.yaml
Полностью заменить содержимое `levl/pubspec.yaml` на версию выше.

### 2. Создать `.env` файл
```
# levl/.env
SUPABASE_URL=placeholder
SUPABASE_ANON_KEY=placeholder
```
> Реальные ключи будут добавлены позже

### 3. Установить зависимости
```bash
cd levl
flutter pub get
```

### 4. Проверить что нет конфликтов версий
```bash
flutter pub deps
```

## Verification
- [ ] `flutter pub get` выполнен без ошибок
- [ ] Все 12 зависимостей установлены
- [ ] assets секция в pubspec.yaml указывает на обе папки
- [ ] `.env` файл создан
- [ ] `flutter pub deps` не показывает конфликтов
