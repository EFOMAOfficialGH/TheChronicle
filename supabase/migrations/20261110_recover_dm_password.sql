-- Allows a signed-in user to reset a campaign DM password only when their
-- Supabase Auth email matches the campaign's stored backup email.
create or replace function public.recover_dm_password(camp text, pw text) returns boolean
language plpgsql security definer set search_path = public as $$
declare caller_email text := lower(coalesce(auth.jwt()->>'email',''));
begin
  if auth.uid() is null or caller_email = '' or length(pw) < 6 then return false; end if;
  update public.campaigns
     set dm_pw_hash = crypt(pw, gen_salt('bf'))
   where id = camp and lower(coalesce(dm_email,'')) = caller_email;
  return found;
end;
$$;
revoke all on function public.recover_dm_password(text,text) from public;
grant execute on function public.recover_dm_password(text,text) to authenticated;
