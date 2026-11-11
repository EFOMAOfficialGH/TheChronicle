-- Replace the old account-email-gated password reset with an emailed generated-password flow.
-- The helper RPCs are callable only by service_role, from the Edge Function.

drop function if exists public.recover_dm_password(text, text);

create or replace function public.rotate_campaign_dm_password_for_email(camp text, pw text)
returns jsonb
language plpgsql security definer set search_path = public, extensions as $$
declare previous_hash text; replacement_hash text;
begin
  if pw is null or length(pw) < 16 then return null; end if;
  select dm_pw_hash into previous_hash from public.campaigns where id = camp for update;
  if not found then return null; end if;
  update public.campaigns
     set dm_pw_hash = crypt(pw, gen_salt('bf'))
   where id = camp
   returning dm_pw_hash into replacement_hash;
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
