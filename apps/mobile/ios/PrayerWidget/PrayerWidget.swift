import SwiftUI
import WidgetKit

// Home-screen prayer-times widget.
//
// Reads whatever JSON `PrayerHomeWidgetService` (Dart,
// lib/core/home_widget/prayer_home_widget_service.dart) last wrote into the
// shared App Group's UserDefaults under `prayer_widget_data` — this file
// does no prayer-time math or Hijri conversion of its own, only rendering.
//
// See SETUP.md in this folder for the one-time Xcode steps needed to turn
// this into a real Widget Extension target (adding this file to a new
// target isn't something that can be done outside Xcode).

// MARK: - Data model (mirrors the JSON payload written from Dart)

private struct PrayerInfo: Decodable {
    let key: String
    let label: String
    let time: String
    let timestampMs: Double

    var date: Date { Date(timeIntervalSince1970: timestampMs / 1000) }
}

private struct PrayerWidgetData: Decodable {
    let isRtl: Bool
    let weekday: String
    let hijri: String
    let gregorian: String
    let nextKey: String?
    let prayers: [PrayerInfo]

    /// Same data, but with `nextKey` recomputed for a given moment — used to
    /// build one timeline entry per prayer so the highlight moves on its own
    /// (see `PrayerProvider.getTimeline`).
    func withNextKey(asOf date: Date) -> PrayerWidgetData {
        let next = prayers.first { $0.date > date }?.key
        return PrayerWidgetData(
            isRtl: isRtl,
            weekday: weekday,
            hijri: hijri,
            gregorian: gregorian,
            nextKey: next,
            prayers: prayers
        )
    }
}

// MARK: - Timeline

private struct PrayerEntry: TimelineEntry {
    let date: Date
    let data: PrayerWidgetData?
}

private struct PrayerProvider: TimelineProvider {
    /// Must match `PrayerHomeWidgetService.iOSAppGroupId` (Dart) and the App
    /// Group added to both the Runner and this extension's entitlements.
    static let appGroupId = "group.com.takwa.PrayerWidget"
    static let dataKey = "prayer_widget_data"

    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date(), data: loadData())
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(PrayerEntry(date: Date(), data: loadData()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let now = Date()
        guard let data = loadData() else {
            // Nothing shared yet (fresh install before the app has run once).
            // Ask again soon rather than never — the app writes on launch.
            let timeline = Timeline(
                entries: [PrayerEntry(date: now, data: nil)],
                policy: .after(now.addingTimeInterval(30 * 60))
            )
            completion(timeline)
            return
        }

        // One entry for right now, plus one at each remaining prayer time
        // today, so the "next prayer" highlight advances on WidgetKit's own
        // schedule instead of needing the app to push again between prayers.
        var entryDates = [now]
        entryDates.append(contentsOf: data.prayers.map(\.date).filter { $0 > now })
        entryDates.sort()

        let entries = entryDates.map { date in
            PrayerEntry(date: date, data: data.withNextKey(asOf: date))
        }

        // By the time the last known prayer has passed, the app should have
        // pushed tomorrow's times (see PrayerHomeWidgetService); ask again
        // shortly after in case it hasn't run in the background.
        let reloadDate = (entryDates.last ?? now).addingTimeInterval(30 * 60)
        completion(Timeline(entries: entries, policy: .after(reloadDate)))
    }

    private func loadData() -> PrayerWidgetData? {
        guard
            let defaults = UserDefaults(suiteName: Self.appGroupId),
            let json = defaults.string(forKey: Self.dataKey),
            let jsonData = json.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(PrayerWidgetData.self, from: jsonData)
    }
}

// MARK: - View

private struct PrayerWidgetEntryView: View {
    let entry: PrayerEntry
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let theme = TakwaWidgetTheme.resolve(colorScheme)
        Group {
            if let data = entry.data {
                PrayerContentView(data: data, theme: theme)
                    .environment(\.layoutDirection, data.isRtl ? .rightToLeft : .leftToRight)
            } else {
                Text("افتح تطبيق تقوى لعرض أوقات الصلاة")
                    .font(.caption)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .containerBackground(for: .widget) { theme.backgroundGradient }
    }
}

private struct PrayerContentView: View {
    let data: PrayerWidgetData
    let theme: TakwaWidgetTheme

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(data.hijri)
                    .font(.system(size: 11))
                    .foregroundColor(theme.textSecondary)
                Spacer()
                Text(data.weekday)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                Spacer()
                Text(data.gregorian)
                    .font(.system(size: 11))
                    .foregroundColor(theme.textSecondary)
            }
            Divider().overlay(theme.divider)
            HStack(spacing: 0) {
                ForEach(data.prayers, id: \.key) { prayer in
                    let isNext = prayer.key == data.nextKey
                    VStack(spacing: 2) {
                        Text(prayer.label).font(.system(size: 11))
                        Text(prayer.time).font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(isNext ? theme.gold : theme.textPrimary)
                }
            }
        }
        .padding(14)
    }
}

// MARK: - Widget declaration

struct PrayerWidget: Widget {
    // Must match `PrayerHomeWidgetService.iOSWidgetName` (Dart) — that's the
    // `name`/`iOSName` `HomeWidget.updateWidget()` looks up by.
    let kind: String = "PrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("أوقات الصلاة")
        .description("يعرض مواقيت الصلاة اليوم مع تمييز الصلاة القادمة.")
        .supportedFamilies([.systemMedium])
    }
}

// `@main` for the whole extension lives in TakwaWidgetsBundle.swift, which
// lists this widget alongside DuaOfDayWidget/DhikrOfDayWidget — a WidgetKit
// extension has exactly one entry point for every Widget it hosts.
