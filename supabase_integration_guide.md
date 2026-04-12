# Takwa × Supabase — Professional Integration Guide

> **Stack**: Flutter · Drift (local SQLite) · Supabase (Postgres + Auth + Realtime + Storage)
> **Pattern**: **Offline-first** — every write hits Drift first, then syncs to Supabase in the background.

---

## 0. Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                 Flutter App                      │
│                                                  │
│  UI ──► Riverpod Providers                       │
│              │                                   │
│         ┌────▼─────────┐   sync   ┌───────────┐  │
│         │  Drift (DAO)  │ ──────► │ Supabase  │  │
│         │  (SQLite)     │ ◄────── │ Postgres  │  │
│         └──────────────┘  stream  └───────────┘  │
└──────────────────────────────────────────────────┘
```

- **Local first** → app works 100% offline with Drift
- **Background sync** → SyncService pushes dirty records to Supabase
- **Realtime** → Supabase Realtime pushes remote changes back
- **Auth** → Supabase Auth (email / Google / anonymous)

---

## 1. Supabase Project Setup

### 1.1 Create Project

1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Note your **Project URL** and **anon public key** (Settings → API)

### 1.2 Install CLI (optional but recommended)

```bash
# Windows (scoop)
scoop install supabase

# verify
supabase --version
```

---

## 2. Database Schema (Supabase Postgres)

Run in **SQL Editor → New Query**:

```sql
-- ─────────────────────────────────────────
--  Enable UUID extension
-- ─────────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ─────────────────────────────────────────
--  ENUM TYPES  (mirror Flutter enums)
-- ─────────────────────────────────────────
create type prayer_status as enum
  ('notDue','pending','performed','qadaa','missed');

create type fasting_type as enum
  ('none','fard','nafl','makruh');

create type prohibition_category as enum
  ('ghadhBasar','gheeba','nameema','kadhb','ghaDab','idaatWaqt','custom');

-- ─────────────────────────────────────────
--  TABLE: profiles
-- ─────────────────────────────────────────
create table profiles (
  id          uuid primary key references auth.users on delete cascade,
  display_name text,
  created_at  timestamptz default now()
);

-- ─────────────────────────────────────────
--  TABLE: daily_records
-- ─────────────────────────────────────────
create table daily_records (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid not null references profiles(id) on delete cascade,
  date            date not null,

  -- Prayers
  fajr_status     prayer_status not null default 'pending',
  dhuhr_status    prayer_status not null default 'pending',
  asr_status      prayer_status not null default 'pending',
  maghrib_status  prayer_status not null default 'pending',
  isha_status     prayer_status not null default 'pending',
  night_prayer    boolean not null default false,

  -- Quran
  quran_pages     int not null default 0,

  -- Adhkar
  morning_adhkar  boolean not null default false,
  evening_adhkar  boolean not null default false,

  -- Fasting
  fasting_type    fasting_type not null default 'none',

  -- Sadaqah
  sadaqah         boolean not null default false,

  -- Points
  taqwa_points    int not null default 0,
  deducted_points int not null default 0,
  net_points      int not null default 0,

  -- Notes
  notes           text,

  updated_at      timestamptz default now(),
  unique(user_id, date)
);

-- ─────────────────────────────────────────
--  TABLE: prohibitions_log
-- ─────────────────────────────────────────
create table prohibitions_log (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references profiles(id) on delete cascade,
  record_id   uuid not null references daily_records(id) on delete cascade,
  date        date not null,
  category    prohibition_category not null,
  committed   boolean not null default false,
  times_count int not null default 0,
  deduct_pts  int not null default 10,
  unique(record_id, category)
);

-- ─────────────────────────────────────────
--  updated_at trigger
-- ─────────────────────────────────────────
create or replace function handle_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_updated_at
  before update on daily_records
  for each row execute function handle_updated_at();

-- ─────────────────────────────────────────
--  Auto-create profile on sign-up
-- ─────────────────────────────────────────
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles(id)
  values (new.id)
  on conflict do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
```

---

## 3. Row Level Security (RLS)

> **Always enable RLS** — users may only see/edit their own rows.

```sql
-- daily_records
alter table daily_records enable row level security;

create policy "own records only"
  on daily_records for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- prohibitions_log
alter table prohibitions_log enable row level security;

create policy "own prohibitions only"
  on prohibitions_log for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- profiles
alter table profiles enable row level security;

create policy "own profile"
  on profiles for all
  using  (auth.uid() = id)
  with check (auth.uid() = id);
```

---

## 4. Flutter — Package Setup

### 4.1 Add to [pubspec.yaml](file:///c:/Users/imada/StudioProjects/muhasabah/pubspec.yaml)

```yaml
dependencies:
  supabase_flutter: ^2.5.0
  connectivity_plus: ^6.0.3 # detect online/offline
```

```bash
flutter pub get
```

### 4.2 Initialize in `main.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://YOUR_PROJECT.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
    // optional: custom headers, realtime config
  );

  runApp(const ProviderScope(child: MyApp()));
}

// Convenience accessor
final supabase = Supabase.instance.client;
```

> 💡 Store secrets in a `.env` file + `flutter_dotenv`, never hard-code in production.

---

## 5. Authentication

### 5.1 Providers

```dart
// lib/core/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider((_) => Supabase.instance.client);

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseProvider).auth.currentUser;
});
```

### 5.2 Sign In / Sign Up

```dart
// Email + Password
await supabase.auth.signUp(email: email, password: password);
await supabase.auth.signInWithPassword(email: email, password: password);

// Google
await supabase.auth.signInWithOAuth(OAuthProvider.google);

// Anonymous (great for onboarding)
await supabase.auth.signInAnonymously();

// Sign out
await supabase.auth.signOut();
```

### 5.3 Guard routes

```dart
// In your router / shell widget
final authState = ref.watch(authStateProvider);
authState.when(
  data: (state) => state.session != null ? const HomeShell() : const OnboardingScreen(),
  loading: () => const SplashScreen(),
  error: (_, __) => const OnboardingScreen(),
);
```

---

## 6. Sync Service (Offline-First)

### 6.1 `SyncService`

```dart
// lib/core/sync/sync_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../database/daos.dart';

class SyncService {
  final SupabaseClient _client;
  final DailyRecordDao _dao;

  SyncService(this._client, this._dao);

  // Push a single record to Supabase (upsert = insert or update)
  Future<void> pushRecord(DailyRecord record) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('daily_records').upsert({
      'user_id':         userId,
      'date':            record.date.toIso8601String().substring(0, 10),
      'fajr_status':     record.fajrStatus.name,
      'dhuhr_status':    record.dhuhrStatus.name,
      'asr_status':      record.asrStatus.name,
      'maghrib_status':  record.maghribStatus.name,
      'isha_status':     record.ishaStatus.name,
      'night_prayer':    record.nightPrayer,
      'quran_pages':     record.quranPages,
      'morning_adhkar':  record.morningAdhkar,
      'evening_adhkar':  record.eveningAdhkar,
      'fasting_type':    record.fastingType.name,
      'sadaqah':         record.sadaqah,
      'taqwa_points':    record.taqwaPoints,
      'deducted_points': record.deductedPoints,
      'net_points':      record.netPoints,
      'notes':           record.notes,
    }, onConflict: 'user_id,date');
  }

  // Pull latest 30 days from Supabase → write to Drift
  Future<void> pullRecent() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final rows = await _client
        .from('daily_records')
        .select()
        .eq('user_id', userId)
        .gte('date', DateTime.now().subtract(const Duration(days: 30))
            .toIso8601String().substring(0, 10))
        .order('date', ascending: false);

    for (final row in rows as List) {
      // Write into Drift (skipping recalc since data comes from server)
      await _dao.upsertFromRemote(row);
    }
  }
}
```

### 6.2 Add `upsertFromRemote` to your DAO

```dart
// In DailyRecordDao (daos.dart)
Future<void> upsertFromRemote(Map<String, dynamic> row) async {
  final date = DateTime.parse(row['date'] as String);
  await into(dailyRecords).insertOnConflictUpdate(DailyRecordsCompanion(
    date:           Value(date),
    fajrStatus:     Value(PrayerStatus.values.byName(row['fajr_status'])),
    dhuhrStatus:    Value(PrayerStatus.values.byName(row['dhuhr_status'])),
    asrStatus:      Value(PrayerStatus.values.byName(row['asr_status'])),
    maghribStatus:  Value(PrayerStatus.values.byName(row['maghrib_status'])),
    ishaStatus:     Value(PrayerStatus.values.byName(row['isha_status'])),
    nightPrayer:    Value(row['night_prayer'] as bool),
    quranPages:     Value(row['quran_pages'] as int),
    morningAdhkar:  Value(row['morning_adhkar'] as bool),
    eveningAdhkar:  Value(row['evening_adhkar'] as bool),
    fastingType:    Value(FastingType.values.byName(row['fasting_type'])),
    sadaqah:        Value(row['sadaqah'] as bool),
    taqwaPoints:    Value(row['taqwa_points'] as int),
    deductedPoints: Value(row['deducted_points'] as int),
    netPoints:      Value(row['net_points'] as int),
    notes:          Value(row['notes'] as String?),
    updatedAt:      Value(DateTime.now()),
  ));
}
```

### 6.3 Provider

```dart
// lib/core/providers/sync_providers.dart
final syncServiceProvider = Provider((ref) {
  return SyncService(
    ref.watch(supabaseProvider),
    ref.watch(dailyRecordDaoProvider),
  );
});
```

### 6.4 Trigger sync after every DAO write

Wrap your DAO writes in a helper that fires-and-forgets the push:

```dart
Future<void> _syncRecord(WidgetRef ref, int localId) async {
  final record = await ref.read(dailyRecordDaoProvider).getById(localId);
  if (record != null) {
    ref.read(syncServiceProvider).pushRecord(record).ignore();
  }
}
```

---

## 7. Realtime — Pull Remote Changes Live

Subscribe once (e.g., in your app shell) to stream changes from Supabase back to Drift:

```dart
// In your main shell initState / provider
final channel = supabase
    .channel('daily-records-changes')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'daily_records',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: supabase.auth.currentUser!.id,
      ),
      callback: (payload) {
        // Upsert into Drift
        if (payload.newRecord.isNotEmpty) {
          ref.read(dailyRecordDaoProvider)
              .upsertFromRemote(payload.newRecord)
              .ignore();
        }
      },
    )
    .subscribe();

// Dispose in dispose()
await channel.unsubscribe();
```

---

## 8. Storage (Profile Images, Exports)

```sql
-- In Supabase Dashboard → Storage → New Bucket
-- Name: "avatars", Public: false
```

```dart
// Upload avatar
final bytes = await imageFile.readAsBytes();
await supabase.storage
    .from('avatars')
    .uploadBinary('${userId}/avatar.jpg', bytes,
        fileOptions: const FileOptions(upsert: true));

// Get signed URL (1 hour)
final url = await supabase.storage
    .from('avatars')
    .createSignedUrl('${userId}/avatar.jpg', 3600);
```

---

## 9. Edge Functions (Server-side Logic)

Use Edge Functions for anything sensitive (point recalculation, weekly summary email, etc.).

### 9.1 Create a function

```bash
supabase functions new weekly-summary
```

```typescript
// supabase/functions/weekly-summary/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async req => {
	const supabase = createClient(
		Deno.env.get('SUPABASE_URL')!,
		Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
	);
	// ... your logic
	return new Response(JSON.stringify({ ok: true }), {
		headers: { 'Content-Type': 'application/json' },
	});
});
```

### 9.2 Call from Flutter

```dart
final response = await supabase.functions.invoke(
  'weekly-summary',
  body: {'userId': supabase.auth.currentUser!.id},
);
```

---

## 10. Project File Structure

```
lib/
├── core/
│   ├── database/
│   │   ├── app_database.dart     # Drift schema
│   │   ├── daos.dart             # + upsertFromRemote
│   │   └── app_database.g.dart
│   ├── providers/
│   │   ├── database_providers.dart
│   │   ├── auth_providers.dart   # NEW
│   │   └── sync_providers.dart   # NEW
│   ├── sync/
│   │   └── sync_service.dart     # NEW
│   └── theme/
│       └── app_theme.dart
└── features/
    ├── auth/
    │   ├── login_screen.dart     # NEW
    │   └── signup_screen.dart    # NEW
    └── checklist/
        └── checklist_screen.dart
```

---

## 11. Security Checklist

| ✅ | Item |

| ✅ | RLS enabled on every table |
| ✅ | `service_role` key never in Flutter code |
| ✅ | `anon` key only has SELECT on public data |
| ✅ | All writes validated by RLS `with check` |
| ✅ | Sensitive logic in Edge Functions, not client |
| ✅ | Signed URLs for private storage, not public URLs |
| ✅ | JWT verified server-side in Edge Functions |

---

## 12. Quick Reference — Supabase Flutter API

```dart
// Auth
supabase.auth.currentUser          // User?
supabase.auth.onAuthStateChange    // Stream<AuthState>

// Database
supabase.from('table').select()
supabase.from('table').insert({...})
supabase.from('table').upsert({...}, onConflict: 'col')
supabase.from('table').update({...}).eq('col', val)
supabase.from('table').delete().eq('col', val)

// Storage
supabase.storage.from('bucket').upload(path, file)
supabase.storage.from('bucket').createSignedUrl(path, seconds)

// Edge Functions
supabase.functions.invoke('fn-name', body: {...})

// Realtime
supabase.channel('name')
  .onPostgresChanges(event: ..., callback: ...)
  .subscribe()
```
