create table if not exists public.application_ai_analysis (
  id bigserial primary key,
  application_id bigint references public.applications (a_id) on delete cascade,
  job_id bigint not null references public.jobs (j_id) on delete cascade,
  candidate_id bigint not null references public.candidates (c_id) on delete cascade,
  cv_url text not null,
  match_score integer not null default 0 check (match_score between 0 and 100),
  summary text not null default '',
  strengths jsonb not null default '[]'::jsonb,
  gaps jsonb not null default '[]'::jsonb,
  suggestions jsonb not null default '[]'::jsonb,
  cover_letter_tips jsonb not null default '[]'::jsonb,
  risk_flags jsonb not null default '[]'::jsonb,
  language_code text not null default 'vi',
  model text not null default 'gemini-2.5-flash',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.application_ai_analysis
  add column if not exists language_code text not null default 'vi';

drop index if exists public.application_ai_analysis_unique_cache_key;
create unique index if not exists application_ai_analysis_unique_cache_key
  on public.application_ai_analysis (application_id, job_id, cv_url, language_code);

create index if not exists application_ai_analysis_job_id_idx
  on public.application_ai_analysis (job_id);

create index if not exists application_ai_analysis_candidate_id_idx
  on public.application_ai_analysis (candidate_id);

alter table public.application_ai_analysis enable row level security;

drop policy if exists "Candidates can manage own AI analysis" on public.application_ai_analysis;
create policy "Candidates can manage own AI analysis"
  on public.application_ai_analysis
  for all
  using (
    exists (
      select 1
      from public.applications a
      join public.candidates c on c.c_id = a.c_id
      join public.users u on u.u_id = c.u_id
      where a.a_id = application_ai_analysis.application_id
        and u.auth_uid = auth.uid()
    )
  )
  with check (
    exists (
      select 1
      from public.applications a
      join public.candidates c on c.c_id = a.c_id
      join public.users u on u.u_id = c.u_id
      where a.a_id = application_ai_analysis.application_id
        and u.auth_uid = auth.uid()
    )
  );

drop policy if exists "Employers can manage own AI analysis" on public.application_ai_analysis;
create policy "Employers can manage own AI analysis"
  on public.application_ai_analysis
  for all
  using (
    exists (
      select 1
      from public.jobs j
      join public.employers e on e.e_id = j.e_id
      join public.users u on u.u_id = e.u_id
      where j.j_id = application_ai_analysis.job_id
        and u.auth_uid = auth.uid()
    )
  )
  with check (
    exists (
      select 1
      from public.jobs j
      join public.employers e on e.e_id = j.e_id
      join public.users u on u.u_id = e.u_id
      where j.j_id = application_ai_analysis.job_id
        and u.auth_uid = auth.uid()
    )
  );
