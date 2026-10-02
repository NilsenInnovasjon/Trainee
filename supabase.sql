-- Trainee-køen: database-oppsett for Supabase
-- Lim inn alt i SQL Editor i Supabase og trykk "Run".

-- Hvem som er trainee (alle andre innloggede regnes som meglere)
create table public.roles (
  user_id uuid primary key references auth.users on delete cascade,
  role text not null check (role in ('megler', 'trainee')),
  name text not null
);

-- Ansatte med bilde (velgeren "Hvem er du?")
create table public.staff (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  photo_url text,
  created_at timestamptz not null default now()
);

-- Oppgavene i køen
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  address text not null default '',
  description text not null default '',
  extra text not null default '',
  due date not null,
  due_time text not null default '',
  requested_by text not null,
  requested_by_id uuid references public.staff on delete set null,
  status text not null default 'queue' check (status in ('queue', 'working', 'done')),
  assignee text,
  started_at timestamptz,
  done_at timestamptz,
  created_at timestamptz not null default now()
);

create or replace function public.is_trainee()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.roles where user_id = auth.uid() and role = 'trainee');
$$;

alter table public.roles enable row level security;
alter table public.staff enable row level security;
alter table public.tasks enable row level security;

-- Roller: hver bruker kan bare lese sin egen
create policy "les egen rolle" on public.roles for select to authenticated using (user_id = auth.uid());

-- Ansatte: alle innloggede ser listen, bare trainees endrer den
create policy "alle ser ansatte" on public.staff for select to authenticated using (true);
create policy "trainee legger til ansatte" on public.staff for insert to authenticated with check (public.is_trainee());
create policy "trainee endrer ansatte" on public.staff for update to authenticated using (public.is_trainee()) with check (public.is_trainee());
create policy "trainee fjerner ansatte" on public.staff for delete to authenticated using (public.is_trainee());

-- Oppgaver: alle innloggede ser og legger inn, bare trainees plukker, fullfører og sletter
create policy "alle ser oppgaver" on public.tasks for select to authenticated using (true);
create policy "alle legger inn i køen" on public.tasks for insert to authenticated
  with check (status = 'queue' and assignee is null and started_at is null and done_at is null);
create policy "trainee endrer oppgaver" on public.tasks for update to authenticated
  using (public.is_trainee()) with check (public.is_trainee());
create policy "trainee sletter oppgaver" on public.tasks for delete to authenticated using (public.is_trainee());

-- Sanntid: siden oppdateres for alle når noe endres
alter publication supabase_realtime add table public.tasks, public.staff;

-- Bildelager for nye ansattbilder
insert into storage.buckets (id, name, public) values ('bilder', 'bilder', true);
create policy "trainee laster opp bilder" on storage.objects for insert to authenticated
  with check (bucket_id = 'bilder' and public.is_trainee());

-- Meglerne ved Kristiansand-kontoret (bildene ligger i bilder/-mappa på GitHub)
insert into public.staff (name, photo_url) values
  ('Jon Fadnes', 'bilder/jon-fadnes.jpg'),
  ('Camilla Wehus Hennig-Olsen', 'bilder/camilla-wehus-hennig-olsen.jpg'),
  ('Eivind Bjorå', 'bilder/eivind-bjora.jpg'),
  ('Remi Bangsund', 'bilder/remi-bangsund.jpg'),
  ('Espen Bjørndahl', 'bilder/espen-bjorndahl.jpg'),
  ('Dawoud Mohammadi', 'bilder/dawoud-mohammadi.jpg'),
  ('Azra Hadzic', 'bilder/azra-hadzic.jpg'),
  ('Anders Rønn Skajaa', 'bilder/anders-ronn-skajaa.jpg');
