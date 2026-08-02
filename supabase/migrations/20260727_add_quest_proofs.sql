alter table quests
  add column if not exists proof_type text not null default 'none',
  add column if not exists proof_value text not null default '',
  add column if not exists proof_image_name text not null default '',
  add column if not exists proof_storage_path text not null default '',
  add column if not exists proof_added_at timestamptz;

alter table quests
  drop constraint if exists quests_proof_type_check;

alter table quests
  add constraint quests_proof_type_check
  check (proof_type in ('none', 'text', 'link', 'image'));

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'quest-proofs',
  'quest-proofs',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Users can upload own quest proofs" on storage.objects;
create policy "Users can upload own quest proofs"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'quest-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Users can read own quest proofs" on storage.objects;
create policy "Users can read own quest proofs"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'quest-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Users can replace own quest proofs" on storage.objects;
create policy "Users can replace own quest proofs"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'quest-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'quest-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Users can delete own quest proofs" on storage.objects;
create policy "Users can delete own quest proofs"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'quest-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
