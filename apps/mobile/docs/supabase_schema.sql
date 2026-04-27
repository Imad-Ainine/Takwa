-- ─────────────────────────────────────────
--  Enable UUID extension
-- ─────────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ─────────────────────────────────────────
--  ENUM TYPES
-- ─────────────────────────────────────────
DO $$ BEGIN
  create type prayer_status as enum('notDue', 'pending', 'performed', 'qadaa', 'missed');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  create type fasting_type as enum('none', 'fard', 'nafl', 'makruh');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  create type prohibition_category as enum('ghadhBasar', 'gheeba', 'nameema', 'kadhb', 'ghaDab', 'idaatWaqt', 'custom');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  create type taqwa_level as enum('mubtadi', 'mutawassit', 'mutaqaddim');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ─────────────────────────────────────────
--  TABLES
-- ─────────────────────────────────────────

-- profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  total_points int not null default 0,
  current_streak int not null default 0,
  highest_streak int not null default 0,
  quran_pages int not null default 0,
  level taqwa_level not null default 'mubtadi',
  created_at timestamptz default now(),
  updated_at timestamptz not null default now()
);

-- user_settings
create table if not exists public.user_settings (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  madhab text default 'shafi',
  calc_method text default 'MWL',
  language text default 'ar',

  prayer_reminder boolean default true,
  pre_adhan_notif boolean default true,
  iqama_notif boolean default true,

  wake_up_before_fajr boolean default false,
  wake_up_time text default '04:30',

  morning_adhkar_reminder boolean default true,
  evening_adhkar_reminder boolean default true,

  adhkar_notif_enabled boolean default true,
  morning_adhkar_time text default '06:30',
  evening_adhkar_time text default '17:00',
  sleep_adhkar_time text default '22:00',
  after_fajr_adhkar boolean default true,
  after_asr_adhkar boolean default true,

  muhasaba_reminder boolean default true,
  evening_reminder_time text default '21:00',

  daily_duas_on boolean default true,
  special_reminders_on boolean default true,
  fasting_reminders_on boolean default true,

  ramadan_mode boolean default false,
  theme_mode text default 'system',
  adhan_sound text default 'Adhan-Makkah.mp3',

  -- overlay / in-screen settings
  overlay_popups_enabled boolean default true,
  adhan_sound_enabled boolean default true,
  adhan_screen_enabled boolean default true,
  popup_interval_minutes int default 24,

  favorite_adhkar int[] default '{}',
  favorite_duas int[] default '{}',
  updated_at timestamptz default now()
);

-- achievements (Earned per user)
create table if not exists public.achievements (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null,
  title_ar text not null,
  desc_ar text not null,
  emoji text not null,
  points_reward int not null default 0,
  earned_at timestamptz not null default now(),
  seen boolean not null default false,
  unique (user_id, type)
);

-- daily_records
create table if not exists public.daily_records (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  date date not null,
  fajr_status prayer_status not null default 'pending',
  dhuhr_status prayer_status not null default 'pending',
  asr_status prayer_status not null default 'pending',
  maghrib_status prayer_status not null default 'pending',
  isha_status prayer_status not null default 'pending',
  night_prayer boolean not null default false,
  witr boolean not null default false,
  rawatib int not null default 0,
  quran_pages int not null default 0,
  quran_verses int not null default 0,
  quran_juzaa real not null default 0.0,
  morning_adhkar boolean not null default false,
  evening_adhkar boolean not null default false,
  after_prayer_adhkar boolean not null default false,
  tasbeeh_count int not null default 0,
  fasting_type fasting_type not null default 'none',
  sadaqah boolean not null default false,
  sadaqah_amount real not null default 0.0,
  taqwa_points int not null default 0,
  deducted_points int not null default 0,
  net_points int not null default 0,
  mood text,
  notes text,
  updated_at timestamptz default now(),
  unique (user_id, date)
);

-- prohibitions_log
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
  unique (record_id, category)
);

-- custom_ibadah
create table if not exists public.custom_ibadah (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name_ar text not null,
  emoji text default '⭐',
  is_positive boolean default true,
  points int default 5,
  is_active boolean default true,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- custom_ibadah_log
create table if not exists public.custom_ibadah_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  ibadah_id uuid references public.custom_ibadah(id) on delete cascade,
  date date not null,
  done boolean default false,
  count int default 1,
  created_at timestamptz default now()
);

-- adhkar_categories
create table if not exists public.adhkar_categories (
  id uuid primary key default uuid_generate_v4(),
  name_ar text not null,
  emoji text,
  sort_order int default 0
);

-- adhkar
create table if not exists public.adhkar (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.adhkar_categories(id) on delete cascade,
  category text not null,
  title text not null,
  text text not null,
  translation text,
  benefits text,
  recommended_count int default 1,
  sort_order int default 0,
  source text,
  code int
);

-- douaa_categories
create table if not exists public.douaa_categories (
  id uuid primary key default uuid_generate_v4(),
  name_ar text not null,
  emoji text,
  sort_order int default 0
);

-- douaa_content
create table if not exists public.douaa_content (
  id uuid primary key default uuid_generate_v4(),
  category_id uuid references public.douaa_categories(id) on delete cascade,
  title_ar text not null,
  text_ar text not null,
  reference text,
  sort_order int default 0
);

-- asma_allah
create table if not exists public.asma_allah (
  number int primary key,
  name text not null,
  transliteration text,
  meaning text,
  explanation text,
  dua text,
  quran_ref text
);

-- user_adhkar
create table if not exists public.user_adhkar (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  text_ar text not null,
  count int not null default 1,
  category_hint text default 'general',
  created_at timestamptz not null default now()
);

-- user_duas
create table if not exists public.user_duas (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title_ar text not null,
  text_ar text not null,
  occasion text default '',
  source text default '',
  emoji text default '🤲',
  created_at timestamptz not null default now()
);

-- community_adhkar
create table if not exists public.community_adhkar (
  id uuid primary key default uuid_generate_v4(),
  shared_by uuid not null references public.profiles(id) on delete cascade,
  text_ar text not null,
  count int not null default 1,
  category_hint text default 'general',
  likes int not null default 0,
  approved boolean not null default true,
  created_at timestamptz not null default now()
);

-- community_duas
create table if not exists public.community_duas (
  id uuid primary key default uuid_generate_v4(),
  shared_by uuid not null references public.profiles(id) on delete cascade,
  title_ar text not null,
  text_ar text not null,
  occasion text default '',
  source text default '',
  emoji text default '🤲',
  likes int not null default 0,
  approved boolean not null default true,
  created_at timestamptz not null default now()
);


-- ─────────────────────────────────────────
--  updated_at trigger
-- ─────────────────────────────────────────
create or replace function handle_updated_at () returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_updated_at on daily_records;
create trigger set_updated_at before update on daily_records for each row execute function handle_updated_at ();

drop trigger if exists set_updated_at on user_settings;
create trigger set_updated_at before update on user_settings for each row execute function handle_updated_at ();

drop trigger if exists set_updated_at on profiles;
create trigger set_updated_at before update on profiles for each row execute function handle_updated_at ();

-- ─────────────────────────────────────────
--  Auto-create profile on sign-up
-- ─────────────────────────────────────────
create or replace function handle_new_user () returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles(id)
  values (new.id)
  on conflict do nothing;
  
  insert into public.user_settings(user_id)
  values (new.id)
  on conflict do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users for each row
execute function handle_new_user ();

-- ─────────────────────────────────────────
--  ROW LEVEL SECURITY (RLS) POLICIES
-- ─────────────────────────────────────────

-- profiles
alter table public.profiles enable row level security;
drop policy if exists "own profile" on public.profiles;
create policy "own profile" on public.profiles for all using (auth.uid() = id) with check (auth.uid() = id);

-- user_settings
alter table public.user_settings enable row level security;
drop policy if exists "own settings" on public.user_settings;
create policy "own settings" on public.user_settings for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- achievements (Per user)
alter table public.achievements enable row level security;
drop policy if exists "own achievements" on public.achievements;
create policy "own achievements" on public.achievements for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- daily_records
alter table public.daily_records enable row level security;
drop policy if exists "own records only" on public.daily_records;
create policy "own records only" on public.daily_records for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- prohibitions_log
alter table public.prohibitions_log enable row level security;
drop policy if exists "own prohibitions only" on public.prohibitions_log;
create policy "own prohibitions only" on public.prohibitions_log for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- custom_ibadah
alter table public.custom_ibadah enable row level security;
drop policy if exists "own custom_ibadah" on public.custom_ibadah;
create policy "own custom_ibadah" on public.custom_ibadah for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- custom_ibadah_log
alter table public.custom_ibadah_log enable row level security;
drop policy if exists "own custom_ibadah_log" on public.custom_ibadah_log;
create policy "own custom_ibadah_log" on public.custom_ibadah_log for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- adhkar_categories
alter table public.adhkar_categories enable row level security;
drop policy if exists "viewable by all adhkar_categories" on public.adhkar_categories;
create policy "viewable by all adhkar_categories" on public.adhkar_categories for select using (true);

-- adhkar
alter table public.adhkar enable row level security;
drop policy if exists "viewable by all adhkar" on public.adhkar;
create policy "viewable by all adhkar" on public.adhkar for select using (true);

-- douaa_categories
alter table public.douaa_categories enable row level security;
drop policy if exists "viewable by all douaa_categories" on public.douaa_categories;
create policy "viewable by all douaa_categories" on public.douaa_categories for select using (true);

-- douaa_content
alter table public.douaa_content enable row level security;
drop policy if exists "viewable by all douaa_content" on public.douaa_content;
create policy "viewable by all douaa_content" on public.douaa_content for select using (true);

-- asma_allah
alter table public.asma_allah enable row level security;
drop policy if exists "viewable by all asma_allah" on public.asma_allah;
create policy "viewable by all asma_allah" on public.asma_allah for select using (true);

-- user_adhkar
alter table public.user_adhkar enable row level security;
drop policy if exists "Users can see own adhkar." on public.user_adhkar;
drop policy if exists "Users can insert own adhkar." on public.user_adhkar;
drop policy if exists "Users can update own adhkar." on public.user_adhkar;
drop policy if exists "Users can delete own adhkar." on public.user_adhkar;
create policy "Users can see own adhkar." on public.user_adhkar for select using (auth.uid() = user_id);
create policy "Users can insert own adhkar." on public.user_adhkar for insert with check (auth.uid() = user_id);
create policy "Users can update own adhkar." on public.user_adhkar for update using (auth.uid() = user_id);
create policy "Users can delete own adhkar." on public.user_adhkar for delete using (auth.uid() = user_id);

-- user_duas
alter table public.user_duas enable row level security;
drop policy if exists "Users can see own duas." on public.user_duas;
drop policy if exists "Users can insert own duas." on public.user_duas;
drop policy if exists "Users can update own duas." on public.user_duas;
drop policy if exists "Users can delete own duas." on public.user_duas;
create policy "Users can see own duas." on public.user_duas for select using (auth.uid() = user_id);
create policy "Users can insert own duas." on public.user_duas for insert with check (auth.uid() = user_id);
create policy "Users can update own duas." on public.user_duas for update using (auth.uid() = user_id);
create policy "Users can delete own duas." on public.user_duas for delete using (auth.uid() = user_id);

-- community_adhkar
alter table public.community_adhkar enable row level security;
drop policy if exists "Community adhkar viewable by all." on public.community_adhkar;
drop policy if exists "Users can share adhkar." on public.community_adhkar;
drop policy if exists "Owners can delete own shared adhkar." on public.community_adhkar;
create policy "Community adhkar viewable by all." on public.community_adhkar for select using (approved = true);
create policy "Users can share adhkar." on public.community_adhkar for insert with check (auth.uid() = shared_by);
create policy "Owners can delete own shared adhkar." on public.community_adhkar for delete using (auth.uid() = shared_by);

-- community_duas
alter table public.community_duas enable row level security;
drop policy if exists "Community duas viewable by all." on public.community_duas;
drop policy if exists "Users can share duas." on public.community_duas;
drop policy if exists "Owners can delete own shared duas." on public.community_duas;
create policy "Community duas viewable by all." on public.community_duas for select using (approved = true);
create policy "Users can share duas." on public.community_duas for insert with check (auth.uid() = shared_by);
create policy "Owners can delete own shared duas." on public.community_duas for delete using (auth.uid() = shared_by);
