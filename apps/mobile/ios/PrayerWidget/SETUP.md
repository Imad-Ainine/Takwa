# Wiring up the iOS prayer widget

This folder has the Swift/plist/entitlements source for the widget, but a
WidgetKit **extension target** can only be added to the Xcode project from
inside Xcode — its plumbing (product reference, build phases, embed step,
scheme) isn't something safe to hand-edit into `project.pbxproj` from
outside Xcode, and this repo is developed from a Linux machine with no
Xcode to build/verify a hand edit against. You'll need a Mac with Xcode for
this regardless, since that's also required to build/run the iOS app at
all — so doing these steps once in Xcode's UI isn't extra work, just the
normal place to do it.

Budget about 10 minutes. All of it is done once and then committed.

## 1. Add the Widget Extension target

1. Open `ios/Runner.xcworkspace` in Xcode (not `.xcodeproj`).
2. **File ▸ New ▸ Target…** ▸ iOS ▸ **Widget Extension**.
3. Product Name: `PrayerWidget`. Uncheck "Include Configuration Intent"
   (this widget isn't user-configurable). Team/bundle ID: same team as
   Runner; bundle id `com.takwa.PrayerWidget` (Runner's id + `.PrayerWidget`).
4. When Xcode asks to "Activate" the new scheme, choose **Activate**.
5. Xcode generates a `PrayerWidget/` group with its own
   `PrayerWidget.swift`, `Info.plist`, and (if you left configuration
   intents off) possibly an `Assets.xcassets`. **Delete the generated
   `PrayerWidget.swift` and `Info.plist`** (Move to Trash) and instead
   **drag in the three files already in this folder**:
   `PrayerWidget.swift`, `Info.plist`, `PrayerWidget.entitlements` — check
   "Copy items if needed" and add them to the `PrayerWidget` target only
   (not Runner).
6. In the new target's **Build Settings**, set **Info.plist File** to
   `PrayerWidget/Info.plist` and **Code Signing Entitlements** to
   `PrayerWidget/PrayerWidget.entitlements` if Xcode didn't already point
   them there.
7. In the new target's **Build Settings**, set **iOS Deployment Target**
   to **17.0** (the widget uses `containerBackground(for:.widget)`,
   iOS 17+ only — Runner's own deployment target stays 13.0, so the app
   still installs on older iOS, it just won't offer this widget there).

## 2. Add the shared App Group

Both targets need the *same* App Group so the app can write prayer times
where the widget can read them.

1. Select the **Runner** target ▸ **Signing & Capabilities** ▸
   **+ Capability** ▸ **App Groups**. Click **+** under the App Groups
   list and add `group.com.takwa.PrayerWidget`. Xcode creates
   `Runner/Runner.entitlements` for you and wires it into the build
   settings automatically.
2. Select the **PrayerWidget** target ▸ **Signing & Capabilities** ▸
   **+ Capability** ▸ **App Groups** ▸ check the same
   `group.com.takwa.PrayerWidget` group (Xcode will offer it once step 1
   is done since it already exists in your Apple Developer account/team).
   This should point at the `PrayerWidget.entitlements` already in this
   folder — if Xcode instead generated a second entitlements file, delete
   the generated one and re-point **Code Signing Entitlements** at
   `PrayerWidget/PrayerWidget.entitlements`.
3. If you ever rename the group, update it in **three** places: both
   entitlements files above, and `PrayerHomeWidgetService.iOSAppGroupId`
   in `lib/core/home_widget/prayer_home_widget_service.dart`.

## 3. Build

1. Select the **Runner** scheme (not PrayerWidget) ▸ your device/simulator
   ▸ **Run**.
2. Open the app once so `PrayerHomeWidgetService` writes real prayer times
   into the shared App Group (it runs on every app start — see
   `lib/main.dart`'s `_TakwaAppState.initState`).
3. Long-press the Home Screen ▸ **+** ▸ search "تقوى" ▸ add the
   **أوقات الصلاة** widget.

If the widget shows the "افتح تطبيق تقوى..." placeholder instead of real
times, the App Group is misconfigured (mismatched group id between the two
entitlements files and `iOSAppGroupId`) or the app hasn't been opened yet
on this device/simulator.

## Notes

- `kind = "PrayerWidget"` in `PrayerWidget.swift` must keep matching
  `PrayerHomeWidgetService.iOSWidgetName` (Dart) — that's the name
  `HomeWidget.updateWidget(iOSName: ...)` looks up.
- This ships one size (`.systemMedium`, ~4×2 cells) to start. Add
  `.systemLarge` to `supportedFamilies` and a second layout branch in
  `PrayerContentView` later if you also want the bigger countdown-style
  variant from the reference screenshots.
- No Podfile changes are needed — the extension only uses WidgetKit/SwiftUI
  and `UserDefaults`, no Flutter engine or CocoaPods dependency.
