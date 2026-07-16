alter table quests
  add column if not exists success_criterion text not null default '',
  add column if not exists verification_type text not null default 'self_confirm',
  add column if not exists verification_status text not null default 'not_started',
  add column if not exists verification_started_at timestamptz,
  add column if not exists verified_at timestamptz;

alter table quests
  drop constraint if exists quests_verification_type_check;

alter table quests
  add constraint quests_verification_type_check
  check (verification_type in ('self_confirm', 'timer'));

alter table quests
  drop constraint if exists quests_verification_status_check;

alter table quests
  add constraint quests_verification_status_check
  check (verification_status in ('not_started', 'in_progress', 'verified'));
