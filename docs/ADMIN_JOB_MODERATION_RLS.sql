-- Ensure admins can moderate jobs (approve/reject/unpublish) via app client.
-- Run in Supabase SQL Editor for the project your app is connected to.

-- 1) Enable RLS (safe if already enabled)
alter table public.jobs enable row level security;

-- 2) Drop old policy if it exists (idempotent)
drop policy if exists "Admins can moderate jobs" on public.jobs;

-- 3) Allow authenticated admins to update any job
-- Assumes public.users has columns: auth_uid (uuid), u_role (text)
create policy "Admins can moderate jobs"
on public.jobs
for update
to authenticated
using (
  exists (
    select 1
    from public.users u
    where u.auth_uid = auth.uid()
      and lower(coalesce(u.u_role, '')) = 'admin'
  )
)
with check (
  exists (
    select 1
    from public.users u
    where u.auth_uid = auth.uid()
      and lower(coalesce(u.u_role, '')) = 'admin'
  )
);

-- 4) Optional: admins can delete any job if hard-delete is used
-- Uncomment only if you want to allow DELETE physically.
-- drop policy if exists "Admins can delete jobs" on public.jobs;
-- create policy "Admins can delete jobs"
-- on public.jobs
-- for delete
-- to authenticated
-- using (
--   exists (
--     select 1
--     from public.users u
--     where u.auth_uid = auth.uid()
--       and lower(coalesce(u.u_role, '')) = 'admin'
--   )
-- );
