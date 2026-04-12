-- ──────────────────────────────────────────────────────────────────
--  MUHASABAH — Professional Supabase Schema
--  Author: Antigravity AI
--  Description: Full schema Migration for Professional Religious App
-- ──────────────────────────────────────────────────────────────────

-- 1. EXTENSIONS
create extension if not exists "uuid-ossp";

-- 2. ENUMS
do $$
begin
  if not exists (select 1 from pg_type where typname = 'prayer_status') then
    create type prayer_status as enum ('notDue','pending','performed','qadaa','missed');
  end if;
  if not exists (select 1 from pg_type where typname = 'fasting_type') then
    create type fasting_type as enum ('none','fard','nafl','makruh');
  end if;
  if not exists (select 1 from pg_type where typname = 'prohibition_category') then
    create type prohibition_category as enum ('ghadhBasar','gheeba','nameema','kadhb','ghaDab','idaatWaqt','custom');
  end if;
  if not exists (select 1 from pg_type where typname = 'taqwa_level') then
    create type taqwa_level as enum ('mubtadi','salik','mujahid','mutaqi');
  end if;
end$$;

-- 3. TABLES

-- 3.1 Profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  display_name text,
  avatar_url text,
  total_points int not null default 0,
  current_streak int not null default 0,
  highest_streak int not null default 0,
  level taqwa_level not null default 'mubtadi',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 3.2 Daily Records
create table if not exists public.daily_records (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  date date not null,
  
  -- Prayers
  fajr_status prayer_status not null default 'pending',
  dhuhr_status prayer_status not null default 'pending',
  asr_status prayer_status not null default 'pending',
  maghrib_status prayer_status not null default 'pending',
  isha_status prayer_status not null default 'pending',
  night_prayer boolean not null default false,
  witr boolean not null default false,
  rawatib int not null default 0,

  -- Quran
  quran_pages int not null default 0,
  quran_verses int not null default 0,
  quran_juzaa real not null default 0.0,

  -- Adhkar
  morning_adhkar boolean not null default false,
  evening_adhkar boolean not null default false,
  after_prayer_adhkar boolean not null default false,
  tasbeeh_count int not null default 0,

  -- Fasting
  fasting_type fasting_type not null default 'none',
  
  -- Sadaqah
  sadaqah boolean not null default false,
  sadaqah_amount real not null default 0.0,

  -- Points
  taqwa_points int not null default 0,
  deducted_points int not null default 0,
  net_points int not null default 0,

  -- Metadata
  notes text,
  mood text,
  updated_at timestamptz not null default now(),

  unique(user_id, date)
);

-- 3.3 Prohibitions Log
create table if not exists public.prohibitions_log (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  record_id uuid not null references public.daily_records(id) on delete cascade,
  date date not null,
  category prohibition_category not null,
  custom_name text,
  committed boolean not null default false,
  times_count int not null default 0,
  deduct_points int not null default 10,
  notes text,
  unique(record_id, category)
);

-- 3.4 Custom Ibadah
create table if not exists public.custom_ibadah (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name_ar text not null,
  emoji text not null default '⭐',
  is_positive boolean not null default true,
  points int not null default 5,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- 3.5 Custom Ibadah Log
create table if not exists public.custom_ibadah_log (
  id uuid primary key default uuid_generate_v4(),
  ibadah_id uuid not null references public.custom_ibadah(id) on delete cascade,
  record_id uuid not null references public.daily_records(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  date date not null,
  done boolean not null default false,
  count int not null default 1,
  unique(record_id, ibadah_id)
);

-- 3.6 Achievements
create table if not exists public.achievements (
  id uuid primary key default uuid_generate_v4(),
  type text unique not null,
  title_ar text not null,
  desc_ar text not null,
  emoji text not null,
  points_reward int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.user_achievements (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  achievement_id uuid not null references public.achievements(id) on delete cascade,
  earned_at timestamptz not null default now(),
  seen boolean not null default false,
  unique(user_id, achievement_id)
);

-- 3.7 Religious Content (Adhkar & Douaa)
create table if not exists public.adhkar_categories (
  id uuid primary key default uuid_generate_v4(),
  name_ar text not null,
  emoji text,
  sort_order int default 0
);

create table if not exists public.adhkar_content (
  id uuid primary key default uuid_generate_v4(),
  category_id uuid references public.adhkar_categories(id) on delete cascade,
  text_ar text not null,
  translation_ar text,
  count int default 1,
  reward_ar text,
  sort_order int default 0
);

create table if not exists public.douaa_categories (
  id uuid primary key default uuid_generate_v4(),
  name_ar text not null,
  emoji text,
  sort_order int default 0
);

create table if not exists public.douaa_content (
  id uuid primary key default uuid_generate_v4(),
  category_id uuid references public.douaa_categories(id) on delete cascade,
  title_ar text not null,
  text_ar text not null,
  reference text,
  sort_order int default 0
);

-- 3.8 User Settings
create table if not exists public.user_settings (
  user_id uuid references public.profiles(id) on delete cascade,
  key text not null,
  value text not null,
  primary key (user_id, key)
);

-- 4. VIEWS & FUNCTIONS

-- 4.1 Leaderboards View
create or replace view public.leaderboards as
select 
  p.id as user_id,
  p.display_name,
  p.avatar_url,
  p.total_points,
  p.level,
  rank() over (order by p.total_points desc) as rank
from public.profiles p;

-- 5. TRIGGERS & FUNCTIONS

-- 5.1 Handle Updated At
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.handle_updated_at();

create trigger set_daily_records_updated_at
  before update on public.daily_records
  for each row execute function public.handle_updated_at();

-- 5.2 Auto-create profile on sign-up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data->>'display_name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 6. ROW LEVEL SECURITY (RLS)

-- Profiles
alter table public.profiles enable row level security;
create policy "Public profiles are viewable by everyone." on public.profiles for select using (true);
create policy "Users can update own profile." on public.profiles for update using (auth.uid() = id);

-- Daily Records
alter table public.daily_records enable row level security;
create policy "Users can see own records." on public.daily_records for select using (auth.uid() = user_id);
create policy "Users can insert own records." on public.daily_records for insert with check (auth.uid() = user_id);
create policy "Users can update own records." on public.daily_records for update using (auth.uid() = user_id);
create policy "Users can delete own records." on public.daily_records for delete using (auth.uid() = user_id);

-- Prohibitions Log
alter table public.prohibitions_log enable row level security;
create policy "Users can see own prohibitions." on public.prohibitions_log for select using (auth.uid() = user_id);
create policy "Users can insert own prohibitions." on public.prohibitions_log for insert with check (auth.uid() = user_id);
create policy "Users can update own prohibitions." on public.prohibitions_log for update using (auth.uid() = user_id);

-- Custom Ibadah
alter table public.custom_ibadah enable row level security;
create policy "Users can see own custom ibadah." on public.custom_ibadah for select using (auth.uid() = user_id);
create policy "Users can insert own custom ibadah." on public.custom_ibadah for insert with check (auth.uid() = user_id);
create policy "Users can update own custom ibadah." on public.custom_ibadah for update using (auth.uid() = user_id);

-- User Achievements
alter table public.user_achievements enable row level security;
create policy "Users can see own achievements." on public.user_achievements for select using (auth.uid() = user_id);

-- Religious Content (Public Read)
alter table public.adhkar_categories enable row level security;
create policy "Allow public read" on public.adhkar_categories for select using (true);
alter table public.adhkar_content enable row level security;
create policy "Allow public read" on public.adhkar_content for select using (true);
alter table public.douaa_categories enable row level security;
create policy "Allow public read" on public.douaa_categories for select using (true);
alter table public.douaa_content enable row level security;
create policy "Allow public read" on public.douaa_content for select using (true);
alter table public.achievements enable row level security;
create policy "Allow public read" on public.achievements for select using (true);
