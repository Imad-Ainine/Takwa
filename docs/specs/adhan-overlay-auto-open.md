# Spec: Reliable Auto-Open of the Adhan Overlay at Prayer Time

## 0. Implementation status (updated after two implementation passes)

- **R1/R2 (overlay permission never requested/surfaced) — done.** `overlay_settings_tile.dart`
  now requests the "draw over other apps" permission when "Adhan screen"/popups are enabled, and
  shows a warning + one-tap fix whenever it's missing. See `settings-notifications-improvements.md`
  §0 for the exact commit.
- **R6 — the original framing was incomplete: a third, OS-native path already existed and mostly
  satisfies it; the real remaining gap was a permission, not the polling itself.** §2 below only
  covered two paths (`AdhanAutoTrigger`'s foreground timer, and the background isolate's system
  overlay). A third, independent path was missed in the original investigation:
  `NotificationsService.schedulePrayerNotifications()` (`notifications_service.dart`) already
  schedules a `flutter_local_notifications` `zonedSchedule(...)` for every prayer, with
  `androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle` (a real Android
  `AlarmManager.setExactAndAllowWhileIdle`-backed exact alarm — exactly what R6 asked for) and
  `fullScreenIntent: adhanMode != 'silent'` — Android's own "launch this UI now, locked screen or
  not" mechanism, the same one alarm-clock apps use, requiring no polling at all. Its payload
  (`'prayer:${prayer.name}'`) is routed to `Routes.adhan` by `NotificationRouter.route()`, wired
  for both a live app (`onDidReceiveNotificationResponse`) and a cold app launch
  (`main.dart`'s `_checkNotificationLaunch()` reading `getNotificationAppLaunchDetails()`). This is
  called from `LocationPrayerManager._scheduleForLocation()`, itself reachable from app startup and
  location refresh — so it's live, not dead code.

  What made this exact-alarm path unreliable in practice was the **same class of bug as R1/R2**,
  just for a different permission pair: `NotificationsManager.scheduleAll()` — the entry point that
  calls `schedulePrayerNotifications()` — opens with
  `if (!await NotificationsService.checkPermissions()) return;`, silently scheduling *nothing* if
  either the base notification permission or Android 12+'s exact-alarm permission
  (`Permission.scheduleExactAlarm`, already used by the existing-but-underused
  `NotificationsService.requestPermissions()`/`checkPermissions()`) isn't granted. Exactly like the
  overlay permission, this was only ever requested once, at onboarding — never re-checked, never
  surfaced in Settings. Fixed the same way: a warning banner + one-tap grant action added to
  `adhan_notifications_settings_screen.dart`, backed by a `notificationPermissionsGrantedProvider`.

  Net effect: R6's actual ask (exact, Doze-resistant, no-polling delivery) was already
  architecturally in place; this pass made sure the permission gate in front of it doesn't silently
  disable it. The two polling loops (§2.1/§2.2) haven't been removed — they still add a duplicate,
  faster-reacting foreground path and remain the system-overlay-window mechanism for the
  backgrounded/killed case, which the full-screen-intent notification doesn't replace one-for-one
  (see the open question below about whether both can fire for the same prayer).
- **R7 (duplicate-trigger audit, third pass) — found and fixed a real race between the two
  in-app paths; found and documented a much bigger issue with the third.**

  **Fixed:** `AdhanAutoTrigger._check()` (the foreground 1s timer) and
  `AdhanAutoTrigger.handleForegroundData()` (invoked when the background isolate's
  `sendDataToMain` reaches the main isolate) are two independent triggers for the *same* prayer
  that are normally BOTH live at once in ordinary use — the background service starts on every app
  open, right alongside the foreground timer, not just in some rare edge case. Before this fix,
  each deduped independently: `_check()` via the in-memory `_lastTriggeredPrayer` key,
  `handleForegroundData()` only via a live scan of the navigator stack for `Routes.adhan`. Both
  push after their own 300ms `Future.delayed`, so a real (not just theoretical) race existed: if
  `handleForegroundData()`'s scan ran before `_check()`'s delayed push had actually landed on the
  stack, it saw no Adhan screen yet and pushed a second one — meaning a user with the app open at
  prayer time could see two stacked, identical Adhan screens, discovering the duplicate only on
  dismissing the first. Fixed by having both claim the same `_lastTriggeredPrayer` slot
  synchronously, before either awaits anything, so whichever runs first wins and the other returns
  immediately — closing the race deterministically rather than relying on timing.
  `overlay_background_service.dart`'s `sendDataToMain` payload gained a `prayerKey` field (the
  internal `'fajr'`/`'dhuhr'`/… id) so `handleForegroundData()` can build the identical dedupe key
  `_check()` uses; both already draw from the same `'fajr'`/`'dhuhr'`/… naming convention shared
  with `PrayerTimeInfo`/`_PrayerInfo`, so the two keys are guaranteed to match for the same prayer.

  **Found, not fixed — larger issue:** the system overlay window (`ow.FlutterOverlayWindow.
  showOverlay` + `shareData({'type': 'prayer', ...})`, the path meant to reach the user when the
  app is fully killed) does not actually show anything resembling an Adhan screen.
  `UnifiedOverlayWindow._pickRandom()` (`overlays/unified_overlay_window.dart:465-473`) only
  special-cases `_filter == 'adhkar'` and `_filter == 'dua'` — `'prayer'` matches neither, so it
  falls through to the unfiltered pool and shows a **random** adhkar/dua card, indistinguishable
  from the routine popups that already appear every ~24 minutes, auto-closing in 15 seconds, with
  no adhan audio played from that isolate at all. So in the one app state (killed) where the
  full-screen-intent notification is the only thing that can reliably reach the user, the *other*
  candidate mechanism for that same state doesn't announce the prayer at all — it's not a
  duplicate-trigger problem, it's closer to the opposite: this path was never actually finished.
  Fixing it means adding a real `'prayer'` branch to `UnifiedOverlayWindow` (prayer name, a
  persistent/non-auto-closing card while the prayer window is active, ideally audio) — a UI design
  task, not a dedupe fix, and out of scope for this pass; flagged here rather than left
  undiscovered.
- **R4 (`UnifiedOverlayWindow` had no `'prayer'` branch) — done (fourth pass).** Added
  `_PopupItem.isPrayerAnnouncement`/`sourceIcon` and a `_showPrayerAnnouncement()` path triggered
  when `shareData` sends `type: 'prayer'`, so the killed-app overlay now shows the actual prayer
  name/emoji/time (reusing the existing `overlayServicePrayerTimeOverlayTitle`/`Content` strings)
  instead of falling through to a random adhkar/dua card from the unfiltered pool. Audio was
  already covered separately: `_scheduleAdhanNotification` fires a real system notification on a
  dedicated `NotifChannels.prayerSound` channel, which plays regardless of app/isolate state, so
  this fix only needed to correct the *visual* content.
- **R7 (fourth pass) — the two dedupe stores are now the same store, not just no-longer-racing on
  one path.** `AdhanAutoTrigger` now reads and writes the exact same `SharedPreferences` keys/date
  format (`overlay_triggered_prayers`/`overlay_triggered_prayers_date`, `'$year-$month-$day'`) that
  `OverlayBackgroundService._checkAndTriggerAdhan` already used privately — since SharedPreferences
  is native platform storage, both isolates now genuinely observe each other's writes. `_check()`
  defers to this shared store before firing (covers a main-isolate restart mid-window when its own
  in-memory `_lastTriggeredPrayer` is empty but the background isolate already fired today) and
  writes to it after firing (so the background isolate's own loop — which already checked this key
  — also sees it).
- **Not yet done:** R3 (verify the background service restarts on boot — `flutter_foreground_task`
  is configured with `autoRunOnBoot: true`, which likely already covers this, but wasn't
  independently re-verified), R6's polling loops were not removed (deliberately — see the note
  below on why replacing them wasn't attempted in this pass), and confirming on a real device that
  the full-screen-intent notification actually auto-launches when the app is killed and the screen
  is locked (Android's full-screen-intent behavior has tightened across OS versions and device OEM
  skins vary; this can't be verified without hardware).
- A Flutter/Dart toolchain (3.47.2 stable) was available for this fourth pass —
  `flutter analyze` (whole project) and `flutter test` (whole suite) both pass clean after these
  changes, in addition to the by-hand review the first three passes relied on.
- **R6/R1 (fifth pass) — decoupled the exact-alarm notification's sound from its full-screen-intent
  launch, and made the "entering prayer time" notification silent by default.** The exact-alarm
  notification (`NotificationsService.schedulePrayerNotifications`, item 2) previously tied
  `fullScreenIntent` to `adhanMode != 'silent'` — so a user who picked the silent Adhan mode (no
  audio) also lost the automatic full-screen launch of the Adhan overlay entirely, even though
  "no sound" and "don't auto-open the screen" are two different preferences
  (`adhanMode` vs. `adhanScreenEnabled`). `fullScreenIntent` is now tied to `adhanScreenEnabled`
  instead, and the notification itself never plays a sound regardless of `adhanMode` (it always
  uses the `prayerSilent`/`prayerVibrate` channel, never `prayerSound`) — the actual Adhan audio is
  played exclusively by `AdhanAudioPlayer` once the overlay screen opens, never by the OS
  notification. The same change was made to `OverlayBackgroundService._scheduleAdhanNotification`
  (the background isolate's own immediate notification, fired in `_checkAndTriggerAdhan` alongside
  the system-level overlay window) — it used to only fire, with real channel sound, when
  `adhanMode == 'sound'`; it now always fires silently (vibrating only in `'vibrate'` mode),
  simultaneously with the system overlay, so a silent notification and the overlay reach the user
  together regardless of app state. `_checkAndTriggerAdhan`'s system overlay
  (`ow.FlutterOverlayWindow.showOverlay`) is now also gated on a new `_adhanScreenEnabled` field
  (mirrored live from `OverlayBackgroundService.updateSettings`, same pattern as `adhanMode`/
  `adhanVolumeLevel`), so turning "Adhan screen" off has the same effect in the killed-app path as
  it already did in `AdhanAutoTrigger.handleForegroundData`'s in-app path — previously the system
  overlay ignored this setting entirely. `flutter analyze`/`flutter test` (whole project/suite)
  pass clean after this change.

## 1. Problem statement

The Adhan overlay/screen should open automatically the moment a prayer starts, in every app
state (app open, app backgrounded, app fully killed, screen off). Today it only reliably fires
while the app process is alive and, even then, depends on a system permission the app never
actively prompts for at the right moment — so in practice it's inconsistent, which matches the
report that it doesn't "just open" when prayer starts.

## 2. Current mechanism (two parallel, only-partly-connected paths)

### 2.1 Foreground/in-app path — `AdhanAutoTrigger` (`core/notifications/adhan_auto_trigger.dart`)

```dart
static void start(WidgetRef ref, GlobalKey<NavigatorState> navigatorKey) {
  _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) => _check(ref, navigatorKey));
}
```

A plain `Timer.periodic` in the main isolate, started via `AdhanAutoMixin.initAdhanAuto()`
(`adhan_auto_trigger.dart:251-260`) from wherever the app's root widget mixes it in. It compares
`DateTime.now()` against cached prayer times every second and, within a 0–180s window after
prayer start, pushes `Routes.adhan` (`adhan_auto_trigger.dart:79-162`).

**This only runs while that widget is mounted and the Dart isolate is alive** — i.e., app in
foreground, or briefly backgrounded before the OS suspends the isolate. It does nothing once the
app is swiped away/killed or the OS freezes the isolate in the background (normal Android/iOS
background execution limits).

### 2.2 Background path — `overlay_background_service.dart` (a `flutter_foreground_task` isolate)

A separate background isolate (started as a foreground service, so Android keeps it alive) polls
prayer times and, in `_checkAndTriggerAdhan` (`core/notifications/overlay_background_service.dart:
~390-475`):

```dart
final hasOverlayPerm = await ow.FlutterOverlayWindow.isPermissionGranted();
if (hasOverlayPerm) {
  await ow.FlutterOverlayWindow.showOverlay(...);      // system-level overlay — works even if app is killed
  ...
  ow.FlutterOverlayWindow.shareData({...});
}

FlutterForegroundTask.sendDataToMain({                  // only reaches the app if the main isolate is alive
  'action': 'show_adhan',
  ...
});
```

Two separate delivery mechanisms, gated independently:

- **System overlay window** (`flutter_overlay_window`) — the only one of the two that can draw
  over other apps / a locked or off screen without the main app process running. **Gated on
  `ow.FlutterOverlayWindow.isPermissionGranted()`** (Android's "draw over other apps" /
  `SYSTEM_ALERT_WINDOW` special permission). If this permission was never granted, the code
  silently skips `showOverlay` — no fallback, no user-visible reason why nothing happened.
- **`sendDataToMain` → `AdhanAutoTrigger.handleForegroundData`** (`adhan_auto_trigger.dart:
  165-220`) — routed to `Routes.adhan` inside the *existing* Flutter UI. This only has any effect
  if the main isolate/navigator is alive, i.e. it's a duplicate of 2.1's job for the case where
  the background isolate detected the prayer instead of the foreground timer.

### 2.3 Where this breaks in practice

1. **Permission never actively requested at a useful moment.** `overlay_settings_tile.dart`
   presumably has a manual toggle (see `core/notifications/overlay_settings_tile.dart`), but if
   the user enabled "adhan screen" in Settings (`adhanScreenEnabled` in
   `features/settings/data/user_preferences.dart:39`) without separately granting the OS-level
   overlay permission, the background path (2.2) silently does nothing when the app isn't in the
   foreground — the setting *looks* on, but the overlay never appears when it matters most (app
   closed).
2. **Two independent "enabled" checks that can disagree.** `adhanScreenEnabled` (drives the
   in-app `Routes.adhan` push, both foreground timer and `handleForegroundData`) and
   `overlayEnabled`/whatever gates `showOverlay` in the background isolate are separate
   preference fields (`user_preferences.dart:37-39`) that the user has no single obvious control
   over — see the companion settings spec.
3. **No user-visible feedback when the overlay permission is missing/revoked.** Android lets
   users revoke "draw over other apps" at any time from system settings; the app has no periodic
   re-check + prompt, so the feature can silently stop working after working once.
4. **Foreground service itself may not be running/enabled.** If the background foreground-task
   service was never started (e.g., battery optimization killed it, user never opened the app
   after install so `flutter_foreground_task` was never initialized, Android 12+ exact-alarm/
   foreground-service restrictions), *nothing* fires when the app is killed — not even the
   fallback `sendDataToMain` path, since there's no background isolate to send from.
5. **1-second polling drains battery / can be throttled.** Both `AdhanAutoTrigger`'s 1s
   `Timer.periodic` and the background service's poll loop are wall-clock polling rather than
   scheduled exact triggers (`AlarmManager`/`UNNotificationRequest` with a calendar trigger),
   which OS-level Doze/App-Standby can delay by minutes — directly undermining "opens exactly
   when prayer starts."

## 3. Goals

- The Adhan overlay/screen opens within a few seconds of prayer time in all three app states:
  foreground, backgrounded, fully killed.
- The user is told, at the moment they enable "auto-open adhan screen," exactly which OS
  permissions that requires, and is walked through granting them — not left with a setting that
  silently no-ops.
- The app detects when a required permission has been revoked and re-surfaces the request instead
  of failing silently forever.

## Non-goals

- Redesigning the overlay UI itself (`core/notifications/overlays/adhan_overlay_screen.dart`).
- Adding new prayer-time calculation logic — this spec assumes `prayerTimesProvider` /
  `_refreshPrayerTimes()` already produce correct times.
- iOS support beyond what local notifications can do (iOS does not allow arbitrary overlay
  windows or launching the app UI from the background the way Android's overlay permission does —
  this needs a documented, deliberately different iOS behavior, e.g. a full-screen critical
  notification, rather than parity with Android).

## 4. Requirements (EARS)

- **R1** — WHEN the user enables "Adhan screen" in Settings (`adhanScreenEnabled`) on Android AND
  the `SYSTEM_ALERT_WINDOW`/overlay permission is not yet granted, THE SYSTEM SHALL immediately
  prompt for that permission (via `ow.FlutterOverlayWindow.requestPermission()`, already used
  elsewhere per `overlay_background_service.dart:160`) with an explanation of why it's needed,
  rather than silently leaving the setting on with no effect.
- **R2** — WHEN the overlay permission is denied or later revoked, THE SYSTEM SHALL reflect this
  in the Settings UI (e.g., a warning row) so the user can tell the feature is currently
  non-functional, instead of assuming a green toggle means it works.
- **R3** — THE SYSTEM SHALL verify, when "Adhan screen" is enabled, that the background
  foreground-task service is actually running, and (re)start it if not (covers the app being
  killed and Android boot — confirm a `BOOT_COMPLETED` receiver re-arms the service; if absent,
  add one).
- **R4** — WHEN a prayer time is reached AND the app is killed or backgrounded, THE SYSTEM SHALL
  open the system-level overlay (`ow.FlutterOverlayWindow.showOverlay`) without depending on the
  main Flutter isolate being alive — this already exists (2.2) but is gated by R1's permission
  fix and R3's service-liveness fix, both of which are the actual gaps today.
- **R5** — WHEN a prayer time is reached AND the app is already in the foreground, THE SYSTEM
  SHALL route to the in-app `Routes.adhan` screen instead of also popping the system overlay on
  top of it (avoid double UI — confirm the existing "don't push if already visible" guard in
  `adhan_auto_trigger.dart:117-127` also suppresses the *system* overlay in this case, not just
  the in-app route).
- **R6** — THE SYSTEM SHALL trigger within ±5 seconds of the scheduled prayer time regardless of
  Doze/App-Standby state. Prefer migrating from wall-clock polling to OS-scheduled triggers
  (Android `AlarmManager.setExactAndAllowWhileIdle` per prayer, or rescheduling local
  notifications with an exact calendar trigger) over the current 1s/60s poll loops, since polling
  is both a battery cost and a reliability risk under OS power management.
- **R7** — THE SYSTEM SHALL NOT open a duplicate overlay for the same prayer twice (existing
  per-prayer-per-day dedupe key in both `adhan_auto_trigger.dart:113-115` and
  `overlay_background_service.dart`'s `_kTriggeredPrayersKey` — keep, but verify the two dedupe
  stores (in-memory `_lastTriggeredPrayer` vs. `SharedPreferences`) can't disagree across a
  process restart mid-window).

## 5. Acceptance criteria

1. Fresh install → enable "Adhan screen" in Settings → app immediately asks for the overlay
   permission with a clear reason, and Settings shows the current grant state afterward.
2. With permission granted and the app fully swiped away, the Adhan overlay appears within 5
   seconds of the next prayer time on a real device (not just while charging/USB-debugging, which
   can mask Doze effects — test on battery with the screen off for at least 15 minutes before the
   prayer time to let Doze engage).
3. Revoking the overlay permission from Android system settings surfaces a warning next time the
   Settings → Notifications screen is opened.
4. Force-stopping the app (not just backgrounding) and waiting past a prayer time still shows the
   overlay if `BOOT_COMPLETED`/service auto-restart is implemented; otherwise this is documented
   as a known OS-level limitation with the mitigation the app takes (e.g., a persistent
   foreground-service notification that's hard for users to swipe away).
5. No duplicate overlay for the same prayer when the background service and an open app both
   detect the same trigger window.

## 6. Implementation notes / open questions

- Confirm current behavior of `overlay_settings_tile.dart` — does it already request the overlay
  permission on toggle? If so, R1 may already be partially implemented and this becomes "make
  `adhanScreenEnabled` in the main Settings screen use the same gate," not new code.
- R6 (moving off polling) is the highest-effort item here and could be split into its own
  follow-up spec if the polling approach turns out to be "good enough" once R1/R3 close the
  bigger permission/service-liveness gaps — recommend shipping R1–R5/R7 first, measuring real
  on-time-open rates, then deciding whether R6 is still needed.
- iOS: document actual current behavior (likely: local notification only, no overlay) and decide
  the intended iOS UX explicitly rather than leaving it implied by the Android-first code.
