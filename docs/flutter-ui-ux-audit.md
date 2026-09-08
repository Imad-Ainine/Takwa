# Takwa — Flutter UI/UX Audit

> **Scope:** `apps/mobile` + `packages/takwa_ui` — all screens, widgets, navigation flows, theme
> system, layout, typography, components, motion, accessibility, dark/light mode, RTL, and the
> performance characteristics of UI code.
>
> **Method:** static analysis of the codebase (160 Dart files, ~77k lines). No Flutter SDK was
> available in the audit environment, so no `flutter analyze` / runtime profiling was performed —
> every claim below is anchored to a file path and, where useful, a computed number. Contrast
> ratios are WCAG 2.1 relative-luminance calculations against the palettes in
> `packages/takwa_ui/lib/src/app_theme.dart` and `ramadan_theme.dart`.

---

## Table of contents

0. [Implementation Status](#0-implementation-status)
1. [Executive Summary](#1-executive-summary)
2. [Critical Issues (must-fix)](#2-critical-issues-must-fix)
3. [High-Priority Improvements](#3-high-priority-improvements)
4. [Medium / Low Priority & Polish](#4-medium--low-priority--polish)
5. [Design System & Theme Audit](#5-design-system--theme-audit)
6. [Accessibility Report](#6-accessibility-report)
7. [Recommended Refactor Plan](#7-recommended-refactor-plan)
8. [Best Practices Checklist](#8-best-practices-checklist)

---

## 0. Implementation Status

*Last reconciled 2026-09-08 against the code, not just the commit log — every row below was
re-checked with a fresh `grep`/read, since the original findings were themselves static-analysis
counts that don't always survive a second look (see the RTL note under §H5).*

**Score today: this is a materially different codebase than the one this audit describes.**
Every item in §2 (Critical) and §3 (High-Priority) has been addressed. What's left is concentrated
in §4 (Medium/Low) and the two structurally large Phase 4 items (§H2 emoji→icons, §H3
GestureDetector→TakwaTappable) that need either design assets or a file-by-file sweep wider than
one sitting.

### §2 Critical — all 11 resolved

| # | Status |
|---|---|
| C1 onPrimary contrast | ✅ Fixed — `onPrimary`/button foreground is `#241B05` (9.4:1+), full `goldText`/`tealText`/`successText`/`warningText`/`dangerText` on-surface ramp added |
| C2 App bar title contrast | ✅ Fixed — `titleColor` derived via `estimateBrightnessForColor`, not hardcoded white |
| C3 Forced light status bar | ✅ Fixed — the 16 per-screen `AnnotatedRegion`s are gone; the only 2 left are theme-derived (`main.dart`'s `TakwaApp.builder`) or intentionally independent of app theme (Quran reader's own sepia/night reading theme) |
| C4 `PrimaryButton` unreachable by screen readers | ✅ Fixed — real `onTap`, `Semantics(button:)`, 48dp min height, `try/finally`, locale-correct font |
| C5 Ramadan theme drops 11 component themes | ✅ Fixed — `RamadanTheme.dark/light` now call the shared `AppTheme.fromColors` builder; the ~200-line duplicate `ThemeData` and the second type scale are gone |
| C6 Silent error branches | ✅ Fixed — `TakwaErrorState` shared component exists and is used; the 2 remaining `error: (_, _) => SizedBox()` are documented, deliberate (a toast and a count badge that both have the failure surfaced elsewhere on the same screen) |
| C7 `Navigator.pop()` on non-route overlays | ✅ Fixed — both the drawer and `guest_mode_guard` sites call the right dismiss API now |
| C8 Ramadan painter cache thrashing | ✅ Fixed |
| C9 Forever-looping app bar animation | ✅ Fixed — `AppMotion`/`prefersReducedMotion`/`repeatUnlessReducedMotion` exist and are wired through the app bar and other ambient loops |
| C10 6-tab bottom nav, emoji, 9.5px labels | ✅ Fixed — 5 destinations, real `Icons.*` (outlined/filled selected state), theme type scale |
| C11 `MainShell(initialIndex:)` nav desync | ✅ Fixed — `currentTabProvider` is reconciled in `initState`'s post-frame callback |

### §3 High-Priority — all 9 resolved

H1 (type scale rebuilt to a 12–32px, role-based 10-step scale), H2 (bottom nav's emoji are gone —
see below for the rest of the app), H3 (`TakwaTappable` exists and is adopted in several places —
see below for the remaining call sites), H4 (chart has `Semantics`, fixed contrast, persistent
tooltip, `onTapCancel`; `fl_chart`/`scrollable_positioned_list` removed from `pubspec.yaml`), H5
(RTL — see the correction below), H6 (`AutomaticKeepAliveClientMixin` on all 6 shell tabs plus
Asma), H7 (`AuthField` rebuilt with focus chaining, `autofillHints`, `AutofillGroup`, a real
`FormField` driving a visible error border), H8 (sync-status affordance + optimistic checklist
writes), H9 (splash gates on a readiness future, not a flat timer) are all done.

**Correction to §H5 (RTL):** the original raw counts (`0 EdgeInsetsDirectional`,
`34 Positioned(left/right)`, `chevron_left`/`chevron_right` "both conventions ship") were accurate
counts but an overstated *bug* — re-reading the actual call sites: the drawer now opens from the
correct edge (`PositionedDirectional` + a direction-signed translate + `PopScope` for Android back);
essentially every drill-in/back chevron in the app (`quran_screen`, `free_reading_screen`,
`ai_memorize_screen`, `settings_widgets`, `checklist_screen`, `home_screen`,
`qiyam_dashboard_screen`, `quran_widgets`, …) is already `Directionality.of(context) == rtl ? ... :
...`, correctly mirrored per-locale; `EdgeInsets.only(left/right:)` is down to 1 site app-wide. The
remaining absolute `Positioned(left/right:)` sites are decorative corner glows/blobs and symmetric
`left: 0, right: 0` full-bleed bars — not locale-directional by nature, so `PositionedDirectional`
wouldn't change their behavior. The remaining `TextAlign.right` sites are all Qur'an/Khatma content
that's Arabic regardless of UI locale (same reasoning as `quranicVerse`'s fixed Amiri font in
§app_theme.dart) — not a locale bug either. **Net: RTL is in good shape; no further sweep needed**
unless a specific screen is visually confirmed wrong (this audit still has no Flutter SDK / device
to render against).

### §4 Medium/Low — mostly resolved; three fixed in this pass

✅ Done since the original audit: M1 (`settings:` on routes), M2 (404 styled+localized, safe
argument casts), M3 (real `MediaQuery` insets), M4/M5 (off-grid spacing/icon sizes swept), M6
(bottom sheets get `useSafeArea`/`showDragHandle`), M9 (`copyWith`/`lerp` implemented for real on
all 4 extensions), M11 (date picker theme no longer crashes/forces dark), M12 (leaked Arabic
strings localized), M14 (`Matrix4..scale` fixed), M15 (41 background patterns curated to 3),
M17 (`use_build_context_synchronously`/`deprecated_member_use` re-enabled, 803 `withOpacity` calls
migrated), M18 (no `print()` left in `lib/`).

🔧 **Fixed in this pass:**
- **M10** — `onboarding_screen.dart`'s 6 `CustomPainter`s (37 call sites) hardcoded the static
  dark-only `AppColors` alias, so onboarding rendered dark-mode illustration colors in light mode.
  Each painter now takes `AppColorsExtension colors` from its caller's `context.colors`.
- **M16** — `custom_pattern_background.dart` called `_ctrl.stop()`/`_ctrl.repeat()` inline in
  `build()`. Moved to `didChangeDependencies` (for the reduce-motion/MediaQuery half) plus a
  `ref.listen` registered in `build` (for the Ramadan-mode half) — `build()` no longer mutates
  state as a side effect.
- **M13 (partial)** — `PasswordStrengthBar`'s weak/medium/good/strong colors were the raw
  `Colors.redAccent/orange/amber/greenAccent` at every brightness; amber-as-text on a light surface
  was ~1.8:1. Dark mode keeps the original accents; light mode now uses the theme's `dangerText`/
  `warningText`/`successText` roles plus one darkened orange, all clearing 4.5:1.
- **Refactor Plan item 29 (`AppBarWidget` rollout)**, +6 screens — `qiyam_virtues_screen`,
  `qiyam_sunnah_guide_screen`, `qiyam_beginner_guide_screen`, `qiyam_sleep_calculator_screen`,
  `qiyam_calculator_screen`, `payment_methods_screen` each hand-rolled the same
  `Row(CustomLeadingButton, Spacer, Text(title), Spacer)` header; all six now use
  `Scaffold.appBar: AppBarWidget(...)` instead, dropping the duplicated `_buildAppBar` method in
  each. `qiyam_calculator_screen` got a small correctness fix as a side effect: its header used to
  live *inside* the `AsyncValue.when(data: ...)` branch, so there was no back button at all while
  prayer times were loading or failed to load — hoisting the app bar to `Scaffold.appBar` fixes that
  for every state. 22 of ~50 screens now use `AppBarWidget`, up from 16.
- **§H3 `TakwaTappable` rollout**, +7 sites in `quran_widgets.dart` — a first-pass scan classified
  all ~137 `GestureDetector`s app-wide by callback shape: 37 have `onTap` as their *only* callback
  (no drag/long-press/double-tap alongside it), making them unambiguous, mechanically-safe
  conversions; the other ~100 mix in gesture types `TakwaTappable` doesn't model and were left
  alone. Converted the 7 `onTap`-only sites in this one file as a first slice (`DailyVerseCard`'s
  drill-in chevron and two icon buttons, `KhatmaActionCard`'s outer tap area and its two
  `_circleBtn`s, `FeatureGridItem`, `AyahBlock`'s play marker), following the wrapper's own
  documented guidance throughout: `minTapSize: null` for anything sitting inline in a `Row`/`Wrap`
  next to other content (forcing 48dp there would eat into the layout rather than usefully growing
  the tap target), the default 48dp for standalone controls, and `borderRadius` matched to each
  child's own decoration so the press-tint clips to the same shape. One structural fix alongside
  it: `KhatmaActionCard` had its outer `margin:` on the same `Container` the `GestureDetector`
  wrapped, which would have put `TakwaTappable`'s rounded press-tint at the margin's outer (un-inset)
  edge instead of the card's actual edge — moved the margin to a `Padding` outside the tappable so
  the two rounded rects line up.

⏳ **Still open, deliberately not attempted here** (needs either visual QA on a device/simulator —
unavailable in this environment, same limitation the original audit had — or design assets this
pass doesn't have):
- **M13 (remainder)** — hardcoded hex/`Colors.*` literals in feature code beyond the one component
  above (`quran_helpers.dart`, `quran_reader_screen.dart`, `prayer_screen.dart`, the overlay
  windows). Large, and several of these are deliberately-fixed-regardless-of-theme colors (e.g. the
  Quran night-reading theme), so this needs a per-site read, not a mechanical sweep.
- **§H2 emoji → icon set** — the bottom nav is fixed; ~660 emoji characters remain across ~50
  files. Most are legitimate *content* (reaction emoji in `duas_data.dart`, achievement icons,
  ARB placeholder text) rather than chrome, per the audit's own distinction — but a real pass needs
  someone to sort which is which, and commissioning/adopting a line-icon set for the rest is a
  design decision, not a code one.
- **§H3 `TakwaTappable` rollout, remainder** — 30 more `onTap`-only sites identified (see above) are
  still on bare `GestureDetector`, plus the ~100 sites mixing in drag/long-press/double-tap that
  need a per-site read rather than the mechanical rule used here, across dozens of files. This pass
  covered one file as a proof of the classification and the pattern to follow; the rest is the same
  work at volume.
- **Refactor Plan item 29 (`AppBarWidget` rollout), remainder** — the rest of the ~50 screens fall
  into two buckets, neither of which is a safe drop-in: (a) screens whose header carries a `TabBar`
  (`manage_custom_ibadah_screen`, `khatma_history_screen`, `achievements_screen`'s `SliverAppBar`) —
  `AppBarWidget` has no `bottom:` slot for that today; (b) screens with a bespoke header shape
  (a two-line title+subtitle, a trailing decorative element, no title text at all, or a
  scroll-scaled layout like `misbaha_screen`'s `LayoutBuilder`) where swapping in the standardized
  centered-title bar is a visual-design call this pass can't verify without a device.
**Correction to the previous pass's note on item 30 (golden tests):** that note was wrong — re-
reading `main_shell_golden_test.dart` shows the full matrix already exists: all 3 themes × both text
scales × all 5 bottom-nav screens (30 cases, `test/golden/README.md` documents the one remaining
manual step). Nothing left to build here; the only blocker is a real `flutter test --update-goldens`
run, from a machine with the Flutter SDK, to generate baseline images and wire it into CI — the
README already spells out those steps in full. Not open work, just an unblockable-from-here step.
- **M7** (66→93 SnackBars as the app has grown, still only a handful with an action) and **M8**
  (no `barrierDismissible` review) — noted, not swept: adding a retry/undo action needs a real
  retry callback at each site, which is a per-site judgment call at this volume.

---

## 1. Executive Summary

**Overall UI/UX score: 5.0 / 10** *(at the time of the original audit — see §0 above for what's
changed since)*

A genuinely ambitious app with real craft in places — but the design system is *described* rather
than *enforced*, and the light theme, accessibility layer, and error states are effectively
unshipped.

### Biggest strengths

1. **A real token architecture exists.** `AppColorsExtension` / `AppTypographyExtension` /
   `AppDecorationsExtension` / `AppShadowsExtension` as `ThemeExtension`s with a `context.colors`
   accessor (`packages/takwa_ui/lib/src/app_theme.dart:519-526`) is the right pattern, and it's
   extracted into its own package.
2. **Spacing scale is correct and widely adopted.** `AppSpacing` (4/8/12/16/20/24/32) is a clean
   4pt grid.
3. **Haptics are taken seriously** — 65 `HapticFeedback` calls, mapped to intent
   (`selectionClick` for tabs, `mediumImpact` for commits).
4. **Serious visual identity investment** — 1,845 lines of hand-authored Islamic geometric
   painters, a custom branded loading indicator, a custom drawer transition. The ambition is above
   average.
5. **A complete ARB i18n pipeline** with Arabic/English and locale-aware font selection
   (`appFontFamily` / `appBodyFontFamily`).

### Biggest problems

1. **Light mode is broken, not just imperfect.** The primary CTA is **2.15:1**. The shared app bar
   title is white-on-near-white. 16 of 17 screens force white status-bar icons onto a white status
   bar.
2. **Two conflicting type scales ship inside one `ThemeData`**, and neither is actually used —
   35 distinct hardcoded font sizes, down to 8px, via a `style.naskh(11)` API that takes a raw
   pixel number.
3. **Accessibility is essentially absent**: 6 `Semantics` widgets and 0 `semanticLabel`s across
   160 files; the app's own `PrimaryButton` cannot be activated by a screen reader at all.
4. **Ramadan mode is a half-built parallel theme** that silently drops 11 component themes and
   resizes every piece of text in the app.
5. **Errors are hidden from the user** — 18 of 41 `AsyncValue` error branches render
   `const SizedBox()`.

---

## 2. Critical Issues (must-fix)

### C1 — Primary CTA is illegible in light mode (2.15:1 / 2.24:1)

`packages/takwa_ui/lib/src/app_theme.dart:637-638` and `core/widgets/primary_button.dart:73-77`

`ColorScheme.onPrimary` is set to `colors.background`. In light mode that is `#F9FAFB` on gold
`#C8A96E`:

| Pair | Ratio | WCAG AA (4.5:1) |
|---|---|---|
| `onPrimary #F9FAFB` on `primary #C8A96E` | **2.15** | ✗ |
| `PrimaryButton` white on gold `#C8A96E` | **2.24** | ✗ |
| white on gradient end `#B8920E` | **2.93** | ✗ |
| gold `#C8A96E` on white card | **2.24** | ✗ |
| teal `#3AAFA9` on white | **2.66** | ✗ |
| success `#4CAF7D` on white | **2.71** | ✗ |
| warning `#E0A044` on white | **2.26** | ✗ |

Every accent color in the light palette fails as a foreground. Gold at `#C8A96E` is a *surface*
color that has been pressed into service as a *text* color.

**Fix:** split the ramp — keep `gold` for fills/borders, add a `goldOn` (or `onGoldSurface`) role
dark enough to sit on white.

```dart
// AppColorsExtension.light
gold:        Color(0xFFC8A96E), // fills only
goldText:    Color(0xFF6B5320), // 6.1:1 on #FFFFFF — text/icons on light surfaces
tealText:    Color(0xFF14655F), // 6.3:1 on #FFFFFF
successText: Color(0xFF1E7A4C),

// ColorScheme
primary:   colors.gold,
onPrimary: const Color(0xFF241B05), // 9.4:1 on gold — NOT colors.background
```

---

### C2 — Shared app bar title is white on a near-white gradient in light mode

`core/widgets/app_bar_widget.dart:97-110`

```dart
final titleColor = widget.showBackground ? Colors.white : colors.textPrimary;
```

The light gradient is `background(#F9FAFB @65%)` → `gold @80%`. White title over the background end
is roughly **1.05:1**. The code compensates with a black `Shadow` (line 199-206) — a symptom, not a
fix.

```dart
final onGradient = ThemeData.estimateBrightnessForColor(
  Color.lerp(gradientStart, gradientEnd, 0.5)!,
) == Brightness.dark ? Colors.white : colors.textPrimary;
```

Also add `maxLines: 1, overflow: TextOverflow.ellipsis` — the title currently has neither.

---

### C3 — 16 of 17 screens force a light status bar regardless of theme

`main.dart:110-112` sets `statusBarIconBrightness: Brightness.light` and
`systemNavigationBarColor: Color(0xFF0A0E1A)` unconditionally. Then 16 screens re-assert it
(`home_screen.dart:113`, `checklist_screen.dart:104`, `statistics_screen.dart:166`,
`settings_screen.dart:47`, `qibla_screen.dart:76`, `misbaha_screen.dart:61`,
`mosques_screen.dart:143`, `auth_screen.dart:237`, …):

```dart
AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
```

In light theme: white icons on a `#F9FAFB` status bar. The nav bar is also hardcoded to a navy that
matches *neither* theme (dark bg is `#0D1117`).

**Fix:** delete all 16 `AnnotatedRegion`s. `appBarTheme.systemOverlayStyle` already handles this
correctly (`app_theme.dart:667-674`) — these overrides are actively defeating it. For the nav bar,
drive it from the resolved theme in `TakwaApp.build`, not from `main()` before any theme exists.

---

### C4 — `PrimaryButton` is unreachable by screen readers

`core/widgets/primary_button.dart:78-96`

The button fires on `onTapUp` and never sets `onTap`. `GestureDetector` only contributes
`SemanticsAction.tap` when `onTap` is non-null — so TalkBack/VoiceOver double-tap does **nothing**
on the app's principal action, on every screen.

```dart
return Semantics(
  button: true,
  enabled: !disabled,
  label: widget.label,
  child: GestureDetector(
    onTapDown: disabled ? null : (_) { _ctrl.forward(); HapticFeedback.lightImpact(); },
    onTapCancel: () => _ctrl.reverse(),
    onTap: disabled ? null : _run,   // ← the real handler lives here
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48), // currently ~44
      ...
```

Also in this widget:

- `fontFamily: 'NotoNaskhArabic'` is **hardcoded** (line 166) — every button label renders in an
  Arabic naskh face in the English UI, defeating the Poppins work in `appBodyFontFamily()`.
- No `try/finally` around `await widget.onTap!()` — a throwing handler pins the spinner forever.
- `borderRadius: 24` (line 115) ignores `AppRadius.button` (= 100).
- Disabled state is `textDim` on `border`: **1.76:1** in dark. Unreadable.

---

### C5 — Ramadan mode silently drops 11 component themes and rescales all text

`packages/takwa_ui/lib/src/ramadan_theme.dart:107-149`

`AppTheme._buildTheme` defines 17 component themes. `RamadanTheme.dark/light` define **6**.
Missing: `inputDecorationTheme`, `dialogTheme`, `snackBarTheme`, `chipTheme`, `checkboxTheme`,
`switchTheme`, `tabBarTheme`, `sliderTheme`, `progressIndicatorTheme`, `outlinedButtonTheme`,
`textButtonTheme`, `navigationBarTheme`.

Flip the Ramadan toggle and every text field, dialog, snackbar, chip, checkbox, switch, tab bar and
slider reverts to stock Material 3 defaults.

Worse — **two type scales coexist in the same `ThemeData`**:

| Role | `extensions:` (`AppTypographyExtension`) | `textTheme:` (`_buildTextTheme`) |
|---|---|---|
| displayLarge | 40 | 36 |
| headlineMedium | 22 | 18 |
| bodyLarge | 20 | 16 |
| bodyMedium | 18 | 14 |
| bodySmall | 16 | 12 |

`context.typography.bodyMedium` → 18px. `Theme.of(context).textTheme.bodyMedium` → 14px. Same
theme. Every Material widget reflows when Ramadan mode turns on.

**Fix:** `RamadanTheme` should call the same `_buildTheme` as `AppTheme`, passing only a different
`AppColorsExtension`. The entire 200-line duplicate is unnecessary:

```dart
static ThemeData dark([Locale locale = const Locale('ar')]) =>
    AppTheme.fromColors(_ramadanDarkColors, Brightness.dark, locale);
```

---

### C6 — 18 error branches render nothing

```
error: (_, _) => const SizedBox()   × 18   (of 41 total .when() calls)
```

`home_screen.dart:213, 231`, `animated_drawer.dart:378`, and 15 more. When the DB or network fails,
the card silently vanishes — no message, no retry, no indication anything went wrong. The user sees
a gap.

`main_shell.dart:143` is the worst case: `error: (_, _) => const _SplashScreen()`. A failed
`onboardingDoneProvider` leaves the user on a **permanent splash screen** with no way out.

Of the 13 that *do* render something, none has a retry button and several leak raw exceptions:

- `settings_screen.dart:104` → `Text('Error loading settings: $err')` (unlocalized English, raw
  stack info)
- `checklist_screen.dart:124`, `reminders_list_screen.dart:58` → `e.toString()` shown to users
- `_user_community_adhkar_views.dart:84` → `TextStyle(color: Colors.redAccent)` hardcoded

**Fix:** one shared component, used everywhere.

```dart
class TakwaErrorState extends StatelessWidget {
  const TakwaErrorState({super.key, required this.onRetry, this.message});
  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.cloud_off_rounded, size: 40, color: context.colors.textDim),
      const SizedBox(height: AppSpacing.md),
      Text(message ?? AppLocalizations.of(context)!.genericErrorTitle,
           textAlign: TextAlign.center, style: context.typography.bodySmall),
      const SizedBox(height: AppSpacing.lg),
      OutlinedButton(onPressed: onRetry,
        child: Text(AppLocalizations.of(context)!.retry)),
    ])),
  );
}

// error: (_, _) => TakwaErrorState(onRetry: () => ref.invalidate(todayRecordProvider)),
```

---

### C7 — `Navigator.pop()` called on non-route overlays

Two places pop the *page route* when they mean to dismiss an overlay:

- `app/animated_drawer.dart:269-273` — the drawer is a `Stack` layer, not a route.
  `Navigator.pop(context); Future.delayed(300ms, () => Navigator.pushNamed(...))` pops `MainShell`
  off the stack, then pushes Profile onto whatever's left, with no `context.mounted` check across
  the delay.
- `core/widgets/guest_mode_guard.dart:90` — the "العودة" button pops from inside a **tab**,
  ejecting the user from the shell entirely.

```dart
// drawer
onTap: () {
  onClose();                                     // the drawer's own close
  Navigator.of(context).pushNamed(Routes.profile);
}
```

---

### C8 — Ramadan background painter thrashes a static cache every frame

`packages/takwa_ui/lib/src/ramadan_theme.dart:358-419`

```dart
static List<Offset>? _stars;
static Picture? _cachedArabesque;
static Size? _cachedArabesqueSize;
```

These are **static** — shared across all live instances. There are 58 `CustomPatternBackground`
call sites, and they coexist at different sizes: one full-screen per screen, one inside the bottom
nav, **one inside every `PrimaryButton`** (`primary_button.dart:127-132`). Each frame, each
differently-sized painter invalidates the other's cache and re-records the full arabesque `Picture`
(nested loops over the viewport × a 20-segment star + 10 béziers per cell). The `Picture`s are never
disposed → native memory leak on every re-record.

`_stars` is generated once from the *first* size seen and reused for all others.

**Fix:** make the cache instance-level, key it on size, and dispose the old picture. Better: promote
the arabesque to a single `RepaintBoundary`-backed layer at the screen root rather than 58
independent painters.

---

### C9 — Every app bar runs a forever-looping 60fps animation

`core/widgets/app_bar_widget.dart:45-47`

```dart
_animationController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
  ..repeat(reverse: true);
```

Three `Transform.scale` + `Positioned` circles rebuild every frame, permanently, on every screen
using this bar. The `AnimatedBuilder` at line 137 ignores its `child` parameter, so nothing is
hoisted out of the rebuild. It is wrapped in `TCurvedEdgeWidget` → `ClipPath` whose clipper returns
`shouldReclip => true` (`curved_edges.dart:37`), so the non-rectangular clip path is recomputed
every frame too.

App-wide there are **26 infinite `.repeat()` animations across 16 files, 2 `RepaintBoundary`s, and
0 reduce-motion checks.**

```dart
// 1. respect the OS setting
if (MediaQuery.disableAnimationsOf(context)) { /* render static */ }
// 2. hoist the static subtree
AnimatedBuilder(animation: _ctrl, child: _circles, builder: (_, child) => ...)
// 3. shouldReclip => oldClipper != this;  // not `true`
```

---

### C10 — Bottom nav: 6 destinations, 9.5px labels, unreadable in dark

`app/main_shell.dart:338`, `:42-49`

- **6 tabs** exceeds Material's 3–5 destination guidance; at 375pt that's 62pt per tab.
- **`fontSize: 9.5`** — Material's smallest label is 11sp; iOS HIG floor is 11pt.
- Unselected labels use `colors.textDim` `#4A6070` on card `#1A2332` = **2.40:1**. Fails AA even
  before the 9.5px size.
- Icons are emoji (`🏠 🌙 ✅ 📊 ✨ ⚙️`), which cannot be tinted — the "selected" state is faked with
  a `Shadow` (line 315-320) because `color:` has no effect on a color-emoji font.

**Fix:** move Asma or Qiyam into the drawer to reach 5 tabs; replace emoji with a real icon set;
label ≥ 11px; use `colors.textSecondary` (7.32:1) for unselected.

---

### C11 — `MainShell(initialIndex:)` desyncs the nav from the content

`app/main_shell.dart:55-66` sets `PageController(initialPage: 5)` and `_tabAnims[5].forward()`, but
never writes `currentTabProvider`. `_buildShell()` then reads `currentIdx = 0`. Navigating to
`Routes.settings` shows the Settings page with **Home highlighted** in the nav bar, and the
`ref.listen` at line 155 won't correct it.

```dart
// initState
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref.read(currentTabProvider.notifier).state = widget.initialIndex;
});
```

---

## 3. High-Priority Improvements

### H1 — Typography is a free-for-all: 35 distinct font sizes

The `AdaptiveStyle` API is `style.naskh(11)` — a **raw pixel number**
(`ramadan_theme.dart:637-676`). 266 call sites pass 19 different values. Separately, 174 hardcoded
`fontSize:` literals. Full distribution:

```
8, 8.5, 9, 9.5, 10, 10.5, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 48, 50, 52, 60, 64, 90, 100
```

**~46 usages sit at ≤10px.** And `settings_widgets.dart:255-266` is the tell: it takes
`context.typography.bodyMedium` (18px) and immediately `.copyWith(fontSize: 13)`, with a 10.5px
sublabel. The scale is overridden because it doesn't fit — `bodyMedium: 18` / `bodySmall: 16` are
display sizes masquerading as body sizes.

**Fix:** rebuild the scale around real usage, then make `AdaptiveStyle` take a *role*, not a number.

```dart
// AppTypographyExtension — a 7-step scale, min 12
displayLarge : 32/1.2   headingLarge : 22/1.3
headingMedium: 18/1.35  bodyLarge    : 16/1.5
bodyMedium   : 14/1.5   labelMedium  : 13/1.4
caption      : 12/1.35

// AdaptiveStyle — role-based
TextStyle heading({Color? color}) => _t.headingMedium.copyWith(color: color);
TextStyle body({Color? color})    => _t.bodyMedium.copyWith(color: color);
TextStyle caption({Color? color}) => _t.caption.copyWith(color: color);
```

`grep -n "\.\(amiri\|naskh\|tajawal\)(" -r lib` gives the 266 migration sites.

---

### H2 — 575 emoji as the icon system

575 emoji characters in Dart source across 58 files, versus 55 `Icon(Icons.*)`. Emoji are the app's
icon language — bottom nav, settings rows (`settings_widgets.dart:246` `String icon`), checklist
prayers (`checklist_screen.dart:520-526`), achievements, drawer.

Why this caps the app's ceiling:

- **Not tintable.** `Text('🌙', style: TextStyle(color: s.goldLight))` (`home_screen.dart:411`) is a
  no-op — the author expected it to work.
- **Platform-divergent.** Noto Color Emoji on Android vs Apple Color Emoji on iOS vs vendor skins —
  the app looks like a different product per device, and the glyph set changes with OS version.
- **Not theme-aware.** Full-color emoji on both a dark navy and an ivory surface.
- **Not accessible.** They enter the semantics tree as their Unicode name ("crescent moon",
  "sparkles") when they're meant to be decorative.

**Fix:** commission or adopt one line-icon set (a 24dp stroke family reads well against this
gold/teal palette) and expose it as `TakwaIcons`. Keep emoji only where they are *content*
(user-chosen avatar `avatar_emoji`, reactions) — not chrome.

---

### H3 — 132 tap targets with no press feedback, and ripples globally disabled

132 `GestureDetector` vs 18 `InkWell`. On top of that, splashes are turned off where Material
*would* have provided feedback:

- `app_theme.dart:781-782` — `tabBarTheme: splashFactory: NoSplash, overlayColor: transparent`
- `duas_screen.dart:293-301` — `Theme(highlightColor: transparent, splashColor: transparent)`

Net result: outside of haptics, tapping most of this app produces **no visual response at all**. On
iOS haptics are subtle and on Android many users disable them, so a large share of interactions have
zero acknowledgement.

**Fix:** a shared pressable wrapper, so feedback is a property of the design system rather than
per-call-site discipline.

```dart
class TakwaTappable extends StatefulWidget {
  // AnimatedScale 1.0 → 0.97 on tapDown, plus a subtle overlay tint.
  // Wraps Semantics(button: true) and enforces minHeight/minWidth: 48.
}
```

---

### H4 — Chart is unreadable and invisible to assistive tech

`features/statistics/statistics_screen.dart:789-980`

- **No Y-axis, gridlines, or scale.** Bars are normalized to `maxPts` with no numeric reference —
  you cannot tell 10 points from 100.
- **Non-today bars use `colors.border`**: `#2A3A50` on card `#1A2332` = **1.37:1** (light:
  **1.23:1**). The comparison data is effectively invisible; only "today" is visible. The legend
  swatch has the same problem.
- **Tooltip shows only while the finger is down** (`onTapDown` → show, `onTapUp` → hide, line
  866-867). The value appears *under the user's finger* and vanishes on release. There is no
  `onTapCancel`, so dragging off a bar leaves the tooltip stuck open.
- **Zero `Semantics`** — the whole statistics view is silent to a screen reader.
- Weekly mode uses `pt.fullDayName` in 7 columns of ~45pt with **no `maxLines`/`overflow`** (line
  940-947) → guaranteed overflow with "الأربعاء" / "Wednesday".

Also: **`fl_chart` is declared in `pubspec.yaml` but imported 0 times.** Either adopt it here (it
gives you axes, tooltips and touch handling for free) or drop the dependency.
`scrollable_positioned_list` is likewise unused.

```dart
Semantics(
  label: l10n.chartBarSemantics(pt.dayName, pt.points, maxPts),
  child: /* bar */,
)
```

---

### H5 — RTL is not implemented; the app is authored LTR-first

For an Arabic-default app, the directional API usage is inverted:

| Direction-aware | count | Absolute | count |
|---|---|---|---|
| `EdgeInsetsDirectional` | **0** | `EdgeInsets.only(left/right:)` | 12 |
| `PositionedDirectional` | **0** | `Positioned(left/right:)` | 34 |
| `BorderRadiusDirectional` | **0** | `BorderRadius.only(topLeft…)` | 1 |
| `AlignmentDirectional` | 3 | `Alignment.centerLeft/topRight/…` | 60 |
| — | | `TextAlign.left/right` | 23 |

**The drawer opens from the wrong side in Arabic.** `animated_drawer.dart:110-116` uses
`Positioned(left: 0)` and `..translate(_slide.value, 0.0)` — a hard leftward drawer in both locales.
Material places the nav drawer on the *start* edge, which is the right in RTL. `Scaffold.drawer`
does this automatically; this custom one does not.

**Chevrons point both ways depending on the file.** Both conventions ship:

- `chevron_right` as "drill in": `qiyam_dashboard_screen.dart:528`,
  `settings_widgets.dart:275,352`, `checklist_screen.dart:718`, `home_screen.dart:1688`
- `chevron_left` as "drill in": `quran_screen.dart:233,344,425`,
  `free_reading_screen.dart:261,365`, `ai_memorize_screen.dart:252`

In *either* locale, roughly half the app's affordances point backwards.

**Fix:** `Icons.chevron_right` + `Icons.arrow_forward_ios` are already auto-mirrored by Flutter's
`matchTextDirection` for many icons — standardise on the LTR-named icon everywhere and let the
framework mirror. Then sweep `EdgeInsets.only` → `EdgeInsetsDirectional.only`, `TextAlign.right` →
`TextAlign.start`, and rebuild the drawer on `PositionedDirectional` + a direction-signed translate.

---

### H6 — Tab state is destroyed on every switch

`main_shell.dart:186-206`. Six screens in a `PageView` with `NeverScrollableScrollPhysics`, only
**1 file in the entire app** uses `AutomaticKeepAliveClientMixin` (`adhkar _screen.dart:264`).
Switching Home → Statistics → Home discards scroll position, expanded sections, and in-progress text
in `_DayNoteField`. It also re-runs each screen's 1.5s entry stagger, so returning to a tab feels
like a cold load.

```dart
class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;
  @override Widget build(BuildContext context) { super.build(context); ... }
}
```

---

### H7 — Forms have no focus management, no autofill, no visible error state

19 text fields. **0 `textInputAction`. 0 `FocusNode` / `autofocus` / `FocusScope`.
0 `autofillHints`.** 5 validators.

`core/widgets/auth_field.dart:68-73` sets `errorBorder: InputBorder.none` and wraps the field in an
`AnimatedContainer` whose border reacts only to focus — **a validation failure never turns the field
red.** The `hintText` is also the only label, so once the user types, the field's purpose disappears
(WCAG 3.3.2).

```dart
TextFormField(
  focusNode: widget.focusNode,
  textInputAction: widget.isLast ? TextInputAction.done : TextInputAction.next,
  onFieldSubmitted: (_) => widget.isLast ? widget.onSubmit?.call()
                                         : FocusScope.of(context).nextFocus(),
  autofillHints: widget.isPassword
      ? const [AutofillHints.password]
      : const [AutofillHints.email],
  decoration: InputDecoration(
    labelText: widget.hint,          // persistent floating label
    hintText: widget.example,
  ),
)
// and drive the AnimatedContainer border from error state:
border: Border.all(color: _hasError ? s.danger : (_focused ? s.gold : s.border)),
```

Wrap the auth form in `AutofillGroup` so password managers can fill it.

---

### H8 — No offline UI at all

`connectivityProvider` exists (`core/supabase/supabase_providers.dart:17`) and is read in exactly
one place (`favorites_providers.dart:31`). It is **never surfaced to the user**. Sync failures are
swallowed with `print('Offline book sync skipped: $e')` (`books_reading_provider.dart:90,116`).

For an offline-first daily tracker with cloud sync, the user has no way to know whether today's
entries are saved locally-only. Add a persistent, unobtrusive sync-status affordance (a small chip
in the app bar: synced / pending / offline) and a "last synced" line in the drawer.

Related: `checklist_screen.dart:566-583` does three sequential awaits (local write → re-read →
`syncDailyRecord`) on every prayer tap, with **no optimistic UI, no error handling, and
`updatedRec!`** which throws on null. A slow network makes the checkbox feel stuck.

---

### H9 — 3-second hard-coded splash

`features/splash/splash_screen.dart:52-57`

```dart
Timer(const Duration(milliseconds: 3000), () { ... pushReplacementNamed('/home'); });
```

Three seconds of mandatory waiting on every cold start, unrelated to whether init finished — and if
init takes longer, you navigate into a half-ready app. It also starts a 10-second `..repeat()`
background controller for a 3-second screen, and uses the raw string `'/home'` instead of
`Routes.home`.

**Fix:** gate on a readiness future with a minimum-display floor:

```dart
await Future.wait([
  ref.read(appReadyProvider.future),
  Future.delayed(const Duration(milliseconds: 600)), // avoid a flash
]);
```

---

## 4. Medium / Low Priority & Polish

**M1 — `MaterialPageRoute` never receives `settings`.** All ~55 routes in
`core/routes/app_routes.dart` do `MaterialPageRoute(builder: ...)` without `settings: settings`.
`ModalRoute.of(context)?.settings.name` is null everywhere, breaking route observers, analytics, and
deep-link restoration. One-line fix per case.

**M2 — The 404 route is a bare unstyled string.** `app_routes.dart:246-249` →
`Scaffold(body: Center(child: Text('Route not found')))`. No theme, no localization, no way back.
`booksChapter`/`booksPdf` do `settings.arguments as IslamicBook` — an unchecked cast that crashes on
a null argument.

**M3 — Magic status-bar inset.** `home_screen.dart:311` → `EdgeInsets.fromLTRB(16, 47, 16, 10)`. The
47 is a guessed status-bar height; use `MediaQuery.paddingOf(context).top`. Similarly
`SizedBox(width: 40)` at line 328 to dodge the drawer button, and `SizedBox(height: 100)` at line
258 / `checklist_screen.dart:189` to clear the nav bar.

**M4 — Off-grid spacing.** `AppSpacing` is a good 4pt scale, then: `SizedBox(height: 14)` × 8 in
`home_screen.dart`, `height: 30` and `height: 170` in the chart, `vertical: 11` /
`margin: bottom: 7` in `_PrayerRow`, `horizontal: 14` throughout `settings_widgets.dart`,
`vertical: 47`, `borderRadius: 10 / 18 / 24 / 28` alongside `AppRadius.lg/xl`.

**M5 — Sub-legible icon sizes.** `size: 6`, `8`, `10`, `12` appear (e.g. `animated_drawer.dart:366`
— an 8px chevron). Floor meaningful icons at 16dp, decorative at 12dp.

**M6 — Bottom sheets miss M3 affordances.** 17 `showModalBottomSheet`, **0 `useSafeArea`,
0 `showDragHandle`**. `settings_widgets.dart:355-370` hand-rolls a grabber and hand-computes
`MediaQuery.of(ctx).padding.bottom + 20`. Set both flags and delete the manual work. Only 1
`DraggableScrollableSheet` — long option lists in a `Column(mainAxisSize: min)` will overflow rather
than scroll.

**M7 — 66 SnackBars, 4 with an action.** Most feedback is a dead-end toast. Destructive and failure
paths deserve `SnackBarAction` (Undo / Retry).

**M8 — 0 `barrierDismissible`, 2 `PopScope`.** No Android back-button handling for the custom drawer
(back exits the screen instead of closing the drawer), and dialog dismissal behaviour is
unconsidered.

**M9 — `ThemeExtension` contracts are stubbed.** `copyWith()` returns `this` and `lerp()` returns
`this` for typography, decorations and shadows (`app_theme.dart:66, 265-269, 302-306`).
`AppColorsExtension.copyWith()` takes no arguments at all. Consequence: dark↔light theme transitions
animate colors but *snap* on everything else, and `copyWith` is unusable for per-screen overrides.

**M10 — `AppColors` static class aliases dark values.** `app_theme.dart:201-228`, still used 106
times in `mosques_screen.dart` and `onboarding_screen.dart` — those two screens render dark-mode
colors in light mode.

**M11 — Date picker drops all theme extensions.** `create_khatma_screen.dart:556-563` wraps the
picker in `Theme(data: ThemeData.dark().copyWith(...))`. Any `context.colors` inside that subtree
hits `extension<...>()!` on a null → crash. It also forces a dark picker in light mode.

**M12 — Un-localized strings remain** despite the ARB pipeline: `guest_mode_guard.dart:66,83,94`
(a whole Arabic dialog), `app_theme.dart:869` (`'$days يوم متواصل'` inside the shared design
system), `main_shell.dart:401,409` (splash title + hadith), `app_routes.dart:212`
(`?? 'الصلاة'`).

**M13 — Hardcoded palette colors in feature code.** 174 `Color(0x…)` literals and 75
`Colors.<named>` outside the theme. Worst offenders: `quran_helpers.dart` (24),
`quran_reader_screen.dart` (23), `prayer_screen.dart` (15), the three overlay windows (15/15/13).
`auth_field.dart:120-127` uses `Colors.redAccent/orange/amber/greenAccent` for password strength —
amber on light is ~1.8:1.

**M14 — `Matrix4..scale(v)` scales Z.** `animated_drawer.dart:122` — should be `scale(v, v, 1.0)`.

**M15 — 41 background pattern variants.** `BackgroundPattern` has 41 members backed by ~41 painters
in 1,845 lines. This is design-system bloat: it dilutes identity rather than reinforcing it, and no
call site can reason about which to pick. Curate down to 3–4 with documented semantics.

**M16 — Side effects inside `build()`.** `custom_pattern_background.dart:126-131` calls
`_ctrl.stop()` / `_ctrl.repeat()` during `build`, making builds non-idempotent. Move to
`didChangeDependencies` or a `ref.listen`.

**M17 — Lints that hide real bugs.** `apps/mobile/analysis_options.yaml` sets
`use_build_context_synchronously: ignore` and `deprecated_member_use: ignore`. The former masks ~15
async-gap `context` uses; the latter masks **803 `withOpacity` calls**, deprecated since Flutter
3.27 for precision loss (migrate to `.withValues(alpha:)`). Re-enable both and fix the fallout —
this is a mechanical sweep.

**M18 — 16 `print()` calls** in `lib/` (`avoid_print: ignore`).

---

## 5. Design System & Theme Audit

### Strengths

- Four typed `ThemeExtension`s with a clean `context.colors` / `.typography` / `.decorations` /
  `.shadows` accessor — the correct Flutter 3.x pattern, better than most codebases.
- Extracted into `packages/takwa_ui` with a clear boundary (`RamadanToggle` correctly left behind in
  the app layer because it touches providers).
- `AppSpacing` and `AppRadius` are well-formed scales.
- `AppShadowsExtension.fromColors` deriving light/dark shadow weight from
  `background.computeLuminance()` is a nice touch.
- Locale-driven font selection centralized in
  `appFontFamily` / `appBodyFontFamily` / `appFontFamilyFallback`.

### Gaps

**ColorScheme is under-specified.** `app_theme.dart:636-649` sets 11 roles. M3 has ~30, and unset
ones fall back to baseline values that clash with this palette. Missing and load-bearing:
`onSurfaceVariant`, `surfaceContainerLowest/Low/High/Highest`, `outlineVariant`,
`tertiary`/`onTertiary`, `errorContainer`/`onErrorContainer`, `inverseSurface`/`onInverseSurface`,
`surfaceTint`, `shadow`, `scrim`. Any M3 component you adopt later (NavigationBar, SearchBar, Badge,
DatePicker, BottomSheet) will render off-palette.

`RamadanTheme` uses `const ColorScheme.dark(...)` (`ramadan_theme.dart:111-121`) without `onError` —
so error text lands on baseline black over `rubyLight #B03040` = **3.34:1**.

**No `PageTransitionsTheme`.** 55 routes on stock platform transitions. A single custom shared-axis
transition is the cheapest "premium" win available:

```dart
pageTransitionsTheme: const PageTransitionsTheme(builders: {
  TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
}),
```

**No component-level `WidgetStateProperty` states.** Buttons define one visual state. No hover,
focus, pressed, or disabled overlays defined in theme.

**Design tokens leak by omission.** There is no `AppDurations` or `AppCurves`, so animation timing
is invented per site: 100 / 150 / 180 / 200 / 220 / 250 / 300 / 350 / 420 / 800 / 1000 / 1500 /
1800ms. Add:

```dart
class AppMotion {
  static const fast = Duration(milliseconds: 150);   // state change
  static const base = Duration(milliseconds: 250);   // enter/exit
  static const slow = Duration(milliseconds: 400);   // page/drawer
  static const emphasized = Curves.easeOutCubic;
}
```

### Recommended `ColorScheme` (light)

```dart
colorScheme: ColorScheme(
  brightness: Brightness.light,
  primary:            colors.gold,
  onPrimary:          const Color(0xFF241B05), // 9.4:1 — was 2.15:1
  primaryContainer:   colors.goldDim,
  onPrimaryContainer: const Color(0xFF3D2E08),
  secondary:          colors.teal,
  onSecondary:        Colors.white,
  secondaryContainer: colors.tealDim,
  onSecondaryContainer: const Color(0xFF0A3B38),
  tertiary:           colors.success,
  onTertiary:         Colors.white,
  error:              const Color(0xFFB3261E), // was E07070 (3.12:1)
  onError:            Colors.white,
  errorContainer:     const Color(0xFFF9DEDC),
  onErrorContainer:   const Color(0xFF410E0B),
  surface:            colors.card,
  onSurface:          colors.textPrimary,
  onSurfaceVariant:   colors.textSecondary,
  surfaceContainerLowest:  const Color(0xFFFFFFFF),
  surfaceContainerLow:     const Color(0xFFF9FAFB),
  surfaceContainer:        const Color(0xFFF3F4F6),
  surfaceContainerHigh:    const Color(0xFFECEEF1),
  surfaceContainerHighest: const Color(0xFFE5E7EB),
  outline:            colors.border,
  outlineVariant:     const Color(0xFFEDF0F4),
  shadow:             Colors.black,
  scrim:              Colors.black,
  inverseSurface:     const Color(0xFF1A2332),
  onInverseSurface:   const Color(0xFFE8EDF3),
  surfaceTint:        Colors.transparent,
),
```

---

## 6. Accessibility Report

**Grade: F.** This app would not pass an accessibility review, and in several regions (EU
Accessibility Act, US Section 508 for public-sector distribution) that is a compliance exposure, not
just a quality one.

| Check | Result |
|---|---|
| `Semantics` widgets | **6** across 160 files |
| `semanticLabel` | **0** |
| `MergeSemantics` / `ExcludeSemantics` | **0** |
| `tooltip:` on icon buttons | **7** (of 19 `IconButton`s) |
| `textScaler` handling | **0** |
| `MediaQuery.disableAnimations` checks | **0** |
| `FocusNode` / `FocusScope` / `autofocus` | **0** |
| `textInputAction` | **0** (19 fields) |
| `autofillHints` | **0** |
| `LayoutBuilder` | **1** |
| `minimumSize` / min tap constraints | **1** |

### Contrast failures (computed)

| Pair | Ratio | Where |
|---|---|---|
| `onPrimary` on `primary` (light) | **2.15** | every `ElevatedButton` |
| `PrimaryButton` white on gold | **2.24** | every primary CTA |
| App bar title white on light gradient | **~1.05** | `app_bar_widget.dart:110` |
| Chart bar `border` on `card` (dark) | **1.37** | `statistics_screen.dart:912` |
| Chart bar `border` on `card` (light) | **1.23** | same |
| Disabled `textDim` on `border` (dark) | **1.76** | `primary_button.dart:74` |
| `textDim` on `card` (dark) | **2.40** | nav labels, captions, chevrons |
| gold / teal / success / warning on white | **2.24–2.71** | all light-mode accents |

### Structural failures

- **`PrimaryButton` cannot be activated by a screen reader** (§C4) — the app's principal control.
- **Statistics charts are silent** — no `Semantics` on any bar, ring, or legend.
- **The `GuestModeGuard` scrim leaves the locked screen in the semantics tree**
  (`Opacity(0.3, AbsorbPointer(...))` blocks touch but not TalkBack) — screen reader users can read
  and traverse content they can't interact with.
- **The custom drawer has no focus trap and no `Semantics(scopesRoute:)`** — with the drawer open,
  assistive tech still reaches the content behind it.
- **Text sizes below the platform floor:** ~46 usages at ≤10px, including a 9.5px nav label and
  10.5px settings sublabels.
- **Placeholder-as-label** in every auth field (WCAG 3.3.2), and validation errors are visually
  invisible on the field.
- **No `textScaler` handling anywhere** — with a 40px `displayLarge` and 20px `bodyLarge`,
  `SizedBox(height: 170)` chart areas and `Row`s without `Flexible`, the app will overflow at 1.3×
  system font. There are only **22 `maxLines`** and **20 `TextOverflow`** across 77k lines.
- **26 infinite animations, 0 reduce-motion checks** — vestibular-sensitivity risk and a hard
  battery cost.

### Fastest path to a passing grade (roughly one sprint)

1. Fix the contrast pairs above (§C1, §H4) — purely a token change.
2. Add `Semantics(button: true)` + `onTap` to `TakwaTappable` and `PrimaryButton`; the 132
   `GestureDetector`s inherit it for free (§H3).
3. Enforce `minHeight: 48` in that same wrapper.
4. Raise the type floor to 12px and delete the ≤10px sizes.
5. Guard the 26 `.repeat()` controllers behind `MediaQuery.disableAnimationsOf(context)`.
6. Add `tooltip:` to all 19 `IconButton`s.
7. Test at `textScaleFactor: 1.5` and fix the overflows.

---

## 7. Recommended Refactor Plan

### Phase 0 — Quick wins (≈1 day, no architecture change)

1. Fix `onPrimary` and the light accent ramp (§C1). *One file, unblocks all of light mode.*
2. Delete the 16 `AnnotatedRegion<SystemUiOverlayStyle>` overrides and the hardcoded nav-bar color
   in `main.dart` (§C3).
3. Fix `app_bar_widget.dart` `titleColor`; add `maxLines`/`overflow` (§C2).
4. Add `onTap` + `Semantics` + `minHeight: 48` + `try/finally` + `appBodyFontFamily(locale)` to
   `PrimaryButton` (§C4).
5. Set `currentTabProvider` from `initialIndex` in `MainShell` (§C11).
6. Add `settings: settings` to all `MaterialPageRoute`s; style and localize the 404 (§M1, §M2).
7. Localize `guest_mode_guard.dart`, `StreakBadge`, `_SplashScreen`, `app_routes.dart:212` (§M12).
8. Remove `fl_chart` and `scrollable_positioned_list` from `pubspec.yaml` (§H4).

### Phase 1 — Correctness & states (≈3 days)

9. Build `TakwaErrorState` + `TakwaEmptyState`; replace all 18 `error: => SizedBox()` and the
   `_SplashScreen` error branch (§C6).
10. Fix both `Navigator.pop()` misuses (§C7).
11. Fix chart contrast, tooltip persistence, `onTapCancel`, label overflow; add bar `Semantics`
    (§H4).
12. Add `AutomaticKeepAliveClientMixin` to the six shell tabs (§H6).
13. Surface `connectivityProvider` as a sync-status affordance; wrap the checklist write path in
    `try/catch` with optimistic UI (§H8).
14. Replace the splash `Timer` with a readiness future (§H9).

### Phase 2 — Performance & motion (≈3 days)

15. Make `RamadanBgPainter`'s caches instance-level and disposed; hoist the pattern to one root
    layer (§C8).
16. Fix `AnimatedBuilder`s that ignore `child`; add `RepaintBoundary`s; fix `shouldReclip` (§C9).
17. Add `AppMotion` tokens; gate all 26 `.repeat()` controllers behind `disableAnimationsOf`
    (§C9, §M9).
18. Move `_headerCollapsed` off `setState` onto a `ValueListenableBuilder` so scrolling Home stops
    rebuilding 11 sections (`home_screen.dart:77-80`).
19. Re-enable `use_build_context_synchronously` and `deprecated_member_use`; migrate 803
    `withOpacity` → `withValues(alpha:)` (§M17).

### Phase 3 — Design system (≈1–2 weeks)

20. **Collapse `RamadanTheme` into `AppTheme.fromColors`** — deletes ~200 lines and the
    dual-type-scale bug in one move (§C5).
21. Fill out both `ColorScheme`s to the full M3 role set; add `PageTransitionsTheme` (§5).
22. Rebuild the type scale to 7 steps with a 12px floor; convert `AdaptiveStyle` to role-based
    methods; migrate the 266 raw-size call sites (§H1).
23. Fix the `ThemeExtension` `copyWith`/`lerp` stubs (§M9).
24. Ship `TakwaTappable` and migrate the 132 `GestureDetector`s (§H3).
25. Rebuild `AuthField` with focus, autofill, labels, and visible error state (§H7).

### Phase 4 — Identity & structure (≈2–3 weeks)

26. **Replace 575 emoji with a real icon set** (§H2). The single highest-leverage change for
    perceived quality.
27. Full RTL sweep: directional insets/positions/alignments, one chevron convention, right-side
    drawer (§H5).
28. Reduce the bottom nav to 5 destinations; curate 41 background patterns down to 3–4
    (§C10, §M15).
29. Reduce `AppBarWidget`'s 160dp default and give it scroll-linked collapse; adopt it across all
    ~50 screens (currently 4).
30. Add golden tests for the six main screens × {light, dark, Ramadan} × {1.0×, 1.5× text} — this is
    what stops the regressions above from returning.

---

## 8. Best Practices Checklist

### Architecture & tooling

- ✅ Feature-first folder structure, `presentation/domain/data` layering
- ✅ Riverpod throughout; design system extracted to its own package
- ✅ Full ARB localization pipeline (ar/en) with locale-aware fonts
- ✅ Melos monorepo, `flutter_lints`
- ⚠️ 352 `const` constructors — good, but only 2 `RepaintBoundary`s
- ❌ Key lints disabled (`use_build_context_synchronously`, `deprecated_member_use`)
- ❌ 16 `print()` in `lib/`
- ❌ Two unused dependencies shipped (`fl_chart`, `scrollable_positioned_list`)

### Theming

- ✅ `useMaterial3: true`, typed `ThemeExtension`s, `context.colors` accessor
- ✅ Spacing and radius scales exist and are used
- ⚠️ `ColorScheme` covers 11 of ~30 M3 roles
- ❌ Two conflicting type scales inside one `ThemeData`
- ❌ `RamadanTheme` omits 11 component themes
- ❌ `copyWith`/`lerp` stubbed on 4 extensions
- ❌ No `PageTransitionsTheme`, no motion tokens
- ❌ 174 hardcoded hex + 75 named `Colors.*` in feature code

### Layout & responsiveness

- ✅ 48 `SafeArea` usages; sliver-based scrolling on main screens
- ❌ 1 `LayoutBuilder`, 6 `MediaQuery.size` — no tablet/foldable/landscape story
- ❌ 0 `textScaler` handling; 22 `maxLines` across 77k lines
- ❌ Magic insets (`47`, `40`, `100`, `170`) instead of `MediaQuery` / intrinsics
- ❌ Portrait-locked in `main.dart`

### Components & interaction

- ✅ Haptics mapped to intent (65 sites)
- ✅ Entry-stagger animations on main screens
- ⚠️ 26 infinite animations, none reduce-motion aware
- ❌ 132 `GestureDetector` vs 18 `InkWell`; ripples globally disabled
- ❌ 0 `useSafeArea` / `showDragHandle` on 17 bottom sheets
- ❌ 4 of 66 SnackBars offer an action
- ❌ 1 explicit minimum tap-target constraint

### States

- ✅ Skeleton loaders exist (23 references); 1 branded loading indicator
- ⚠️ Empty states exist on ~7 screens of ~50
- ❌ 18 of 41 error branches render nothing; 0 have retry
- ❌ Raw `e.toString()` shown to users in 4+ places
- ❌ No offline indication anywhere

### Accessibility

- ✅ Bottom nav and `_PrayerRow` have correct `Semantics` — proof the team knows how
- ❌ 6 `Semantics` / 0 `semanticLabel` / 0 `MergeSemantics` app-wide
- ❌ Primary button unreachable by screen readers
- ❌ 8 contrast pairs below 3:1, including the primary CTA
- ❌ ~46 text usages ≤10px
- ❌ No focus management, autofill, or `textInputAction`

### RTL / i18n

- ✅ ARB pipeline, RTL derived correctly from `locale:` in `MaterialApp`
- ✅ Localized Hijri months and digit formatting
- ❌ 0 `EdgeInsetsDirectional` / `PositionedDirectional` / `BorderRadiusDirectional`
- ❌ Drawer opens from the wrong edge in Arabic
- ❌ Contradictory chevron directions across files
- ❌ Un-localized strings remain in 5+ files, including the design system

### Testing

- ✅ Unit tests for points, achievements, hijri, notification i18n
- ❌ 3 widget tests total; no golden tests; no accessibility tests

---

## The through-line

This codebase has the *scaffolding* of a design system but no *enforcement*. `AppSpacing` is
respected because it's the only convenient way to express spacing; the type scale is ignored because
`style.naskh(11)` is easier than fixing a scale that doesn't fit.

Every recommendation above reduces to the same principle — **make the correct thing the easy
thing**: role-based typography instead of pixel arguments, one `TakwaTappable` instead of 132
`GestureDetector`s, one `TakwaErrorState` instead of 41 hand-written branches, one theme builder
instead of two.
