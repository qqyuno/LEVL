-- LEVL — Supabase Database Schema
-- Run this in Supabase Dashboard → SQL Editor
-- Last updated: 2026-04-01

-- =============================================
-- 1. Профиль пользователя
-- =============================================
create table if not exists profiles (
  id uuid references auth.users primary key,
  name text,
  goals text[],
  spheres text[],                          -- выбранные сферы ['discipline','knowledge',...]
  life_context text,
  main_goal text,
  work_style text,
  pain_points text,                        -- боли из онбординга (шаг 2)
  daily_minutes integer default 30,
  level integer default 1,
  xp integer default 0,
  current_streak integer default 0,
  tier text default 'free',                -- 'free' или 'pro'
  character_state jsonb default '{}',      -- состояние кастомизации персонажа
  created_at timestamptz default now()
);

-- RLS: пользователь видит только свой профиль
alter table profiles enable row level security;

create policy "Users can read own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);

-- =============================================
-- 2. Задачи (квесты)
-- =============================================
create table if not exists quests (
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
  success_criterion text not null default '',
  action_type text not null default 'routine'
    check (action_type in ('focus', 'movement', 'reflection', 'communication', 'result', 'routine')),
  verification_type text not null default 'self_confirm'
    check (verification_type in ('self_confirm', 'timer', 'location_timer')),
  verification_minutes integer not null default 0
    check (verification_minutes between 0 and 60),
  required_place_type text not null default ''
    check (required_place_type in ('', 'home', 'work', 'training', 'focus')),
  location_checks_passed integer not null default 0
    check (location_checks_passed between 0 and 10),
  last_location_check_at timestamptz,
  suggested_proof_type text not null default 'none'
    check (suggested_proof_type in ('none', 'text', 'link', 'image')),
  proof_prompt text not null default '',
  verification_status text not null default 'not_started'
    check (verification_status in ('not_started', 'in_progress', 'verified')),
  verification_started_at timestamptz,
  verified_at timestamptz,
  proof_type text not null default 'none'
    check (proof_type in ('none', 'text', 'link', 'image')),
  proof_value text not null default '',
  proof_image_name text not null default '',
  proof_storage_path text not null default '',
  proof_added_at timestamptz,
  created_at timestamptz default now(),
  completed_at timestamptz
);

alter table quests enable row level security;

create policy "Users can read own quests"
  on quests for select
  using (auth.uid() = user_id);

create policy "Users can insert own quests"
  on quests for insert
  with check (auth.uid() = user_id);

create policy "Users can update own quests"
  on quests for update
  using (auth.uid() = user_id);

-- =============================================
-- 3. Кеш задач (генерируются раз в день)
-- =============================================
create table if not exists quest_cache (
  user_id uuid references profiles,
  cache_key text,
  quests jsonb,
  generated_at timestamptz,
  primary key (user_id, cache_key)
);

alter table quest_cache enable row level security;

create policy "Users can read own cache"
  on quest_cache for select
  using (auth.uid() = user_id);

create policy "Users can upsert own cache"
  on quest_cache for insert
  with check (auth.uid() = user_id);

create policy "Users can update own cache"
  on quest_cache for update
  using (auth.uid() = user_id);

-- =============================================
-- 4. Ежедневный чекин
-- =============================================
create table if not exists daily_checkins (
  user_id uuid references profiles,
  date date,
  energy_level integer,
  primary key (user_id, date)
);

alter table daily_checkins enable row level security;

create policy "Users can manage own checkins"
  on daily_checkins for all
  using (auth.uid() = user_id);

-- =============================================
-- 5. Начисление XP (новая нелинейная кривая)
-- Уровень рассчитывается клиентом (levelFromXp),
-- Supabase хранит XP, клиент вычисляет уровень.
-- =============================================
create or replace function add_xp(p_user_id uuid, xp_amount integer)
returns void as $$
  update profiles
  set xp = xp + xp_amount
  where id = p_user_id;
$$ language sql security definer;

-- =============================================
-- 6. Почему задание не сработало
-- =============================================
create table if not exists quest_feedback (
  quest_id text references quests(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  reason text not null check (reason in ('too_hard', 'not_relevant', 'no_time')),
  created_at timestamptz default now(),
  primary key (user_id, quest_id)
);

alter table quest_feedback enable row level security;

create policy "Users can read own quest feedback"
  on quest_feedback for select
  using (auth.uid() = user_id);

create policy "Users can insert own quest feedback"
  on quest_feedback for insert
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from quests
      where quests.id = quest_id and quests.user_id = auth.uid()
    )
  );

create policy "Users can update own quest feedback"
  on quest_feedback for update
  using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from quests
      where quests.id = quest_id and quests.user_id = auth.uid()
    )
  );

-- =============================================
-- 7. Приватная продуктовая аналитика
-- =============================================
create table if not exists product_events (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  event_name text not null
    check (
      length(event_name) between 1 and 64
      and event_name ~ '^[a-z0-9_]+$'
    ),
  properties jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists product_events_user_created_idx
  on product_events (user_id, created_at desc);

create index if not exists product_events_name_created_idx
  on product_events (event_name, created_at desc);

alter table product_events enable row level security;

create policy "Users can insert own product events"
  on product_events for insert
  to authenticated
  with check (auth.uid() = user_id);
