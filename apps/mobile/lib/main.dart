import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takwa/l10n/app_localizations.dart';

import 'package:takwa/core/notifications/notifications_service.dart';
import 'package:takwa/core/notifications/adhan_foreground_service.dart';
import 'package:takwa/core/notifications/adhan_auto_trigger.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/theme_provider.dart';
import 'package:takwa/core/providers/locale_provider.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/providers/shared_preferences_provider.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/supabase/supabase_config.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import 'package:quran_library/quran_library.dart';

import 'package:takwa/core/notifications/overlay_background_service.dart';
import 'package:takwa/core/notifications/location_prayer_update.dart';
import 'package:takwa/core/notifications/overlays/unified_overlay_window.dart';

// ────────────────────────────────────────────
//  OVERLAY ENTRY POINT
// ────────────────────────────────────────────
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    debugPrint('Overlay isolate error: ${details.exceptionAsString()}');
  };
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // The overlay only ever renders Arabic religious content (adhan/
        // adhkar strings are Arabic literals regardless of the app's UI
        // language — see AdhkarCategory data), so it doesn't need to read
        // the user's locale setting here; fixed Arabic keeps this isolate
        // simple and matches what it actually displays.
        theme: AppTheme.dark(const Locale('ar')),
        home: const UnifiedOverlayWindow(),
      ),
    ),
  );
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  NotificationRouter.route(response.payload ?? '');
}

// ─────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv.load error: $e');
  }

  try {
    await initializeDateFormatting('ar', null);
    await initializeDateFormatting('en', null);
  } catch (e) {
    debugPrint('DateFormatting error: $e');
  }

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase initialize error: $e');
  }

  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences initialize error: $e');
  }

  try {
    AdhanForegroundService.initForegroundTask();
  } catch (e) {
    debugPrint('AdhanForegroundService error: $e');
  }

  try {
    OverlayBackgroundService.init();
  } catch (e) {
    debugPrint('OverlayBackgroundService error: $e');
  }

  try {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0E1A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } catch (e) {
    debugPrint('SystemChrome error: $e');
  }

  try {
    await NotificationsService.initialize();
  } catch (e) {
    debugPrint('NotificationsService initialize error: $e');
  }

  try {
    await QuranLibrary.init();
  } catch (e) {
    debugPrint('QuranLibrary init error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TakwaApp(),
    ),
  );
}

// ─────────────────────────────────────────
class TakwaApp extends ConsumerStatefulWidget {
  const TakwaApp({super.key});
  @override
  ConsumerState<TakwaApp> createState() => _TakwaAppState();
}

class _TakwaAppState extends ConsumerState<TakwaApp> {
  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onForegroundData);
    // بدء مراقبة أوقات الصلاة لتشغيل الأذان تلقائياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdhanAutoTrigger.start(ref, NotificationRouter.navigatorKey);
      _setupAuthListener();
    });
  }

  void _setupAuthListener() {
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.passwordRecovery) {
          debugPrint('Auth: Password Recovery mode detected');
          NotificationRouter.navigatorKey.currentState?.pushNamed(
            Routes.updatePassword,
          );
        } else if (event == AuthChangeEvent.signedIn) {
          debugPrint('Auth: User signed in. Triggering fullSync...');
          ref.read(syncManagerProvider).fullSync();
        }
      });
    } catch (e) {
      debugPrint('Auth listener setup error: $e');
    }
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onForegroundData);
    AdhanAutoTrigger.stop();
    super.dispose();
  }

  void _onForegroundData(Object data) {
    if (data is! Map) return;
    final action = data['action'];

    switch (action) {
      case 'show_adhan':
        AdhanAutoTrigger.handleForegroundData(
          data,
          NotificationRouter.navigatorKey,
          ref,
        );
        break;
      case 'refresh_location':
        LocationPrayerManager.refreshLocation(ref);
        break;
      case 'location_updated':
        _syncLocationFromBackground(data);
        break;
    }
  }

  Future<void> _syncLocationFromBackground(Map data) async {
    final lat = data['latitude']?.toString();
    final lng = data['longitude']?.toString();
    final cityName = data['cityName']?.toString();
    if (lat != null && lng != null) {
      final settings = ref.read(settingsDaoProvider);
      await settings.set('latitude', lat);
      await settings.set('longitude', lng);
      if (cityName != null) await settings.set('cityName', cityName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    // Driven by the language switcher in Settings (persisted via
    // localeProvider); defaults to Arabic, matching today's behavior. Also
    // picks the theme's font — Amiri/NotoNaskhArabic for Arabic (unchanged),
    // Poppins for English — see appFontFamily()/appBodyFontFamily().
    final locale = ref.watch(localeProvider);

    return WithForegroundTask(
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        navigatorKey: NotificationRouter.navigatorKey,
        themeMode: ref.watch(themeModeProvider),
        theme: isRamadan ? RamadanTheme.light(locale) : AppTheme.light(locale),
        darkTheme: isRamadan
            ? RamadanTheme.dark(locale)
            : AppTheme.dark(locale),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedAppLocales,
        // No manual Directionality override — MaterialApp's own
        // Localizations widget already derives it from `locale:` above
        // (WidgetsLocalizationAr resolves to TextDirection.rtl for 'ar'),
        // so this follows the active locale automatically in both
        // directions as the user switches language.
        initialRoute: Routes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
