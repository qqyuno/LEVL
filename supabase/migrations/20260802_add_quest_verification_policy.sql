alter table quests
  add column if not exists action_type text not null default 'routine',
  add column if not exists verification_minutes integer not null default 0,
  add column if not exists suggested_proof_type text not null default 'none',
  add column if not exists proof_prompt text not null default '';

alter table quests
  drop constraint if exists quests_action_type_check;

alter table quests
  add constraint quests_action_type_check
  check (
    action_type in (
      'focus',
      'movement',
      'reflection',
      'communication',
      'result',
      'routine'
    )
  );

alter table quests
  drop constraint if exists quests_verification_minutes_check;

alter table quests
  add constraint quests_verification_minutes_check
  check (verification_minutes between 0 and 60);

alter table quests
  drop constraint if exists quests_suggested_proof_type_check;

alter table quests
  add constraint quests_suggested_proof_type_check
  check (suggested_proof_type in ('none', 'text', 'link', 'image'));
