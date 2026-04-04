-- Run this in Supabase SQL Editor (project: devgqjhlzkgexfwvxoej)
-- Goal: enable admin block/unblock + soft delete without dropping user data.

alter table if exists public.users
  add column if not exists u_status text not null default 'active',
  add column if not exists u_blocked_reason text,
  add column if not exists u_blocked_at timestamptz,
  add column if not exists u_deleted_at timestamptz;

-- Backfill status for existing rows.
update public.users
set u_status = coalesce(nullif(trim(u_status), ''), 'active')
where u_status is null or trim(u_status) = '';

-- Optional but recommended: keep status values constrained.
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'users_u_status_check'
  ) then
    alter table public.users
      add constraint users_u_status_check
      check (u_status in ('active', 'blocked', 'deleted'));
  end if;
end $$;

-- Helpful index for admin filtering.
create index if not exists idx_users_u_status on public.users(u_status);

-- NOTE:
-- If Row Level Security is enabled and admin updates are blocked,
-- add/update policies so your admin account can update users.u_status.
-- Policy details depend on your auth model (role in JWT, mapping table, etc.).
