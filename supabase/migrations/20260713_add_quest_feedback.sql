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
