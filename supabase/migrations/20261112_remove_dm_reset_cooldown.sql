-- The app no longer imposes a per-campaign waiting period on password emails.
drop function if exists public.claim_campaign_dm_password_reset(text);
drop table if exists public.campaign_dm_password_reset_limits;
