import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:takwa/core/notifications/notifications_service.dart';
import 'package:takwa/core/notifications/adhan_foreground_service.dart';
import 'package:takwa/core/notifications/adhan_auto_trigger.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/theme_provider.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/supabase/supabase_config.dart';
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
        theme: AppTheme.dark,
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
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ar', null);

  await SupabaseConfig.initialize();
  AdhanForegroundService.initForegroundTask();
  // try {
  //   await FlutterWindowManagerPlus.addFlags(
  //     FlutterWindowManagerPlus.FLAG_SECURE,
  //   );
  // } catch (e) {
  //   debugPrint('WindowManager Error: $e');
  // }

  OverlayBackgroundService.init();

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

  await NotificationsService.initialize();
  await QuranLibrary.init();

  runApp(const ProviderScope(child: TakwaApp()));
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
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('Auth: Password Recovery mode detected');
        NotificationRouter.navigatorKey.currentState?.pushNamed(
          Routes.updatePassword,
        );
      }
    });
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

    return WithForegroundTask(
      child: MaterialApp(
        title: 'تقوى',
        debugShowCheckedModeBanner: false,
        navigatorKey: NotificationRouter.navigatorKey,
        themeMode: ref.watch(themeModeProvider),
        theme: isRamadan ? RamadanTheme.light : AppTheme.light,
        darkTheme: isRamadan ? RamadanTheme.dark : AppTheme.dark,
        locale: const Locale('ar', 'SA'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', 'SA'), Locale('ar')],
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        initialRoute: Routes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
