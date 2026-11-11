-- Make pgcrypto functions resolve whether the extension is installed in public or extensions.
alter function public.rotate_campaign_dm_password_for_email(text, text)
  set search_path = public, extensions;
