import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:geocoding/geocoding.dart';
import '../providers/database_providers.dart';
import 'notifications_service.dart';
import '../utils/timezone_resolver.dart';
import '../../features/settings/providers/user_preferences_provider.dart';
import 'package:takwa/l10n/app_localizations.dart';

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
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      final lat = pos.latitude;
      final lng = pos.longitude;

      // حل الـ timezone
      final tzName = TimezoneResolver.resolveFromCoordinates(lat, lng);
      TimezoneResolver.setLocalTimezone(tzName);

      // حل اسم المدينة (Reverse Geocoding)
      String cityName = lookupAppLocalizations(
        const Locale('ar'),
      ).overlayServiceUnknownCity;
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

    final prefs = await ref.read(userPreferencesProvider.future);

    if (!prefs.prayerReminder) return;

    // حساب الأوقات بالـ timezone الصحيح
    final prayers = await PrayerTimesWithTimezone.calculate(
      latitude: lat,
      longitude: lng,
      madhab: prefs.madhab,
      method: prefs.calcMethod,
    );

    await NotificationsService.schedulePrayerNotifications(
      prayers: prayers,
      preAdhanEnabled: prefs.preAdhanNotif,
      iqamaEnabled: prefs.iqamaNotif,
      adhanMode: prefs.adhanMode,
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
      case 'Algeria':
        p = adhan.CalculationMethod.egyptian.getParameters();
        p.fajrAngle = 18.0;
        p.ishaAngle = 17.0;
        p.methodAdjustments.fajr = 0;
        p.methodAdjustments.dhuhr = 0;
        p.methodAdjustments.asr = 1;
        p.methodAdjustments.maghrib = 5;
        p.methodAdjustments.isha = 0;
        break;
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
      case 'MWL':
      default:
        p = adhan.CalculationMethod.muslim_world_league.getParameters();
        p.fajrAngle = 18.0;
        p.ishaAngle = 17.0;
    }
    p.madhab = madhab == 'hanafi' ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    return p;
  }

  /// اسم الـ timezone المترجم لواجهة المستخدم
  static String timezoneDisplayName(AppLocalizations l10n, String tzName) {
    final map = {
      'Africa/Algiers': l10n.timezoneAlgiers,
      'Africa/Tunis': l10n.timezoneTunis,
      'Africa/Cairo': l10n.timezoneEgypt,
      'Asia/Riyadh': l10n.timezoneRiyadh,
      'Asia/Dubai': l10n.timezoneDubai,
      'Asia/Kuwait': l10n.timezoneKuwait,
      'Asia/Beirut': l10n.timezoneBeirut,
      'Asia/Jerusalem': l10n.timezoneJerusalem,
    };
    return map[tzName] ?? tzName;
  }
}

enum LocationResult {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error;

  String message(AppLocalizations l10n) => switch (this) {
    LocationResult.success => l10n.locationResultSuccess,
    LocationResult.serviceDisabled => l10n.locationResultServiceDisabled,
    LocationResult.permissionDenied => l10n.locationResultPermissionDenied,
    LocationResult.permissionDeniedForever =>
      l10n.locationResultPermissionDeniedForever,
    LocationResult.error => l10n.locationResultError,
  };

  bool get isSuccess => this == LocationResult.success;
}

class LocationUpdateTile extends ConsumerStatefulWidget {
  const LocationUpdateTile({super.key});

  @override
  ConsumerState<LocationUpdateTile> createState() => _LocationUpdateTileState();
}

class _LocationUpdateTileState extends ConsumerState<LocationUpdateTile> {
  bool _loading = false;
  String? _lastCity;
  String? _lastTimezone;
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      _loadSaved();
    }
  }

  Future<void> _loadSaved() async {
    final s = ref.read(settingsDaoProvider);
    final l10n = AppLocalizations.of(context)!;
    final city = await s.get('cityName') ?? l10n.overlayServiceUnknownCity;
    final tz = await s.get('timezone') ?? '';
    final tzDisplay = tz.isNotEmpty
        ? PrayerTimesWithTimezone.timezoneDisplayName(l10n, tz)
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
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message(l10n),
          style: const TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 13),
        ),
        action:
            result == LocationResult.serviceDisabled ||
                result == LocationResult.permissionDeniedForever
            ? SnackBarAction(
                label: l10n.locationEnableAction,
                textColor: Colors.white,
                onPressed: () {
                  if (result == LocationResult.serviceDisabled) {
                    Geolocator.openLocationSettings();
                  } else {
                    Geolocator.openAppSettings();
                  }
                },
              )
            : null,
        backgroundColor: result.isSuccess
            ? context.colors.success
            : context.colors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(
          seconds:
              result == LocationResult.serviceDisabled ||
                  result == LocationResult.permissionDeniedForever
              ? 5
              : 3,
        ),
      ),
    );

    if (result.isSuccess) _loadSaved();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _loading ? null : _update,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.md,
        ),
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
                        child: TakwaLoadingIndicator(
                          color: context.colors.teal,
                          strokeWidth: 2,
                          size: 18,
                        ),
                      )
                    : const Text('📍', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.locationUpdateTileLabel,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (_lastCity != null)
                    Text(
                      '$_lastCity${_lastTimezone != null ? " · $_lastTimezone" : ""}',
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
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
