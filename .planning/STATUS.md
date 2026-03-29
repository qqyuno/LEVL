# LEVL — Статус разработки

> Обновлено: 2026-03-29

---

## ✅ ГОТОВО

### Phase 1 — Фундамент
- [x] Flutter проект создан (Dart 3.11, Flutter 3.41)
- [x] Riverpod v2 + GoRouter v14 + Isar 3.1 подключены
- [x] Тема Light Minimal — AppColors + AppTheme (Material 3, Brightness.light)
- [x] Шрифты DM Serif Display + DM Sans
- [x] GoRouter с тройным guard (auth → onboarding → dashboard)
- [x] Модели: UserProfileLocal, QuestLocal (Isar), UserProfile, Quest (Freezed)
- [x] .env через flutter_dotenv

### Phase 2 — Auth
- [x] Supabase клиент инициализирован
- [x] AuthNotifier (Riverpod) — стримит сессию
- [x] Welcome экран — кнопки Google / Apple OAuth
- [x] signInWithGoogle / signInWithApple через supabase_flutter
- [x] isAuthenticatedProvider
- [x] Isar сервис с path_provider (директория для Windows)

### Phase 3 — Онбординг (7 шагов)
- [x] Шаг 1: Где ты сейчас? (текст)
- [x] Шаг 2: Что тормозит? (мульти-выбор чипы)
- [x] Шаг 3: Какие сферы развить? (выбор 2-4 из 6)
- [x] Шаг 4: Цели в сферах (текст per sphere, persistent controllers)
- [x] Шаг 5: Как работаешь? (стиль)
- [x] Шаг 6: Куда через год? (суперцель)
- [x] Шаг 7: Сколько времени? (слайдер)
- [x] OnboardingData — immutable с copyWith
- [x] Валидация canProceed() по каждому шагу
- [x] saveProfile() → Isar (spheresJson, goalsJson через jsonEncode)
- [x] Анимированный progress bar
- [x] OnboardingComplete guard в роутере

### GitHub / Коллаборация
- [x] Репо qqyuno/LEVL (private)
- [x] SSH ключи настроены (ты + Денис)
- [x] Денис добавлен как collaborator
- [x] Код запушен

---

## ✅ Phase 4 — Dashboard + Quests (ГОТОВО)

### 4.1 Edge Function (Supabase)
- [x] `supabase/functions/generate-quests/index.ts`
- [x] Промпт для Claude API (claude-sonnet-4-20250514) с контекстом профиля
- [x] Кеш-логика: ключ `userId_YYYY-MM-DD`, upsert в quest_cache
- [x] Ротация сфер (2-3 → все, 4 → 3 в день по rotation)
- [x] Возврат 3 заданий: title, description, sphere, isMainGoalTask, xpReward, estimatedMinutes, difficulty, tip

### 4.2 Supabase — База данных
- [ ] ⚠️ Нужно создать таблицы в Supabase Dashboard (SQL из CLAUDE.md)
- [ ] Таблица profiles, quests, quest_cache, daily_checkins
- [ ] Функция add_xp()

### 4.3 Flutter — Quest провайдер
- [x] QuestNotifier — загружает из Isar → fallback Edge Function
- [x] UserProfileNotifier — загружает профиль из Isar
- [x] completeQuest() → UI update → Isar → add_xp → sync Supabase
- [x] Isar query helpers через .build().findAll()

### 4.4 Flutter — Dashboard UI
- [x] Подключены реальные провайдеры (убраны mock)
- [x] QuestCard с иконкой сферы в цветном кружке (40x40)
- [x] Суперцель — карточка с Icons.stars_rounded, золотая рамка
- [x] Кнопка "выполнено" — AnimatedContainer, HapticFeedback
- [x] Зачёркнутый текст + заливка при выполнении
- [x] ErrorCard с кнопкой "Повторить"
- [x] Время (мин) + сфера label на каждой карточке

---

## 🔜 ДАЛЬШЕ (после Phase 4)

## ✅ Phase 5 — Character Sheet (ГОТОВО)
- [x] StatsRadarChart — кастомный hexagonal radar (CustomPainter, без пакетов)
- [x] 6 характеристик с иконками сфер и цветами
- [x] StatBar — горизонтальные progress bars для каждой характеристики
- [x] Achievement model — 12 достижений (уровень, стрик, квесты, сферы)
- [x] AchievementCard — золотой бордер для разблокированных, серый для locked
- [x] CharacterPage — avatar, title по уровню, radar chart, stat bars, achievements grid
- [x] Bottom Navigation — 3 таба (Путь, Персонаж, Система) через ShellRoute
- [x] GoRouter обновлён — ShellRoute для dashboard/character/mentor

### Phase 6 — AI Ментор
- [ ] Чат с контекстом прогресса
- [ ] Edge Function для диалога

### Phase 7 — Polish
- [ ] Rive/Lottie анимации
- [ ] Haptic Feedback
- [ ] Звуки

---

## Окружение
- Flutter 3.41.6 / Dart 3.11.4
- Windows 11, VS Code
- Supabase проект: нужно создать (URL + ключи в .env)
- Visual Studio C++ установлен (для Windows desktop builds)
