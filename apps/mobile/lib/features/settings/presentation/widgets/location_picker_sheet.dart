import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/core/utils/timezone_resolver.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/notifications/location_prayer_update.dart';
import 'package:takwa/l10n/app_localizations.dart';

class LocationPickerSheet extends ConsumerStatefulWidget {
  const LocationPickerSheet({super.key});

  /// Helper to show this bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );
  }

  @override
  ConsumerState<LocationPickerSheet> createState() =>
      _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<LocationPickerSheet> {
  bool _isLoading = false;

  // List of professional curated cities with pre-defined coordinates and timezones
  // Used as a fallback and an easy-mode for users who don't want to use GPS.
  // 'name'/'country' are Arabic; 'nameEn'/'countryEn' are the matching
  // English display forms — plain proper-noun data (like SurahMeta.nameEn),
  // not translated sentences, so no ARB entries needed for these.
  static const List<Map<String, dynamic>> _cities = [
    {
      'name': 'الجزائر العاصمة',
      'nameEn': 'Algiers',
      'country': 'الجزائر',
      'countryEn': 'Algeria',
      'emoji': '🇩🇿',
      'lat': 36.7525,
      'lng': 3.04197,
      'tz': 'Africa/Algiers',
    },
    {
      'name': 'مكة المكرمة',
      'nameEn': 'Mecca',
      'country': 'السعودية',
      'countryEn': 'Saudi Arabia',
      'emoji': '🇸🇦',
      'lat': 21.3891,
      'lng': 39.8579,
      'tz': 'Asia/Riyadh',
    },
    {
      'name': 'المدينة المنورة',
      'nameEn': 'Medina',
      'country': 'السعودية',
      'countryEn': 'Saudi Arabia',
      'emoji': '🇸🇦',
      'lat': 24.4672,
      'lng': 39.6112,
      'tz': 'Asia/Riyadh',
    },
    {
      'name': 'القاهرة',
      'nameEn': 'Cairo',
      'country': 'مصر',
      'countryEn': 'Egypt',
      'emoji': '🇪🇬',
      'lat': 30.0444,
      'lng': 31.2357,
      'tz': 'Africa/Cairo',
    },
    {
      'name': 'القدس',
      'nameEn': 'Jerusalem',
      'country': 'فلسطين',
      'countryEn': 'Palestine',
      'emoji': '🇵🇸',
      'lat': 31.7683,
      'lng': 35.2137,
      'tz': 'Asia/Jerusalem',
    },
    {
      'name': 'دبي',
      'nameEn': 'Dubai',
      'country': 'الإمارات',
      'countryEn': 'United Arab Emirates',
      'emoji': '🇦🇪',
      'lat': 25.2048,
      'lng': 55.2708,
      'tz': 'Asia/Dubai',
    },
    {
      'name': 'الرباط',
      'nameEn': 'Rabat',
      'country': 'المغرب',
      'countryEn': 'Morocco',
      'emoji': '🇲🇦',
      'lat': 34.0209,
      'lng': -6.8416,
      'tz': 'Africa/Casablanca',
    },
    {
      'name': 'تونس',
      'nameEn': 'Tunis',
      'country': 'تونس',
      'countryEn': 'Tunisia',
      'emoji': '🇹🇳',
      'lat': 36.8065,
      'lng': 10.1815,
      'tz': 'Africa/Tunis',
    },
    {
      'name': 'بغداد',
      'nameEn': 'Baghdad',
      'country': 'العراق',
      'countryEn': 'Iraq',
      'emoji': '🇮🇶',
      'lat': 33.3128,
      'lng': 44.3615,
      'tz': 'Asia/Baghdad',
    },
  ];

  Future<void> _autoDetectLocation() async {
    setState(() => _isLoading = true);
    final result = await LocationPrayerManager.refreshLocation(ref);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context);
    }

    _showResultSnackBar(result);
  }

  Future<void> _selectManualLocation(Map<String, dynamic> cityData) async {
    HapticFeedback.selectionClick();

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final localizedName = isArabic
        ? cityData['name'] as String
        : cityData['nameEn'] as String;

    final s = ref.read(settingsDaoProvider);
    await s.set('latitude', cityData['lat'].toString());
    await s.set('longitude', cityData['lng'].toString());
    await s.set('timezone', cityData['tz'].toString());
    await s.set('cityName', localizedName);

    // Set Timezone
    TimezoneResolver.setLocalTimezone(cityData['tz'] as String);

    // We can't elegantly call private `_scheduleForLocation` directly,
    // but initializing works, or we can just rely on state notifications.
    // For now we will trigger a fake 'refreshLocation' or call schedule functions if public
    // Since LocationPrayerManager doesn't expose manual schedule, we just save and rely on the UI/providers refreshing it.

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);
    _showSnackBar(l10n.locationPickerLocationSetTo(localizedName), true);
  }

  void _showResultSnackBar(LocationResult result) {
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
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 13),
        ),
        backgroundColor: isSuccess
            ? context.colors.success
            : context.colors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Premium glassmorphism / dark theme sheet
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Subtle glow effect
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.teal.withValues(alpha: 0.15),
              ),
            ).blurred(blur: 50),
          ),
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.gold.withValues(alpha: 0.08),
              ),
            ).blurred(blur: 70),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  height: 5,
                  width: 48,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.teal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.teal.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Center(
                        child: Text('🌍', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.locationPickerTitle,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              color: context.colors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.locationPickerSubtitle,
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: context.colors.textDim,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    // Auto-Detect Location Card
                    _AutoDetectCard(
                      isLoading: _isLoading,
                      onTap: _autoDetectLocation,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: context.colors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Text(
                            l10n.locationPickerOrChooseCity,
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: context.colors.border.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Curated Cities Grid / List
                    ..._cities.map(
                      (city) => _CityCard(
                        cityData: city,
                        onTap: () => _selectManualLocation(city),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── EXTRAS ──

extension _BlurExt on Widget {
  Widget blurred({double blur = 10}) {
    return ImageFilterWidget(blur: blur, child: this);
  }
}

class ImageFilterWidget extends StatelessWidget {
  final double blur;
  final Widget child;

  const ImageFilterWidget({super.key, required this.blur, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class _AutoDetectCard extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _AutoDetectCard({required this.isLoading, required this.onTap});

  @override
  State<_AutoDetectCard> createState() => _AutoDetectCardState();
}

class _AutoDetectCardState extends State<_AutoDetectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) _hoverCtrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        if (!widget.isLoading) {
          _hoverCtrl.reverse();
          widget.onTap();
        }
      },
      onTapCancel: () => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hoverCtrl,
        builder: (context, child) => Transform.scale(
          scale: 1.0 - (_hoverCtrl.value * 0.02),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A5A58), Color(0xFF1E3C3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.colors.teal.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: context.colors.teal.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const Center(
                            child: TakwaLoadingIndicator(
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.locationPickerAutoDetectTitle,
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.locationPickerAutoDetectSubtitle,
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  final Map<String, dynamic> cityData;
  final VoidCallback onTap;

  const _CityCard({required this.cityData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Text(cityData['emoji'], style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? cityData['name'] : cityData['nameEn'],
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 14,
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isArabic ? cityData['country'] : cityData['countryEn'],
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 11,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.colors.textDim.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                l10n.locationPickerSelectButton,
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 11,
                  color: context.colors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
