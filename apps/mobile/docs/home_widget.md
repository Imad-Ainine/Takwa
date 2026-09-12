# Home screen widgets

Three home-screen widgets (Android AppWidget / iOS WidgetKit), all sharing
one visual style — the app's own brand colors (gold/teal accents on a
navy-to-card-tone gradient), in both light and dark mode:

- **Prayer times** — today's five prayer times, next one highlighted.
  Modeled on the reference "ختمة" widget the feature request was based on.
- **Dua of the day** — one dua from the app's own bundled traditional duas,
  rotating daily.
- **Dhikr of the day** — same idea, from the bundled adhkar, with a "×N"
  repetition pill when the dhikr is said more than once.

## How it flows

1. **Prayer times**: `prayerTimesProvider` (already existed, `lib/core/
   notifications/notifications_service.dart`) recomputes prayer times
   whenever location, calculation settings, or the day changes.
   `_TakwaAppState.build()` in `lib/main.dart` listens to it (and to
   `localeProvider`, so a language switch alone still refreshes the
   widget's labels) and calls `PrayerHomeWidgetService.update()`, which
   formats the five prayers + Hijri/Gregorian date into a JSON blob.
2. **Dua/dhikr of the day**: `DailyQuoteWidgetService` picks
   deterministically from `kDuasData`/`kAdhkarData` (the same bundled data
   the Duas/Adhkar screens show) using the calendar date, so every device
   shows the same pick on a given day with no server involved. Called once
   at app start and on every locale change (see `_TakwaAppState.initState`
   /`.build()` in `lib/main.dart`).
3. Both services push their JSON via the `home_widget` plugin and ask the
   platform to redraw:
   - **Android**: `HomeWidget.updateWidget()` broadcasts to the matching
     `*WidgetProvider` immediately, and `HomeWidget.scheduleWidgetUpdates()`
     arms an alarm for the next content change (each remaining prayer time
     today, or next midnight for the daily pick) so widgets keep advancing
     while the app is closed.
   - **iOS**: each widget's own WidgetKit `TimelineProvider` builds its
     timeline entries from the same JSON and reload policy, so no
     equivalent "update again later" call is needed from Flutter.
4. No native side computes a prayer time, a Hijri date, or "today's pick"
   itself — they only format whatever JSON these two services last wrote.
   All that logic stays in one place (Dart), so it can never drift between
   the app and the widgets, or between Android and iOS.

## Branding: light & dark

Every widget uses the app's actual design-system colors — mirrored from
`AppColorsExtension` (`packages/takwa_ui/lib/src/theme/app_colors.dart`),
not invented separately — and follows the *system's* light/dark setting
(WidgetKit/AppWidgets have no hook into the app's own in-app theme choice):

- **Android**: `res/values/widget_colors.xml` (light) and
  `res/values-night/widget_colors.xml` (dark) define the same color names;
  Android resolves whichever matches automatically. The shared
  `takwa_widget_card_background.xml` drawable and every widget layout only
  ever reference `@color/widget_*`, never a literal hex, so light/dark
  needs no code — just those two resource files.
- **iOS**: `ios/PrayerWidget/TakwaWidgetTheme.swift` defines the same two
  palettes; every widget view resolves `TakwaWidgetTheme.resolve(
  colorScheme)` from `@Environment(\.colorScheme)` once per render.

## Files

| Purpose | Path |
|---|---|
| Push prayer-time data | `lib/core/home_widget/prayer_home_widget_service.dart` |
| Push dua/dhikr-of-day data | `lib/core/home_widget/daily_quote_widget_service.dart` |
| Shared App Group id | `lib/core/home_widget/home_widget_ids.dart` |
| Shared Hijri month name helper | `lib/core/utils/hijri_display.dart` |
| Android prayer widget | `PrayerWidgetProvider.kt` + `res/layout/prayer_widget.xml` + `res/xml/prayer_widget_info.xml` |
| Android dua/dhikr widgets | `DailyQuoteWidgetProviderBase.kt` (shared base, two thin subclasses) + `res/layout/daily_quote_widget.xml` + `res/xml/{dua,dhikr}_of_day_widget_info.xml` |
| Android brand colors | `res/values/widget_colors.xml` + `res/values-night/widget_colors.xml` |
| Android shared card background | `res/drawable/takwa_widget_card_background.xml` |
| iOS prayer widget | `ios/PrayerWidget/PrayerWidget.swift` |
| iOS dua/dhikr widgets | `ios/PrayerWidget/DailyQuoteWidget.swift` (both, sharing one provider/view) |
| iOS brand colors | `ios/PrayerWidget/TakwaWidgetTheme.swift` |
| iOS `@main` entry point | `ios/PrayerWidget/TakwaWidgetsBundle.swift` (lists all three widgets) |
| iOS one-time Xcode setup | `ios/PrayerWidget/SETUP.md` |

## Status

- **Android**: fully wired — `flutter pub get`, build, and all three work.
  No extra manual step (the `home_widget` plugin's own Gradle module and
  the manifest `<receiver>` entries handle themselves).
- **iOS**: the Swift/plist/entitlements source for all three widgets is
  ready, but a WidgetKit extension **target** has to be added once from
  inside Xcode — that plumbing can't be scripted safely outside Xcode's
  own "New Target" wizard. See `ios/PrayerWidget/SETUP.md` for the exact
  steps (~10 minutes, one-time, then committed) — adding all three widgets
  is one pass through that setup, not three, since they share a single
  extension target.
- All three ship one size for now (`.systemMedium` / a resizable ~4×2
  Android widget). A larger prayer-widget variant with the live countdown
  bar from the original reference screenshot can be added later as a
  second layout + widget family.

## Testing manually (Android)

1. `flutter pub get` (needed once, to pull in `home_widget` — not run in
   this session since no Flutter SDK is available here).
2. Run the app on a device/emulator once so both services push real data.
3. Long-press the home screen → Widgets → search "تقوى" → you'll see three
   widgets: "أوقات الصلاة", "دعاء اليوم", "ذكر اليوم".
4. Toggle the device's system dark mode and confirm all three widgets
   switch between the light and dark palettes.
5. Change the language in Settings and confirm the widgets' labels switch
   too (they redraw within a second via the `localeProvider` listener).
