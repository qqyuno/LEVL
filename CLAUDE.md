# LEVL — Personal System

## Концепт продукта
Приложение геймификации жизни. Пользователь видит это как личную систему прокачки себя — не как трекер задач.

**Язык бренда — что говорим / не говорим:**
- Говорим: Система, Путь, Зафиксировано, Уровень, Отражение, Задача
- НЕ говорим: геймификация, квест, герой, игра, мотивация, прокачка

**Голос AI в приложении:** короткий, курсив, от лица Системы.
- "Три задачи. Этого достаточно."
- "Семь дней. Ты уже не тот."
- "Система ждала. Продолжим."

---

## Визуальный стиль
- **Палитра:** белый фон #F8F8F6, чёрный #0A0A0A, линии #E2E2DE, золото #B8962E ТОЛЬКО для наград
- **Шрифты:** DM Serif Display (заголовки, уровни, логотип), DM Sans (весь UI)
- **Принцип:** Apple-минимализм — пространство важнее украшений

---

## Технический стек
- **Frontend:** Flutter (Dart)
- **State Management:** Riverpod
- **Локальная БД:** Isar (offline-first)
- **Анимации:** Rive + Lottie
- **Backend:** Supabase (Auth + PostgreSQL + Edge Functions + Realtime)
- **AI:** Anthropic Claude API (claude-sonnet-4-20250514) через Supabase Edge Functions
- **Навигация:** GoRouter

---

## Структура проекта (Flutter)
```
levl/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/              # ThemeData, цвета, типографика
│   │   ├── router/             # GoRouter маршруты
│   │   └── supabase/           # Supabase клиент
│   ├── features/
│   │   ├── onboarding/         # 7 экранов онбординга
│   │   ├── dashboard/          # главный экран + квесты
│   │   ├── character/          # Character Sheet
│   │   └── ai_mentor/          # чат с AI-ментором
│   └── shared/
│       ├── models/             # User, Quest, Achievement
│       └── widgets/            # QuestCard, XPBar, AvatarWidget
├── assets/
│   ├── character/              # PNG слои персонажа
│   └── animations/             # Rive/Lottie файлы
└── supabase/
    └── functions/
        └── generate-quests/
            └── index.ts        # Edge Function → Claude API
```

---

## База данных Supabase (нужно создать)
```sql
-- Профиль пользователя
create table profiles (
  id uuid references auth.users primary key,
  name text,
  goals text[],
  life_context text,
  main_goal text,
  work_style text,
  daily_minutes integer default 30,
  level integer default 1,
  xp integer default 0,
  current_streak integer default 0,
  character_state jsonb,  -- состояние кастомизации персонажа
  created_at timestamptz default now()
);

-- Задачи дня
create table quests (
  id text primary key,
  user_id uuid references profiles,
  title text,
  description text,
  category text,
  xp integer,
  difficulty text,
  type text,
  tip text,
  status text default 'pending',
  estimated_minutes integer,
  created_at timestamptz default now(),
  completed_at timestamptz
);

-- Кеш задач (генерируются раз в день)
create table quest_cache (
  user_id uuid references profiles,
  cache_key text,
  quests jsonb,
  generated_at timestamptz,
  primary key (user_id, cache_key)
);

-- Ежедневный чекин
create table daily_checkins (
  user_id uuid references profiles,
  date date,
  energy_level integer,
  primary key (user_id, date)
);

-- Начисление XP
create or replace function add_xp(user_id uuid, xp_amount integer)
returns void as $$
  update profiles
  set
    xp = xp + xp_amount,
    level = floor((xp + xp_amount) / 100) + 1
  where id = user_id;
$$ language sql;
```

---

## Готовые файлы (нужно портировать на Flutter)
- `supabase/functions/generate-quests/index.ts` — Edge Function вызывает Claude API (логика сохраняется)
- Старые `.tsx` файлы (React Native) — служат референсом логики, переписываются на Dart

---

## Онбординг (5 шагов)
1. Где ты сейчас? (контекст жизни — не "выбери класс")
2. Что тормозит? (боль — не "выбери слабость")
3. Как ты работаешь? (стиль — не "тип героя")
4. Куда через год? (свободный текст — главная цель)
5. Сколько времени в день? (ресурс — не "сложность игры")

---

## Система наград
- XP за каждую задачу (10–200 в зависимости от сложности)
- Уровень = floor(XP / 100) + 1
- Одежда для персонажа разблокируется за реальные достижения (нельзя купить)
- Золото (#B8962E) только для заработанных предметов
- Скрытые ачивменты за паттерны поведения

---

## Переменные окружения
```
# Flutter: через flutter_dotenv или --dart-define
SUPABASE_URL=твой_url
SUPABASE_ANON_KEY=твой_ключ
# Только в Supabase Secrets (не во Flutter):
ANTHROPIC_API_KEY=твой_ключ
```

---

## Приоритет разработки (Flutter Roadmap)
1. Flutter проект + архитектура (Riverpod + GoRouter + Isar + ThemeData Dark Fantasy)
2. Supabase клиент + авторизация Google/Apple
3. Онбординг (7 экранов) → AI генерация начального состояния → сохранение профиля
4. Dashboard: квесты + XP + streak + Edge Function
5. Character Sheet: 6 характеристик + экипировка
6. AI-ментор: чат с контекстом прогресса
7. Polish: Rive/Lottie анимации, Haptic Feedback, звуки
