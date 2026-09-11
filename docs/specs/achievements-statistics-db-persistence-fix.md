# Spec: Fix Achievements/Statistics Not Persisting ("save today, gone tomorrow")

## 0. Implementation status (updated after a second implementation pass)

- **R1 (only apply a pull if the remote row is actually newer) — done (first pass).**
  `DailyRecordDao.upsertFromRemote()` compares the remote `updated_at` against the local row's
  `updatedAt` and skips the pull if the local copy is at least as fresh — the actual fix for "log a
  day, it's gone the next day." See `sync_manager.dart`/`daos.dart` git history for that commit.
- **R2/R3 (pending-push outbox + retry, and blocking a pull while a push is pending) — done
  (second pass).** Added a generic `SyncOutbox` table (`app_database.dart`, schema v9) keyed by
  `(entityTable, entityKey)` rather than a bool column per table, per this spec's own suggestion —
  covers `daily_records` (key: ISO date), `achievements`, and `custom_ibadah_log` (key: local row
  id). `syncDailyRecord`/`syncAchievement`/`syncCustomIbadahLog`/`syncProhibition` now mark an
  entity pending on failure and clear it on success; `_syncDailyRecords`/`_syncCustomIbadah`/
  `_syncProhibitions` retry every pending entity for their table before doing their normal
  last-N-days push. `DailyRecordDao.upsertFromRemote` now skips a pull entirely for any date that
  still has a pending outbox entry (R3), rather than only comparing timestamps.
- **R4 (push/pull the previously-commented-out fields) — done, except `ghadh_basar` which
  genuinely is still blocked.** Checked `apps/mobile/docs/schema.sql` directly: `witr`, `rawatib`,
  `quran_verses`, `quran_juzaa`, `after_prayer_adhkar`, `tasbeeh_count`, `sadaqah_amount`,
  `deducted_points`, and `mood` all already exist on the remote `daily_records` table — the
  original spec's "blocked on a migration" framing was wrong for these nine; they were just
  commented out. Uncommented in `syncDailyRecord` (push) and added symmetrically to
  `upsertFromRemote` (pull). `ghadh_basar` is the one field confirmed **not** present remotely
  (absent from `docs/schema.sql`'s column list) — left commented out with a note; still needs an
  actual Supabase migration.
- **R5 (per-step isolation in `fullSync()`) — done.** All eleven `fullSync()` steps (not just the
  six flagged as critical) now run through a shared `_runStep()` helper that catches and records a
  per-step exception instead of letting it propagate and skip every step after it.
- **R6 (surface sync health, not just a debug log) — done.** Added `lastSyncErrorProvider`
  (set from the joined per-step errors after each `fullSync()`) and `pendingSyncCountProvider` (a
  live stream over the `SyncOutbox` table). `SyncStatusIndicator` (used on the Settings, Adhan
  Notifications, and Silent Mode screens) now shows a warning state and the pending count instead
  of unconditionally claiming "synced successfully."
- **Not yet done / known gaps:**
  - `syncProhibition()` (the push function for `prohibitions_log`) is still never actually called
    from anywhere in the app — `logProhibition()` writes locally and the daily record's aggregate
    points get pushed via `syncDailyRecord`, but the raw per-prohibition row never reaches
    Supabase. Outbox instrumentation was added to `syncProhibition`/`_syncProhibitions` so it'll
    behave correctly the moment something calls it, but wiring an actual call site (e.g. from
    `checklist_screen.dart`'s `_ProhibitionRow`, alongside its existing `syncDailyRecord` call) is
    separate, out-of-scope work — flagged rather than silently left.
  - `ghadh_basar` push/pull (see R4 above) needs an actual Supabase column migration.
  - Real multi-day, multi-failure end-to-end testing against a live Supabase project (per this
    spec's own acceptance criteria) wasn't possible in this environment — verified by code reading
    plus `flutter analyze`/`flutter test` (whole project/suite, both clean) rather than a live
    device/backend run.
- A Flutter/Dart toolchain (3.47.2 stable) was available for this pass — `flutter analyze` (whole
  project) and `flutter test` (whole suite) both pass clean after all of the above.

## 1. Problem statement

Reported symptom: the user fills in a day's checklist (prayers, Qur'an, adhkar, etc.), the
points/streak/achievements reflect it correctly at the time, but **the next day** the previous
day's result is gone — points/streak appear reset and statistics/achievements don't reflect what
was saved. This reads as "the data isn't saving to the database," but the local write itself
does succeed; the loss happens later.

## 2. How a day's stats are actually written today

`features/checklist/screens/checklist_screen.dart` has no explicit "Save" button — every toggle
(prayer status, Qur'an pages, adhkar, sadaqah, …) calls straight into
`DailyRecordDao` (`core/database/daos.dart:14`), e.g.:

```dart
final dao = ref.read(dailyRecordDaoProvider);
final rec = await dao.getOrCreateToday();   // core/database/daos.dart:25
await dao.updatePrayerStatus(...);          // writes + recalcPoints(), daos.dart:41-51
```

`getOrCreateToday()`/`updatePrayerStatus()`/`updateQuran()`/etc. all run inside a
`transaction()` and end by calling `recalcPoints(recordId)` (`daos.dart:232-292`), which
recomputes `taqwaPoints` / `deductedPoints` / `netPoints` from the current row + related tables
and writes them back. **This part works and is not the bug** — the local SQLite row for "today"
is correct immediately after each toggle.

`features/statistics/statistics_screen.dart` and `features/achievements/providers/
achievements_providers.dart:29` (`achievementsProvider`) both read straight from this same local
DB (`StatsDao.getMonthStats`/`getCurrentStreak`, `db.achievements`), so right after logging a day
they show the correct numbers.

## 3. Root cause: the Supabase full-sync pull can clobber same-day local writes

`SyncManager.fullSync()` (`core/supabase/sync_manager.dart:41`) runs on app start (and wherever
else it's invoked) and, for daily records, does — in this order:

```dart
Future<void> _syncDailyRecords() async {                       // sync_manager.dart:67
  final localRecords = await dao.getLastNDays(7);
  for (final record in localRecords) {
    await syncDailyRecord(record);        // 1. PUSH local → Supabase
  }
  final remoteRecords = await _service.getRecordsRange(from: ..., to: DateTime.now());
  for (final record in remoteRecords) {
    await dao.upsertFromRemote(record);   // 2. PULL Supabase → local (overwrites!)
  }
}
```

Two independent defects combine to lose data:

### 3.1 Push failures are silently swallowed, with no retry/outbox

```dart
Future<void> syncDailyRecord(DailyRecord record) async {        // sync_manager.dart:219
  ...
  try {
    await _service.upsertDailyRecord({ ... });
  } catch (e) {
    developer.log('syncDailyRecord exception: $e', name: 'SyncManager'); // swallowed
  }
}
```

Any transient failure — no connectivity mid-sync, auth session not yet warm at app-start,
Supabase RLS rejecting the row, a schema mismatch (see 3.3) — drops that day's push with **no
retry, no persisted "pending sync" flag, and no user-visible error**. The local row stays correct,
but Supabase's copy of "today" is now stale (or never existed).

### 3.2 The pull step then overwrites the (correct) local row with the stale remote one

`upsertFromRemote()` (`core/database/daos.dart:417-443`) does an unconditional
`InsertMode`/`DoUpdate` keyed on `date`, with **no comparison of `updatedAt` / any version
field, and no check for whether the local row is newer**:

```dart
Future<void> upsertFromRemote(Map<String, dynamic> data) async {
  final companion = DailyRecordsCompanion(
    date: Value(date),
    ...
    netPoints: Value(_toInt(data['net_points'])),
    taqwaPoints: Value(_toInt(data['taqwa_points'])),
    ...
  );
  await into(dailyRecords).insert(
    companion,
    onConflict: DoUpdate((old) => companion, target: [dailyRecords.date]),
  );
}
```

So on the *next* app start (typically "the next day," matching the report), step 2 of
`_syncDailyRecords` pulls the last 30 days from Supabase and blindly overwrites
`netPoints`/`taqwaPoints`/prayer statuses/etc. for today's (now yesterday's) row with whatever
Supabase has — which, per 3.1, may be stale or absent (defaulting to 0 in `_toInt`). This is
exactly "logged a day, next day it's gone": `getCurrentStreak()`/`getLongestStreak()`
(`core/database/daos.dart:462-520`) require `netPoints > 0` on consecutive days, so a single
zeroed-out day breaks the streak, and `checkAndGrantAchievements()`
(`core/database/daos.dart:759`) reads the now-broken streak — achievements that were earned stop
being re-derivable from a consistent history (already-granted rows in the `achievements` table
survive, but *new* streak-based grants and the visible current streak silently regress).

### 3.3 Several fields are never pushed at all (permanent, not just transient, loss on remote)

`syncDailyRecord()` (`sync_manager.dart:219-256`) comments out fields the remote schema doesn't
have yet:

```dart
// 'witr': record.witr,
// 'rawatib': record.rawatib,
// 'quran_verses': record.quranVerses,
// 'quran_juzaa': record.quranJuzaa,
// 'after_prayer_adhkar': record.afterPrayerAdhkar,
// 'tasbeeh_count': record.tasbeehCount,
// 'ghadh_basar': record.ghadhBasar,
// 'sadaqah_amount': record.sadaqahAmount,
// 'deducted_points': record.deductedPoints,
// 'mood': record.mood,
```

These stay correct locally (not the "gone the next day" symptom by themselves, since
`upsertFromRemote` also never touches them — `Value.absent()` on those columns), but any device
reinstall / second device relying on cloud sync will never see them. Worth fixing in the same
pass since it's the same push/pull contract.

### 3.4 `getCurrentStreak()` / `getLongestStreak()` are strict on exact day gaps

`daos.dart:494-520` breaks the streak the moment one day's `netPoints` isn't `> 0` — including a
day that's zeroed out by 3.2, or a day that was simply skipped by the user. This is arguably
correct product behavior for *genuinely* missed days, but it means the sync bug above is
maximally destructive (one bad pull kills the whole streak, not just one day's score) and makes
the bug hard to distinguish from "user actually missed a day." Fixing 3.1/3.2 removes the false
positives; this item just documents why the symptom looks so total.

## 4. Goals

- A day's locally-recorded stats must never be silently overwritten by an older/stale remote
  copy.
- A push failure must be visible to the sync layer (not just a debug log) and retried, not
  dropped.
- Local-only fields not yet in the remote schema must not be lost by pretending sync succeeded.

## Non-goals

- Redesigning the sync protocol into full CRDT/operational-transform conflict resolution.
- Multi-device concurrent-edit merging beyond last-write-wins by timestamp.
- Changing the points/streak scoring rules themselves (`packages/takwa_core`).

## 5. Requirements (EARS)

- **R1** — WHEN `SyncManager._syncDailyRecords()` pulls a remote record for a date that already
  has a local `DailyRecords` row, THE SYSTEM SHALL only apply the remote row if the remote
  `updated_at` (needs adding to the Supabase table/`getRecordsRange` payload if absent) is
  strictly newer than the local row's `updatedAt`; otherwise it SHALL skip that field of the pull.
- **R2** — WHEN a push (`syncDailyRecord`, `syncAchievement`, `syncCustomIbadahLog`, etc.) fails,
  THE SYSTEM SHALL mark that record as "pending sync" (a local flag/column or a persisted
  outbox table) instead of only logging the exception, and SHALL retry pending records on the
  next `fullSync()` before pulling.
- **R3** — WHILE a record has a pending push, THE SYSTEM SHALL NOT let a pull for that same
  date's remote row overwrite the local `netPoints`/`taqwaPoints`/prayer-status columns.
- **R4** — THE SYSTEM SHALL push every column that has a corresponding local field once the
  remote schema supports it (`witr`, `rawatib`, `quran_verses`, `quran_juzaa`,
  `after_prayer_adhkar`, `tasbeeh_count`, `ghadh_basar`, `sadaqah_amount`, `deducted_points`,
  `mood`), and pull them back symmetrically in `upsertFromRemote`. (Blocked on a Supabase
  migration adding these columns — see Implementation notes.)
- **R5** — WHEN `fullSync()` throws partway through any one sub-sync (`_syncDailyRecords`,
  `_syncCustomIbadah`, etc.), THE SYSTEM SHALL still attempt the remaining sub-syncs rather than
  aborting the whole `fullSync()` (currently a single `try { ... } finally` with no per-step
  isolation — one failing step doesn't currently abort later ones since there's no per-step
  `try/catch`, but confirm this holds once R2's outbox retry is added around each step).
- **R6** — THE SYSTEM SHALL surface a non-debug-log signal (e.g., a `lastSyncError` /
  `pendingSyncCount` provider) so the Settings screen or a small banner can tell the user sync is
  behind, instead of this failing invisibly.
- **R7** — WHEN achievements are (re)computed via `checkAndGrantAchievements()`
  (`daos.dart:759`), THE SYSTEM SHALL base the computation only on local `DailyRecords` rows that
  are not mid-conflict (i.e., after R1–R3 land, the local table is the single source of truth for
  streak math — remote is only ever a backup/restore source, never a live overwrite of a fresher
  local row).

## 6. Acceptance criteria

1. Log a full day's checklist while online, force-kill the app, relaunch the next day with the
   Supabase row for that date manually reverted to zero/absent (simulating a lost push) — the
   local stats for that date remain unchanged after `fullSync()` runs.
2. Simulate a `syncDailyRecord` throwing (e.g., toggle airplane mode mid-save) — the day is not
   silently dropped; the same day is retried and successfully pushed on the next sync, verified
   by reading it back from Supabase.
3. `getCurrentStreak()`/`getLongestStreak()`/`achievementsProvider` reflect a full, uninterrupted
   local history after a `fullSync()` that includes at least one previously-failed-push day.
4. No regression: a genuinely stale local record (e.g., restoring a backup on a new device) still
   picks up newer remote data (R1's "only if newer" comparison must go both directions).

## 7. Implementation notes / open questions

- Requires a Supabase migration to add an `updated_at` column to the remote `daily_records`
  table (if not already present — check `core/supabase/supabase_service.dart` /
  `getRecordsRange`) before R1 can compare timestamps; until then, a cheap interim mitigation is
  to make the pull in `_syncDailyRecords` **skip pulling `netPoints`/`taqwaPoints`/prayer-status
  columns entirely for dates within the just-pushed 7-day push window**, since those were just
  authoritatively pushed by this same sync pass.
- The "pending sync" flag (R2) is the more invasive piece — decide between (a) a new boolean
  column on `DailyRecords`/`Achievements`/`CustomIbadahLog` or (b) a dedicated `SyncOutbox` table
  keyed by `(table, recordId, op)`. Given multiple tables need this (`daily_records`,
  `achievements`, `custom_ibadah_log`, `prohibitions_log`), a single generic outbox table is
  likely less duplication than a flag per table.
- R4's remote-schema columns should be added in one Supabase migration alongside the
  corresponding `syncDailyRecord`/`upsertFromRemote` un-commenting, so the two never drift apart
  again.
