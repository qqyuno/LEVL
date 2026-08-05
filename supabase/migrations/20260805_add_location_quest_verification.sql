alter table quests
  add column if not exists required_place_type text not null default '',
  add column if not exists location_checks_passed integer not null default 0,
  add column if not exists last_location_check_at timestamptz;

alter table quests
  drop constraint if exists quests_verification_type_check;

alter table quests
  add constraint quests_verification_type_check
  check (verification_type in ('self_confirm', 'timer', 'location_timer'));

alter table quests
  drop constraint if exists quests_required_place_type_check;

alter table quests
  add constraint quests_required_place_type_check
  check (required_place_type in ('', 'home', 'work', 'training', 'focus'));

alter table quests
  drop constraint if exists quests_location_checks_passed_check;

alter table quests
  add constraint quests_location_checks_passed_check
  check (location_checks_passed between 0 and 10);
