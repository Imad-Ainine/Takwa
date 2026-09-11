# Spec: Settings & Notifications Improvements

## 0. Implementation status (updated after a first implementation pass)

- **R1 (adhan sound single source of truth) — done, and it was a real bug, not just a naming
  overlap.** Investigation found the background foreground-task isolate
  (`overlay_background_service.dart`'s `_OverlayTaskHandler._checkAndTriggerAdhan`) gated its
  adhan sound notification on the separate `_adhanSoundEnabled` flag, not `_adhanMode` — so a user
  who set "نمط الأذان" (adhan mode) to silent/vibrate on the Adhan settings screen could still get
  a sound notification from the background service, because that screen's mode selector never
  talked to the *other* screen's "صوت الأذان" toggle. The foreground path
  (`AdhanAutoTrigger._check`) already correctly used only `adhanMode`. Fixed: the background
  isolate now checks `_adhanMode == 'sound'`; the redundant standalone toggle was removed from
  `overlay_settings_tile.dart`.
- **R3 + R5 (dead fields) — done for the two confirmed-dead fields.** A grep audit found
  `adhanInSilentEnabled`/`notifsInSilentEnabled` were read nowhere outside the model itself,
  `fromMap`/`toMap`, and a historical migration — no UI control, no consumer. Removed from
  `UserPreferences`, the Settings→Supabase key mapping, and the default-settings seed. The other
  fields §2 originally flagged as *maybe* dead (`wakeScreenEnabled`, `ongoingNotifEnabled`,
  `adhanAlarmEnabled`) turned out to have live UI controls on `adhan_notifications_settings_screen.
  dart` and/or be read by `adhan_overlay_screen.dart` — that part of the original table (below) was
  speculative and is corrected in place. `silentDurationMins` is a **newly-found** real gap in the
  other direction: it's read by the background service but has no UI control anywhere — left as an
  open item since adding a duration picker is a small feature addition, not a cleanup, and
  deserves its own pass.
- **R6 (cross-isolate consistency) — the `adhanMode` instance fixed.** The Adhan-mode selector's
  `onChanged` didn't push the new value to the background isolate at all (unlike every toggle in
  `overlay_settings_tile.dart`, which already did) — it only reached the isolate on next service
  start. Fixed by calling `OverlayBackgroundService.updateSettings(adhanMode: v)` alongside the
  preference write. Other fields read by the background isolate weren't re-audited for the same
  gap in this pass.
- **Not yet done:** R2 (rename/regroup `overlayEnabled` vs `adhanScreenEnabled`), R4 beyond the
  overlay-permission case already covered by `adhan-overlay-auto-open.md`'s implementation, R7
  (numeric-setting labeling audit), and a UI control for `silentDurationMins`.
- No Flutter/Dart toolchain was available to run `flutter analyze`/tests against these changes —
  reviewed by hand; run CI before merging.

## 1. Problem statement

The notification/adhan preference surface has grown organically into a large, flat
`UserPreferences` model (`features/settings/data/user_preferences.dart`, 40+ fields) spread
across four separate screens (`settings_screen.dart`, `adhan_notifications_settings_screen.dart`,
`silent_mode_settings_screen.dart`, `overlay_settings_tile.dart`). Several toggles overlap in
meaning, nothing in the UI explains how they interact, and (per the companion
`adhan-overlay-auto-open.md` spec) some toggles have no effect at all unless a separate OS
permission is also granted — with no indication of that dependency anywhere in Settings. This
spec is about making the *existing* functionality easy to find, understand, and trust; it does
not propose new notification types.

## 2. Current state — concrete overlaps to resolve

All fields below are on `UserPreferences` (`user_preferences.dart:1-70`):

| Field(s) | What it controls today | Overlap / confusion |
|---|---|---|
| `adhanMode` ('sound'\|'vibrate'\|'silent') | High-level adhan behavior, read by `AdhanAutoTrigger._check` (`adhan_auto_trigger.dart:96-97`) | Redundant with `adhanSoundEnabled`, `vibrateWithAdhan`, `silentModeEnabled` below — four different flags can each independently imply "no sound," with no single source of truth |
| `adhanSoundEnabled` | Gates the background isolate playing an adhan sound (`overlay_background_service.dart` via `_adhanSoundEnabled`) | Doesn't agree with `adhanMode == 'sound'` by construction — the two are read in different isolates and never reconciled at the type level |
| `vibrateWithAdhan` | Presumably vibration on adhan | Never cross-checked against `adhanMode == 'vibrate'` |
| `adhanScreenEnabled` | Whether the in-app/overlay Adhan screen opens (`adhan_auto_trigger.dart:99`) | Silently requires the OS overlay permission to do anything when the app isn't foregrounded (see `adhan-overlay-auto-open.md` §2.3) — nothing in Settings says so |
| `overlayEnabled` | Gates the *popup* overlay system (adhkar/dua reminders) in `overlay_background_service.dart` | Named almost identically to `adhanScreenEnabled` but controls a different feature (periodic reminder popups, not the adhan screen) — easy to confuse |
| `silentModeEnabled`, `silentDurationMins`, `silentModeAlertStyle`, `silentVibrationEnabled`, `silentAdhanPrayers`, `silentNotifPrayers`, `autoSilentAfterAdhan`, `adhanInSilentEnabled`, `notifsInSilentEnabled`, `flipToSilenceEnabled` | The device-silencing feature (own screen: `silent_mode_settings_screen.dart`) | Ten fields for one feature, several of which (`adhanInSilentEnabled` vs `silentAdhanPrayers`, `notifsInSilentEnabled` vs `silentNotifPrayers`) look like they encode the same on/off decision two different ways (a blanket bool *and* a per-prayer CSV list) |
| `wakeScreenEnabled` | Whether adhan wakes the screen; read by `adhan_overlay_screen.dart` | **Correction after investigation:** has a live `CheckboxSetting` on `adhan_notifications_settings_screen.dart` — not dead, despite this spec's original guess |
| `ongoingNotifEnabled`, `adhanAlarmEnabled` | "Persistent notification" / "alarm-priority delivery" | **Correction after investigation:** both also have live `CheckboxSetting`s on the same screen — not dead |
| `adhanInSilentEnabled`, `notifsInSilentEnabled` | Blanket "allow during silent mode" bools | **Confirmed genuinely dead** (no UI control, no consumer anywhere) and **removed** — see §0 |
| `silentDurationMins` | How long silent mode stays on after adhan; read by `overlay_background_service.dart`'s `_silentDurationMins` | **New finding:** the opposite problem — it's consumed but has no UI control at all, stuck at its default (20 min) forever. Left open, see §0 |
| `popupIntervalMins` | How often adhkar/dua popups fire | Fine on its own, but its unit/purpose isn't obvious from the settings screen without reading code — confirm the UI labels it clearly (e.g. "every 24 minutes") |

Two structural issues fall out of this table:

1. **Multiple booleans encode what should be one enum per concern.** Sound-vs-vibrate-vs-silent
   for the adhan is already an enum (`adhanMode`) but is *also* re-expressed by
   `adhanSoundEnabled`/`vibrateWithAdhan`/`silentModeEnabled`, which can disagree with it. The
   in-silent-mode behavior (`adhanInSilentEnabled`/`notifsInSilentEnabled`) is *also* re-expressed
   by the per-prayer CSV lists (`silentAdhanPrayers`/`silentNotifPrayers`).
2. **Some settings have no discoverable effect without external context** — the overlay
   permission dependency being the clearest example, but also worth auditing whether every field
   in `UserPreferences` actually has a reachable UI control (`fromMap`/`toMap`,
   `user_preferences.dart:238-511`, accept/emit every field, which doesn't prove anything reads
   them from a widget).

## 3. Goals

- One on-screen control per user-facing decision — no two toggles that can silently contradict
  each other.
- Every toggle in Settings either has a visible, immediate effect, or (for OS-permission-gated
  ones) visibly shows its current effective state ("on, but overlay permission missing — tap to
  fix").
- A user can predict, from reading the Settings screen alone, what will happen at the next prayer
  time — without needing to know which of four screens a given behavior lives on.

## Non-goals

- Adding new notification types/features beyond what already exists.
- Changing the DB schema/sync format for settings (`SettingsDao`, `core/supabase/sync_manager.dart:
  _syncSettings`) beyond what's needed to drop truly-dead fields.
- Redesigning visual style of the settings screens (separate from `docs/flutter-ui-ux-audit.md`,
  which already covers general UI/UX polish — this spec is about information architecture and
  correctness of the notification settings specifically).

## 4. Requirements (EARS)

- **R1** — THE SYSTEM SHALL have exactly one setting that decides adhan sound/vibrate/silent
  behavior (`adhanMode`), and SHALL derive `adhanSoundEnabled`/`vibrateWithAdhan` from it at every
  read site rather than storing them as independently-settable fields. (If a real product need
  exists for playing sound *and* vibrating simultaneously in `sound` mode, make that its own
  explicit sub-toggle shown only when `adhanMode == 'sound'`, not a separately-toggleable
  top-level field.)
- **R2** — THE SYSTEM SHALL rename or regroup `overlayEnabled` (popup reminders) and
  `adhanScreenEnabled` (adhan screen) so their labels and screen placement make the distinction
  obvious — e.g. both under a single "On-screen alerts" section with explicit sub-headers, not
  spread across `settings_screen.dart` and a standalone `overlay_settings_tile.dart` with similar
  naming.
- **R3** — WHEN the effective in-silent-mode behavior is controlled by both a blanket bool
  (`adhanInSilentEnabled`/`notifsInSilentEnabled`) and a per-prayer list
  (`silentAdhanPrayers`/`silentNotifPrayers`), THE SYSTEM SHALL collapse these into the per-prayer
  list alone (a blanket "all prayers" state is just all five/six prayers selected in that list) —
  removing the redundant bool fields and their separate UI control.
- **R4** — WHEN a setting's effect depends on an OS-level permission not managed inside the app's
  own preference store (overlay permission, notification permission, exact-alarm permission on
  Android 12+), THE SYSTEM SHALL show that dependency's current grant state next to the relevant
  toggle, with a one-tap way to grant it (per `adhan-overlay-auto-open.md` R1/R2 — this spec
  covers the Settings-screen half of that fix; the trigger-logic half lives in that spec).
  Note: this partially depends on the fixes in `adhan-overlay-auto-open.md` — the OS permission
  status needs to be readable by the Settings UI, which is currently only checked inside the
  background isolate (`overlay_background_service.dart`).
- **R5** — THE SYSTEM SHALL audit every field in `UserPreferences` for a reachable UI control
  (`wakeScreenEnabled`, `ongoingNotifEnabled`, `adhanAlarmEnabled` at minimum, per §2) and either
  wire up a visible control for it or remove the field (plus its `toMap`/`fromMap`/`copyWith`
  entries and any DB/Supabase column) if it's confirmed dead.
- **R6** — THE SYSTEM SHALL keep `adhanMode`-derived values consistent between the main isolate
  and the background isolate (`overlay_background_service.dart` reads its own cached copies of
  `_adhanMode`, `_adhanSoundEnabled`, etc. via `SettingsPrefsBridge` —
  `features/settings/data/settings_prefs_bridge.dart`) — i.e., a change made in Settings SHALL be
  visible to the background isolate on its next poll, not just to the foreground app. Verify the
  bridge already does this correctly; if there's a lag, document/fix it.
- **R7** — THE SYSTEM SHALL label `popupIntervalMins` and any other numeric/time settings with
  their concrete effect in-context (e.g. "Reminder every {n} minutes"), not just a bare slider or
  number field.

## 5. Acceptance criteria

1. Toggling `adhanMode` to "silent" immediately silences the sound/vibration UI elements it used
   to control as separate toggles — no separate "sound on" switch to *also* turn off.
2. The Settings screen shows a single, unambiguous place to control "does the adhan screen open
   automatically," including its current permission-grant state.
3. `silentAdhanPrayers`/`silentNotifPrayers` are the only stored representation of per-prayer
   silent behavior; grep confirms `adhanInSilentEnabled`/`notifsInSilentEnabled` are removed (or
   documented as intentionally kept, with a reason, if removal turns out to be riskier than
   expected — e.g. remote schema still has the columns and a migration is out of scope for this
   pass).
4. Every remaining field in `UserPreferences` has at least one `grep`-findable widget that reads
   or writes it from a settings screen.
5. A change to `adhanMode` in Settings is reflected in the background isolate's behavior within
   one poll cycle without requiring an app restart.

## 6. Implementation notes / open questions

- R1/R3's field removal touches `toMap()`/`fromMap()` (`user_preferences.dart:238-511`), the
  Supabase `settings` table shape (`SettingsDao`, `core/database/daos.dart:1034+`), and
  `sync_manager.dart`'s `_syncSettings`/`syncSettings` — coordinate so old remote rows with the
  since-removed keys still parse via `fromMap`'s existing `??` fallback chains (they're additive
  reads, so this should degrade gracefully, but verify no `fromMap` call assumes a removed key is
  always present).
- R4 depends on exposing OS permission state to the main isolate/UI layer; the cleanest place is
  probably a small `Provider<Future<bool>>` wrapping
  `ow.FlutterOverlayWindow.isPermissionGranted()`, watched from both the affected Settings rows
  and wherever `adhan-overlay-auto-open.md` R2's warning banner lives — share one implementation
  rather than two.
- Recommend doing R5's dead-field audit first (cheapest, lowest-risk, informs whether R1–R3 need
  to also touch those fields) before the consolidation work in R1–R3.
