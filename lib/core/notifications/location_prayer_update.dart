// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/location_prayer_update.dart
//  تقوى — Location + Timezone + Prayer Auto-Update
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:google_fonts/google_fonts.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:geocoding/geocoding.dart';
import '../providers/database_providers.dart';
import 'notifications_service.dart';
import '../utils/timezone_resolver.dart';

// ═══════════════════════════════════════════════════════════════
//  LOCATION + PRAYER MANAGER (كامل)
// ═══════════════════════════════════════════════════════════════
class LocationPrayerManager {
  static bool _scheduled = false;
  static DateTime? _lastUpdate;

  /// التهيئة الكاملة عند بدء التطبيق
  static Future<void> initialize(dynamic ref) async {
    TimezoneResolver.ensureInitialized();

    final settings = ref.read(settingsDaoProvider);
    final savedLat = await settings.get('latitude');
    final savedLng = await settings.get('longitude');
    final savedTz = await settings.get('timezone');

    if (savedTz != null) {
      TimezoneResolver.setLocalTimezone(savedTz);
    }

    // تحديث إذا مضى أكثر من ساعة أو لا يوجد موقع محفوظ
    final lastUpdateStr = await settings.get('lastLocationUpdate');
    final lastUpdate = lastUpdateStr != null
        ? DateTime.tryParse(lastUpdateStr)
        : null;
    final needsUpdate =
        lastUpdate == null ||
        DateTime.now().difference(lastUpdate).inHours >= 1;

    if (needsUpdate || savedLat == null) {
      await refreshLocation(ref);
    } else {
      // استخدم المحفوظ وجدول الإشعارات
      final lat = double.tryParse(savedLat) ?? 36.7;
      final lng = double.tryParse(savedLng ?? '') ?? 3.0;
      await _scheduleForLocation(ref, lat, lng);
    }
  }

  /// تحديث الموقع يدوياً
  static Future<LocationResult> refreshLocation(dynamic ref) async {
    try {
      // تحقق من الإذن
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.permissionDenied;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationResult.permissionDeniedForever;
      }

      // الحصول على الموقع
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      final lat = pos.latitude;
      final lng = pos.longitude;

      // حل الـ timezone
      final tzName = TimezoneResolver.resolveFromCoordinates(lat, lng);
      TimezoneResolver.setLocalTimezone(tzName);

      // حل اسم المدينة (Reverse Geocoding)
      String cityName = 'غير محدد';
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          cityName =
              '${p.locality ?? p.subAdministrativeArea ?? ''}, ${p.country ?? ''}';
          if (cityName.startsWith(', ')) cityName = cityName.substring(2);
        }
      } catch (_) {}

      // حفظ في الإعدادات
      final settings = ref.read(settingsDaoProvider);
      await settings.set('latitude', lat.toString());
      await settings.set('longitude', lng.toString());
      await settings.set('timezone', tzName);
      await settings.set('cityName', cityName);
      await settings.set(
        'lastLocationUpdate',
        DateTime.now().toIso8601String(),
      );

      // جدولة الإشعارات بالموقع الجديد
      await _scheduleForLocation(ref, lat, lng);

      return LocationResult.success;
    } on LocationServiceDisabledException {
      return LocationResult.serviceDisabled;
    } on PermissionDeniedException {
      return LocationResult.permissionDenied;
    } catch (e) {
      return LocationResult.error;
    }
  }

  /// جدولة إشعارات الصلاة لموقع محدد
  static Future<void> _scheduleForLocation(
    dynamic ref,
    double lat,
    double lng,
  ) async {
    if (_scheduled &&
        _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!).inMinutes < 10) {
      return;
    }

    final settings = ref.read(settingsDaoProvider);
    final madhab = await settings.get('madhab') ?? 'shafi';
    final method = await settings.get('calcMethod') ?? 'MWL';
    final prayerReminder = await settings.getBool(
      'prayerReminder',
      defaultVal: true,
    );
    final wakeUpFajr = await settings.getBool(
      'wakeUpBeforeFajr',
      defaultVal: false,
    );

    if (!prayerReminder) return;

    // حساب الأوقات بالـ timezone الصحيح
    final prayers = await PrayerTimesWithTimezone.calculate(
      latitude: lat,
      longitude: lng,
      madhab: madhab,
      method: method,
    );

    await NotificationsService.schedulePrayerNotifications(
      prayers: prayers,
      wakeUpBeforeFajr: wakeUpFajr,
    );

    _scheduled = true;
    _lastUpdate = DateTime.now();
  }

  /// إعادة الجدولة عند منتصف الليل (لليوم الجديد)
  static Future<void> scheduleMidnightReschedule(dynamic ref) async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);

    Future.delayed(diff, () async {
      await refreshLocation(ref);
      // إعادة الجدولة كل يوم
      scheduleMidnightReschedule(ref);
    });
  }
}

// ═══════════════════════════════════════════════════════════════
//  PRAYER TIMES مع TIMEZONE
// ═══════════════════════════════════════════════════════════════
class PrayerTimesWithTimezone {
  /// حساب الأوقات مع مراعاة الـ timezone المحلي
  static Future<List<PrayerTimeInfo>> calculate({
    required double latitude,
    required double longitude,
    required String madhab,
    required String method,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();

    // تحويل للـ timezone المحلي
    final localNow = tz.TZDateTime.now(tz.local);
    final localDate = date != null
        ? tz.TZDateTime(tz.local, date.year, date.month, date.day)
        : localNow;

    final coords = adhan.Coordinates(latitude, longitude);
    final params = _buildParams(method, madhab);
    final dateComponents = adhan.DateComponents(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    final times = adhan.PrayerTimes(coords, dateComponents, params);

    // تحويل أوقات الصلاة للـ timezone المحلي
    DateTime toLocal(DateTime utcTime) {
      return tz.TZDateTime.from(utcTime, tz.local);
    }

    return [
      PrayerTimeInfo(
        name: 'fajr',
        nameAr: 'الفجر',
        emoji: '🌅',
        time: toLocal(times.fajr),
        notifId: NotifIds.fajr,
      ),
      PrayerTimeInfo(
        name: 'dhuhr',
        nameAr: 'الظهر',
        emoji: '☀️',
        time: toLocal(times.dhuhr),
        notifId: NotifIds.dhuhr,
      ),
      PrayerTimeInfo(
        name: 'asr',
        nameAr: 'العصر',
        emoji: '🌤',
        time: toLocal(times.asr),
        notifId: NotifIds.asr,
      ),
      PrayerTimeInfo(
        name: 'maghrib',
        nameAr: 'المغرب',
        emoji: '🌆',
        time: toLocal(times.maghrib),
        notifId: NotifIds.maghrib,
      ),
      PrayerTimeInfo(
        name: 'isha',
        nameAr: 'العشاء',
        emoji: '🌃',
        time: toLocal(times.isha),
        notifId: NotifIds.isha,
      ),
    ];
  }

  static adhan.CalculationParameters _buildParams(
    String method,
    String madhab,
  ) {
    adhan.CalculationParameters p;
    switch (method) {
      case 'Egypt':
        p = adhan.CalculationMethod.egyptian.getParameters();
        break;
      case 'Karachi':
        p = adhan.CalculationMethod.karachi.getParameters();
        break;
      case 'UmmAlQura':
        p = adhan.CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'ISNA':
        p = adhan.CalculationMethod.north_america.getParameters();
        break;
      default:
        p = adhan.CalculationMethod.muslim_world_league.getParameters();
    }
    p.madhab = madhab == 'hanafi' ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    return p;
  }

  /// تنسيق الوقت بالـ timezone المحلي
  static String formatLocalTime(DateTime dt) {
    final local = tz.TZDateTime.from(dt, tz.local);
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'ص' : 'م';
    return '$h:$m $ampm';
  }

  /// اسم الـ timezone بالعربي
  static String timezoneDisplayName(String tzName) {
    const map = {
      'Africa/Algiers': 'الجزائر (UTC+1)',
      'Africa/Tunis': 'تونس (UTC+1)',
      'Africa/Cairo': 'مصر (UTC+2)',
      'Asia/Riyadh': 'الرياض (UTC+3)',
      'Asia/Dubai': 'دبي (UTC+4)',
      'Asia/Kuwait': 'الكويت (UTC+3)',
      'Asia/Beirut': 'بيروت (UTC+3)',
      'Asia/Jerusalem': 'القدس (UTC+3)',
    };
    return map[tzName] ?? tzName;
  }
}

// ═══════════════════════════════════════════════════════════════
//  RESULT ENUM
// ═══════════════════════════════════════════════════════════════
enum LocationResult {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error;

  String get messageAr => switch (this) {
    LocationResult.success => 'تم تحديث الموقع بنجاح ✓',
    LocationResult.serviceDisabled => 'GPS غير مفعّل، يرجى تفعيله',
    LocationResult.permissionDenied => 'تم رفض إذن الموقع',
    LocationResult.permissionDeniedForever =>
      'يرجى تفعيل إذن الموقع من الإعدادات',
    LocationResult.error => 'خطأ في تحديد الموقع',
  };

  bool get isSuccess => this == LocationResult.success;
}

// ═══════════════════════════════════════════════════════════════
//  LOCATION UPDATE WIDGET (يُضاف للـ Settings)
// ═══════════════════════════════════════════════════════════════
class LocationUpdateTile extends ConsumerStatefulWidget {
  const LocationUpdateTile({super.key});

  @override
  ConsumerState<LocationUpdateTile> createState() => _LocationUpdateTileState();
}

class _LocationUpdateTileState extends ConsumerState<LocationUpdateTile> {
  bool _loading = false;
  String? _lastCity;
  String? _lastTimezone;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final s = ref.read(settingsDaoProvider);
    final city = await s.get('cityName') ?? 'غير محدد';
    final tz = await s.get('timezone') ?? '';
    final tzDisplay = tz.isNotEmpty
        ? PrayerTimesWithTimezone.timezoneDisplayName(tz)
        : null;

    if (mounted) {
      setState(() {
        _lastCity = city;
        _lastTimezone = tzDisplay;
      });
    }
  }

  Future<void> _update() async {
    setState(() => _loading = true);
    final result = await LocationPrayerManager.refreshLocation(ref);
    setState(() => _loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.messageAr,
          style: GoogleFonts.notoNaskhArabic(fontSize: 13),
        ),
        backgroundColor: result.isSuccess
            ? context.colors.success
            : context.colors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );

    if (result.isSuccess) _loadSaved();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _update,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: context.colors.teal,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('📍', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تحديث الموقع وأوقات الصلاة',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 13,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (_lastCity != null)
                    Text(
                      '$_lastCity${_lastTimezone != null ? " · $_lastTimezone" : ""}',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 10,
                        color: context.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.refresh_rounded,
              size: 18,
              color: context.colors.teal.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
