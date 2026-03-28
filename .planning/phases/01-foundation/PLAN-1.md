# Plan 1.1 — Flutter Project Init + Folder Structure

**Phase:** 1 — Foundation
**Goal:** Создать Flutter проект с правильной архитектурой папок.

## Context
- Проект: `levl` (lowercase)
- Путь: `c:\Users\fishk\Desktop\LEVL\levl\`
- Flutter уже установлен (предполагается)

## Steps

### 1. Создать Flutter проект
```bash
cd "c:\Users\fishk\Desktop\LEVL"
flutter create levl --org com.levlapp --platforms ios,android
cd levl
```

### 2. Очистить дефолтный код
Удалить весь стартовый код из `lib/main.dart`, оставить только базовую структуру.

### 3. Создать папочную структуру
```
lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── router/
│   │   └── app_router.dart
│   └── supabase/
│       └── supabase_client.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── providers.dart
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── providers.dart
│   ├── dashboard/
│   │   ├── presentation/
│   │   └── providers.dart
│   ├── character/
│   │   ├── presentation/
│   │   └── providers.dart
│   └── ai_mentor/
│       ├── presentation/
│       └── providers.dart
└── shared/
    ├── models/
    │   ├── user_profile.dart
    │   └── quest.dart
    └── widgets/
        └── .gitkeep
```

```bash
# Создать все папки
mkdir -p lib/core/theme lib/core/router lib/core/supabase
mkdir -p lib/features/auth/data lib/features/auth/domain lib/features/auth/presentation
mkdir -p lib/features/onboarding/presentation/screens lib/features/onboarding/presentation/widgets
mkdir -p lib/features/dashboard/presentation lib/features/character/presentation
mkdir -p lib/features/ai_mentor/presentation
mkdir -p lib/shared/models lib/shared/widgets
mkdir -p assets/character assets/animations
```

### 4. Создать `.gitignore` дополнение
Добавить в `.gitignore`:
```
*.g.dart
*.freezed.dart
```

## Verification
- [ ] `flutter create` выполнен успешно
- [ ] Структура папок соответствует схеме выше
- [ ] `lib/main.dart` очищен от demo-кода
- [ ] `assets/character/` и `assets/animations/` созданы
