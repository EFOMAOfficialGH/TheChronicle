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

-- Characters live outside campaigns. Per-campaign progress is inside data.prog.
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
