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

drop policy if exists "Users can insert own product events" on product_events;
create policy "Users can insert own product events"
  on product_events for insert
  to authenticated
  with check (auth.uid() = user_id);
