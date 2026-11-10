# The Chronicle: working notes (for Claude and Manus)

Read this first, then keep it updated at the end of each session.

## What it is
A D&D companion web app for Mohammed's group (PC and mobile, mostly in person, usable online).
Name must always be **The Chronicle**. Look: gothic, near-black, aged gold (players) and blood red (DM).

## Stack
- Hosting: Cloudflare Pages (static, no build step). Deploys on every push to `main`.
- Backend: Supabase (auth, Postgres, realtime). Schema in `supabase/schema.sql`.
- Code: a single `index.html` (vanilla JS, no framework). State lives in the `S` object plus `chars[]` and `camps[]`;
  `render()` rewrites `#app` and `#modal`. Clicks use `data-a` -> `A{}` actions, inputs use `data-c` -> `C{}`.

## Rules for editing
- Keep it one file until it gets painful. Small, tested changes. Do not rename the app.
- Never commit the Supabase `service_role` key. The `anon` key and project URL are fine to commit.
- No `alert/confirm`; use the in-app confirm modal.

## Status
- Done: campaigns, accounts UI, characters (+ per-campaign progress), DM tools (party, encounter with start/end and initiative
  prompt, rolls with adv/dis, resources, log, assignments dropdown), player tabs, dice with modifiers, skills clickable.
- Done (v1 cloud): Supabase wired in `index.html` (sign up / sign in / guest, load everything at login, debounced save of changed
  characters and campaigns, realtime updates, DM password via `check_dm_password` / `set_dm_password`). Falls back to demo mode
  when Supabase is unreachable (e.g. the Claude artifact preview) so the UI can still be tested.
- Known limits: each campaign is one JSON row, so two people editing the same campaign in the same moment can overwrite each other
  (last write wins). If that bites, split log / combatants / prompts into their own tables. Uploaded pictures are shrunk to 640px.
- Supabase Auth: "Confirm email" should be OFF for signups to log in instantly (Authentication > Providers > Email). Anonymous sign-ins ON.
- Next: PWA install, split hot data into tables if needed, SRD content, image generator link.

## Decisions
- DM password is hashed in Supabase (`set_dm_password` / `check_dm_password`); reset link goes to the backup email.
- Guest characters are held by the DM and can be handed over to an account later.
- Temporary control swaps never change ownership and never show in a player's Characters tab.
