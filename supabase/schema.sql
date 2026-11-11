-- The Chronicle: Supabase schema (v1)
-- Paste this whole file into Supabase > SQL Editor > New query > Run.
-- Design: small, friend-group scale. Each campaign / character keeps its full state as JSON,
-- so the app can add features without migrations. Realtime is switched on for live sync.

create extension if not exists pgcrypto;

-- Players (one row per signed-in account). Guests are handled in the app, not here.
create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  name text not null,
  created_at timestamptz default now()
);

-- Characters live outside campaigns. Global progression is inside data.progress;
-- campaign-owned full-sheet snapshots are stored in the campaign JSON data.
-- owner_id is null for guest characters (held by the DM until claimed).
create table if not exists characters (
  id text primary key,
  owner_id uuid references auth.users on delete set null,
  created_by text,
  data jsonb not null,
  updated_at timestamptz default now()
);

-- A campaign holds members, encounter, log, resources, prompts and shown pictures in data.
-- DM password is stored hashed, never in data.
create table if not exists campaigns (
  id text primary key,
  code text unique not null,
  name text not null,
  dm_id uuid references auth.users on delete set null,
  dm_name text,
  dm_email text,
  dm_pw_hash text not null,
  data jsonb not null,
  updated_at timestamptz default now()
);

create or replace function touch() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;
drop trigger if exists t1 on characters; create trigger t1 before update on characters for each row execute function touch();
drop trigger if exists t2 on campaigns;  create trigger t2 before update on campaigns  for each row execute function touch();

-- DM password helpers (so the hash never leaves the database)
create or replace function set_dm_password(camp text, pw text, email text) returns void
language sql security definer as $$
  update campaigns set dm_pw_hash = crypt(pw, gen_salt('bf')), dm_email = email where id = camp;
$$;
create or replace function check_dm_password(camp text, pw text) returns boolean
language sql security definer as $$
  select dm_pw_hash = crypt(pw, dm_pw_hash) from campaigns where id = camp;
$$;

-- Password recovery is handled by the send-dm-password Edge Function.
-- It emails a newly generated password to dm_email and never exposes hashes to the browser.
create table if not exists public.campaign_dm_password_reset_limits (
  campaign_id text primary key references public.campaigns(id) on delete cascade,
  requested_at timestamptz not null default now()
);
alter table public.campaign_dm_password_reset_limits enable row level security;
revoke all on public.campaign_dm_password_reset_limits from public, anon, authenticated;
grant all on public.campaign_dm_password_reset_limits to service_role;

create or replace function public.claim_campaign_dm_password_reset(camp text)
returns boolean
language plpgsql security definer set search_path = public as $$
declare claimed boolean := false;
begin
  insert into public.campaign_dm_password_reset_limits(campaign_id, requested_at)
  values (camp, now())
  on conflict (campaign_id) do update
    set requested_at = now()
    where public.campaign_dm_password_reset_limits.requested_at < now() - interval '15 minutes'
  returning true into claimed;
  return coalesce(claimed, false);
end;
$$;
revoke all on function public.claim_campaign_dm_password_reset(text) from public, anon, authenticated;
grant execute on function public.claim_campaign_dm_password_reset(text) to service_role;

create or replace function public.rotate_campaign_dm_password_for_email(camp text, pw text)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare previous_hash text; replacement_hash text;
begin
  if pw is null or length(pw) < 16 then return null; end if;
  select dm_pw_hash into previous_hash from public.campaigns where id = camp for update;
  if not found then return null; end if;
  update public.campaigns set dm_pw_hash = crypt(pw, gen_salt('bf'))
   where id = camp returning dm_pw_hash into replacement_hash;
  return jsonb_build_object('old_hash', previous_hash, 'new_hash', replacement_hash);
end;
$$;
revoke all on function public.rotate_campaign_dm_password_for_email(text, text) from public, anon, authenticated;
grant execute on function public.rotate_campaign_dm_password_for_email(text, text) to service_role;

create or replace function public.restore_campaign_dm_password_after_email_failure(camp text, expected_hash text, old_hash text)
returns boolean
language plpgsql security definer set search_path = public as $$
begin
  update public.campaigns set dm_pw_hash = old_hash
   where id = camp and dm_pw_hash = expected_hash;
  return found;
end;
$$;
revoke all on function public.restore_campaign_dm_password_after_email_failure(text, text, text) from public, anon, authenticated;
grant execute on function public.restore_campaign_dm_password_after_email_failure(text, text, text) to service_role;

-- Row level security: signed-in players can read and write the group's data.
-- (This is a trusted friend group. The DM password gates the DM screen inside the app.)
alter table profiles   enable row level security;
alter table characters enable row level security;
alter table campaigns  enable row level security;

create policy "profiles read"   on profiles   for select to authenticated using (true);
create policy "profiles write"  on profiles   for all    to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "chars all"       on characters for all    to authenticated using (true) with check (true);
create policy "camps all"       on campaigns  for all    to authenticated using (true) with check (true);

-- Guests use Supabase anonymous sign-in (Authentication > Providers > Anonymous), so they are
-- "authenticated" too and need no extra policies.

-- Live sync
alter publication supabase_realtime add table characters, campaigns;
