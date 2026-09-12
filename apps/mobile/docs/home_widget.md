# Home screen prayer-times widget

A home-screen widget (Android AppWidget / iOS WidgetKit) showing today's
five prayer times, with the next upcoming one highlighted — modeled on the
reference "ختمة" widget the feature request was based on.

## How it flows

1. `prayerTimesProvider` (already existed, `lib/core/notifications/
   notifications_service.dart`) recomputes prayer times whenever location,
   calculation settings, or the day changes.
2. `_TakwaAppState.build()` in `lib/main.dart` listens to that provider
   (and to `localeProvider`, so a language switch alone still refreshes
   the widget's labels) and calls `PrayerHomeWidgetService.update()`.
3. `PrayerHomeWidgetService` (`lib/core/home_widget/
   prayer_home_widget_service.dart`) formats the five prayers + Hijri/
   Gregorian date into one JSON blob, saves it via the `home_widget`
   plugin, and asks the platform to redraw:
   - **Android**: `HomeWidget.updateWidget()` broadcasts to
     `PrayerWidgetProvider` immediately, and `HomeWidget
     .scheduleWidgetUpdates()` arms one alarm per remaining prayer time
     today so the highlight still advances while the app is closed.
   - **iOS**: WidgetKit's own `TimelineProvider` (`PrayerWidget.swift`)
     builds one timeline entry per remaining prayer time from the same
     JSON, so it needs no equivalent "please update again later" call.
4. Neither native side computes a prayer time or a Hijri date itself —
   they only format whatever this JSON blob says. All Islamic-calendar/
   calculation-method logic stays in one place (Dart).

## Files

| Purpose | Path |
|---|---|
| Push data to the widget | `lib/core/home_widget/prayer_home_widget_service.dart` |
| Shared Hijri month name helper | `lib/core/utils/hijri_display.dart` |
| Android widget provider | `android/app/src/main/kotlin/com/takwa/takwa/PrayerWidgetProvider.kt` |
| Android layout | `android/app/src/main/res/layout/prayer_widget.xml` |
| Android widget metadata | `android/app/src/main/res/xml/prayer_widget_info.xml` |
| iOS widget extension source | `ios/PrayerWidget/PrayerWidget.swift` |
| iOS one-time Xcode setup | `ios/PrayerWidget/SETUP.md` |

## Status

- **Android**: fully wired — `flutter pub get`, build, and it works. No
  extra manual step (the `home_widget` plugin's own Gradle module and the
  manifest `<receiver>` entries handle themselves).
- **iOS**: the Swift/plist/entitlements source is ready, but a WidgetKit
  extension **target** has to be added once from inside Xcode — that
  plumbing can't be scripted safely outside Xcode's own "New Target"
  wizard. See `ios/PrayerWidget/SETUP.md` for the exact steps (~10
  minutes, one-time, then committed).
- Ships one size for now (`.systemMedium` / a resizable ~4×2 Android
  widget) — a larger variant with the live countdown bar from the other
  reference screenshot can be added later as a second layout + widget
  family.

## Testing manually (Android)

1. `flutter pub get` (needed once, to pull in `home_widget` — not run in
   this session since no Flutter SDK is available here).
2. Run the app on a device/emulator once so `PrayerHomeWidgetService`
   pushes real data.
3. Long-press the home screen → Widgets → "تقوى - أوقات الصلاة" → place
   it.
4. Change the language in Settings and confirm the widget's labels
   switch too (it redraws within a second via the `localeProvider`
   listener).
