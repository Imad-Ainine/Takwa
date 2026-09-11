# Spec: Reliable Auto-Open of the Adhan Overlay at Prayer Time

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
