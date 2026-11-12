-- =====================================================================
-- Sua casa te representa? — Métricas anônimas (Supabase / PostgreSQL)
-- Execute no SQL Editor do Supabase.
--
-- Segurança:
--   • Visitantes (anon) só podem INSERIR eventos e comentários.
--   • Somente usuários autenticados presentes em public.admins podem LER.
--   • Ninguém pode editar ou apagar pela API pública.
--   • Não há fotos, nomes, e-mails ou textos livres do questionário aqui.
-- =====================================================================

create table if not exists public.events (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  client_ts   timestamptz,
  event       text not null check (event in (
                'page_view','journey_started','environment_selected','photo_uploaded',
                'ai_analysis_completed','interpretation_reacted','questionnaire_completed',
                'diagnosis_generated','report_viewed','experience_rated',
                'instagram_clicked','journey_abandoned')),
  session_id  uuid not null,
  visitor_id  uuid,
  environment text check (environment is null or environment in ('sala','quarto','cozinha')),
  step        text check (step is null or char_length(step) <= 32),
  props       jsonb not null default '{}'::jsonb check (pg_column_size(props) <= 4000)
);
create index if not exists events_created_at_idx on public.events (created_at);
create index if not exists events_event_idx      on public.events (event, created_at);
create index if not exists events_session_idx    on public.events (session_id);

create table if not exists public.feedback (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  session_id  uuid not null,
  rating      smallint not null check (rating between 1 and 5),
  comment     text not null check (char_length(comment) between 1 and 500)
);
create index if not exists feedback_created_at_idx on public.feedback (created_at);

-- Administradores do Painel de Insights (cadastre o user_id após criar o usuário em Authentication)
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.events   enable row level security;
alter table public.feedback enable row level security;
alter table public.admins   enable row level security;

-- Função auxiliar: o usuário atual é administrador?
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- Inserção anônima (somente inserção)
drop policy if exists events_insert_anyone on public.events;
create policy events_insert_anyone on public.events for insert to anon, authenticated with check (true);
drop policy if exists feedback_insert_anyone on public.feedback;
create policy feedback_insert_anyone on public.feedback for insert to anon, authenticated with check (true);

-- Leitura apenas para administradores
drop policy if exists events_read_admin on public.events;
create policy events_read_admin on public.events for select to authenticated using (public.is_admin());
drop policy if exists feedback_read_admin on public.feedback;
create policy feedback_read_admin on public.feedback for select to authenticated using (public.is_admin());
drop policy if exists admins_read_self on public.admins;
create policy admins_read_self on public.admins for select to authenticated using (user_id = auth.uid());

-- Permissões de tabela
revoke all on public.events, public.feedback, public.admins from anon, authenticated;
grant insert on public.events, public.feedback to anon, authenticated;
grant select on public.events, public.feedback, public.admins to authenticated;

-- ---------------------------------------------------------------------
-- Depois de criar o usuário administrador em Authentication → Users:
--   insert into public.admins (user_id) values ('<UUID-do-usuario>');
-- ---------------------------------------------------------------------
