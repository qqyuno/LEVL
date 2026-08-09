# LEVL — Roadmap

> Актуальная продуктовая стратегия: [PRODUCT_STRATEGY_2026.md](PRODUCT_STRATEGY_2026.md)

## Срез на 9 августа 2026

- [x] Quest Engine 2.5 и проверка заданий по времени/локации развёрнуты в Supabase
- [x] После подтверждения действия пользователь видит XP, рост сферы и движение по маршруту
- [x] Добавлена приватная аналитика ключевой воронки без текстов целей, доказательств и координат
- [ ] Следующий продуктовый срез: weekly recap и сценарий возвращения после пропуска
- [ ] Следующий визуальный срез: полноразмерный 2.5D-персонаж, пять ракурсов и один комплект одежды

## Milestone 0.9 — Pre-MVP Expansion до августа 2026
**Goal:** уйти от ощущения habit tracker и собрать основу удержания: карта, живое отражение пользователя, проверяемые задания, друзья и системные события.

### Phase A: Life Map
**Goal:** добавить карту как второй основной слой приложения после dashboard.

- [x] A.1 Спроектировать карту как "пространство пути", а не обычную геокарту
- [x] A.2 Добавить базовые зоны карты: дом, работа/учёба, тренировка, фокус, восстановление
- A.3 Добавить точки интереса: пасхалки, скрытые события, редкие задания
- [x] A.4 Связать карту с прогрессом пользователя: выполненные действия открывают новые зоны/детали
- [x] A.5 Подготовить механику "глав" на карте: неделя = отдельный маршрут/глава

### Phase B: Character / Reflection 2D or 3D
**Goal:** персонаж должен стать отражением поведения, а не декоративной аватаркой.

- B.1 Принять техническое решение: 2D rotating layered character или 3D character
- B.2 Сделать базовую кастомизацию: тело/силуэт, одежда, аура, рамка, артефакты, фон
- B.3 Привязать визуальные состояния к поведению: streak, сферы, энергия, пропуски, возвращение
- B.4 Добавить unlock-логику: предметы открываются за реальные паттерны, а не покупаются
- B.5 Сделать preview персонажа на dashboard и отдельный character screen

### Phase C: Verified Actions
**Goal:** задания должны фиксировать реальное действие, а не только галочку.

- C.1 Добавить экран фиксации после задания: что сделал, сколько заняло, короткая заметка
- C.2 Добавить optional proof: фото, скрин, ссылка или текстовый результат
- C.3 Добавить geo/time verification для заданий с локацией *(база готова: «Мои места» сохраняются локально; следующая итерация — сессия присутствия)*
- C.4 Пример: если задание "сходить на тренировку", пользователь должен быть в локации "качалка" около 60 минут
- C.5 Добавить мягкий язык проверки: "Система фиксирует след", без ощущения контроля/наказания

### Phase D: Extra Modes / Categories
**Goal:** разделить опыт на режимы, чтобы LEVL не был одним списком задач.

- D.1 Определить основные режимы: день, фокус, тренировка, восстановление, социальное, проект/работа
- D.2 Для каждого режима задать свой UI, правила и типы заданий
- D.3 Связать режимы со сферами персонажа и картой
- D.4 Добавить быстрый выбор режима в dashboard

### Phase E: Friends & Social Progress
**Goal:** добавить социальное удержание без превращения LEVL в соцсеть ради соцсети.

- E.1 Добавление друзей по ссылке/коду
- E.2 Профиль друга: уровень, ритм, активные сферы, открытые достижения
- E.3 Лента новостей: кто что зафиксировал, какие главы/предметы открыл
- E.4 Реакции/поддержка без токсичного сравнения
- E.5 Privacy-настройки: что показывать друзьям, а что оставить приватным

### Phase F: System Retention
**Goal:** один сильный системный контакт в день вместо спама.

- F.1 Мотивационное уведомление от Системы 1 раз в день
- F.2 Уведомление должно учитывать контекст: streak, пропуски, цель, невыполненные действия
- F.3 Добавить вечернюю фиксацию дня как optional сценарий
- F.4 Добавить weekly recap: что изменилось за 7 дней, какая сфера росла, что открылось

### Phase G: Onboarding Seriousness
**Goal:** повысить качество вводных данных, потому что от них зависит весь LEVL.

- G.1 Перед онбордингом добавить дисклеймер: ответы важны, отнесись серьёзно
- G.2 Объяснить, что LEVL использует ответы для задач, карты, персонажа и AI-наставника
- G.3 Добавить предупреждение: не вводить медицинские, финансовые, паспортные данные, пароли и seed-фразы
- G.4 Сделать первый экран онбординга более "ритуальным": пользователь собирает систему, а не заполняет анкету

## Milestone 1.0 — MVP

### Phase 1: Foundation
**Goal:** Flutter project scaffold with full architecture ready.

- 1.1 Initialize Flutter project (`flutter create levl`)
- 1.2 Set up folder structure: `core/`, `features/`, `shared/`
- 1.3 Configure Riverpod + GoRouter
- 1.4 Set up ThemeData: colors (#F8F8F6, #0A0A0A, #E2E2DE, #B8962E), DM Serif Display + DM Sans fonts
- 1.5 Integrate Isar database + define base models (UserProfile, Quest)
- 1.6 Add core dependencies to pubspec.yaml

### Phase 2: Supabase & Auth
**Goal:** Backend connected, auth working on real device.

- 2.1 Supabase client setup (supabase_flutter)
- 2.2 Create DB tables: profiles, quests, quest_cache, daily_checkins + add_xp function
- 2.3 Google Sign-In integration
- 2.4 Apple Sign-In integration
- 2.5 Auth state management via Riverpod (AuthNotifier)
- 2.6 Persist session locally via Isar

### Phase 3: Onboarding Flow
**Goal:** Full 7-screen onboarding with AI character generation.

- 3.1 Onboarding screens scaffold (PageView + progress bar)
- 3.2 Screen 1: Intro animation (Lottie)
- 3.3 Screens 2-6: Survey UI (wheel-of-life sliders, text inputs)
- 3.4 Screen 7: AI Processing screen with loading animation
- 3.5 Supabase Edge Function: generate initial state via Claude API
- 3.6 Success screen + save profile to Isar + Supabase

### Phase 4: Dashboard
**Goal:** Main screen fully functional with quest feed and XP.

- 4.1 Dashboard layout: header, hero segment, quest feed, FAB
- 4.2 XP bar widget + level display
- 4.3 Streak tracker widget
- 4.4 QuestCard widget with category color coding
- 4.5 Main Quest large card
- 4.6 Quest completion: mark done → add XP → Isar update → sync Supabase
- 4.7 Daily quest refresh logic (24h timer)

### Phase 5: Quest Engine + Edge Function
**Goal:** AI-generated daily quests running end-to-end.

- 5.1 Edge Function: generate-quests (port existing index.ts → update for new schema)
- 5.2 Quest generation trigger: onboarding end + daily refresh
- 5.3 Quest cache logic (quest_cache table)
- 5.4 Quest categories → stat mapping (which quests level which stats)
- 5.5 Daily check-in (energy level) → adjust quest difficulty

### Phase 6: Character Sheet
**Goal:** RPG character screen with 6 stats and achievements.

- 6.1 Character Sheet screen layout
- 6.2 6 stat bars (Дисциплина, Знания, Отношения, Энергия, Воля, Мудрость)
- 6.3 Avatar display with equipment slots
- 6.4 Achievement system: unlock conditions + icon display
- 6.5 XP log + level-up history

### Phase 7: AI Mentor Chat
**Goal:** In-app chat with Claude using user progress context.

- 7.1 Chat UI screen
- 7.2 Edge Function: ai-mentor (send context → get response)
- 7.3 Context builder: last 7 days completed quests + current stats
- 7.4 Auto-trigger on app open (daily insight)
- 7.5 Manual trigger via FAB

### Phase 8: Polish & Animations
**Goal:** App feels alive — haptics, sounds, Rive animations.

- 8.1 Rive animation: quest completion effect
- 8.2 Lottie animation: level-up screen
- 8.3 Haptic feedback on all key interactions
- 8.4 Sound effects: menu tap, level-up, quest complete
- 8.5 Offline sync refinement (conflict resolution)
- 8.6 Performance audit + fix jank

## Status
- [ ] Phase A — Life Map
- [ ] Phase B — Character / Reflection 2D or 3D
- [ ] Phase C — Verified Actions
- [ ] Phase D — Extra Modes / Categories
- [ ] Phase E — Friends & Social Progress
- [ ] Phase F — System Retention
- [ ] Phase G — Onboarding Seriousness
- [ ] Phase 1 — Foundation
- [ ] Phase 2 — Supabase & Auth
- [ ] Phase 3 — Onboarding
- [ ] Phase 4 — Dashboard
- [ ] Phase 5 — Quest Engine
- [ ] Phase 6 — Character Sheet
- [ ] Phase 7 — AI Mentor
- [ ] Phase 8 — Polish
