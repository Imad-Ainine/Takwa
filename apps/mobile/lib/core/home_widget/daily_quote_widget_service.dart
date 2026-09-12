import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:home_widget/home_widget.dart';

import '../providers/adhkar_providers.dart' show kAdhkarData, DhikrItem;
import '../../features/duas/data/duas_data.dart' show kDuasData, DuaItem;

/// Keeps the "Dua of the Day" and "Dhikr of the Day" home-screen widgets in
/// sync — same idea as `PrayerHomeWidgetService`, just for content that
/// changes once a day instead of five times.
///
/// Both widgets pick deterministically from the app's own bundled
/// traditional duas/adhkar (`kDuasData`/`kAdhkarData` — the same data the
/// Duas/Adhkar screens show), so they work fully offline and never show
/// something the app itself wouldn't. The pick only depends on the
/// calendar date, so every device shows the same dua/dhikr on a given day
/// without needing a server.
class DailyQuoteWidgetService {
  DailyQuoteWidgetService._();

  static const androidDuaWidgetName = 'DuaOfDayWidgetProvider';
  static const androidDhikrWidgetName = 'DhikrOfDayWidgetProvider';

  /// Must match the `kind:` each iOS Widget registers under (see
  /// ios/PrayerWidget/DuaOfDayWidget.swift / DhikrOfDayWidget.swift).
  static const iOSDuaWidgetName = 'DuaOfDayWidget';
  static const iOSDhikrWidgetName = 'DhikrOfDayWidget';

  static const _duaDataKey = 'dua_of_day_widget_data';
  static const _dhikrDataKey = 'dhikr_of_day_widget_data';

  /// A widget card is small; anything longer than this reads as a wall of
  /// text once ellipsized, so the daily pick is drawn only from entries at
  /// or under this length (falls back to the full list if that pool is
  /// somehow empty — it never can be in practice, both datasets have
  /// plenty of short entries).
  static const _maxTextLength = 220;

  /// Push both widgets' data for "today". Cheap and idempotent — safe to
  /// call on every app start and every locale change; the actual pick only
  /// changes once the calendar date does.
  static Future<void> updateAll({required Locale locale}) async {
    await Future.wait([updateDua(locale: locale), updateDhikr(locale: locale)]);
  }

  static Future<void> updateDua({required Locale locale}) async {
    final pool = kDuasData.values
        .expand((list) => list)
        .where((d) => d.arabic.length <= _maxTextLength)
        .toList();
    final chosen = _pickForToday(
      pool.isNotEmpty ? pool : kDuasData.values.expand((l) => l).toList(),
    );
    if (chosen == null) return;

    final isArabic = locale.languageCode == 'ar';
    await _push(
      dataKey: _duaDataKey,
      androidName: androidDuaWidgetName,
      iOSName: iOSDuaWidgetName,
      payload: {
        'isRtl': isArabic,
        'titleEmoji': chosen.emoji,
        'title': isArabic ? 'دعاء اليوم' : 'Dua of the Day',
        'text': chosen.arabic,
        'subtitle': chosen.occasion,
        'count': 1,
      },
    );
  }

  static Future<void> updateDhikr({required Locale locale}) async {
    final pool = kAdhkarData.values
        .expand((list) => list)
        .where((d) => d.arabic.length <= _maxTextLength)
        .toList();
    final chosen = _pickForToday(
      pool.isNotEmpty ? pool : kAdhkarData.values.expand((l) => l).toList(),
    );
    if (chosen == null) return;

    final isArabic = locale.languageCode == 'ar';
    await _push(
      dataKey: _dhikrDataKey,
      androidName: androidDhikrWidgetName,
      iOSName: iOSDhikrWidgetName,
      payload: {
        'isRtl': isArabic,
        'titleEmoji': '📿',
        'title': isArabic ? 'ذكر اليوم' : 'Dhikr of the Day',
        'text': chosen.arabic,
        'subtitle': '',
        'count': chosen.count,
      },
    );
  }

  static Future<void> _push({
    required String dataKey,
    required String androidName,
    required String iOSName,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(dataKey, jsonEncode(payload));
      await HomeWidget.updateWidget(
        androidName: androidName,
        iOSName: iOSName,
      );

      // The pick only changes at midnight; arm exactly one alarm for that
      // so it flips over even while the app stays closed all day. (iOS
      // needs no equivalent — its TimelineProvider sets its own
      // `.after(nextMidnight)` reload policy from the same assumption.)
      final now = DateTime.now();
      final nextMidnight = DateTime(now.year, now.month, now.day + 1);
      await HomeWidget.scheduleWidgetUpdates([
        nextMidnight,
      ], androidName: androidName);
    } catch (e) {
      // Best-effort, same as PrayerHomeWidgetService: never let a widget
      // refresh failure take the app down with it.
      debugPrint('[DailyQuoteWidgetService] update ($dataKey) failed: $e');
    }
  }

  /// Deterministic "today's pick" — every device lands on the same index
  /// for the same calendar date, without needing a server or any stored
  /// state. Rotates through the whole pool once every `pool.length` days
  /// rather than resetting every January 1st (which a day-of-year index
  /// would do).
  static T? _pickForToday<T>(List<T> pool) {
    if (pool.isEmpty) return null;
    final epoch = DateTime(2024, 1, 1);
    final daysSinceEpoch = DateTime.now().difference(epoch).inDays;
    final index = daysSinceEpoch % pool.length;
    return pool[index < 0 ? index + pool.length : index];
  }
}
