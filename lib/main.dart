// ═══════════════════════════════════════════════════════════════
//  lib/main.dart — تقوى
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
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
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/theme_provider.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/supabase/supabase_config.dart';
import 'package:quran_library/quran_library.dart';

import 'package:takwa/core/notifications/overlay_background_service.dart';
import 'package:takwa/core/notifications/location_prayer_update.dart';

// تلقي الإشعارات والتطبيق في الخلفية
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  NotificationRouter.route(response.payload ?? '');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ar', null);

  // تهيئة Supabase
  await SupabaseConfig.initialize();

  // تهيئة خدمة الأذان في الخلفية
  AdhanForegroundService.initForegroundTask();

  // تهيئة خدمة نافذة الأذكار العائمة
  OverlayBackgroundService.init();

  // حماية الخصوصية — منع التقاط الشاشة في قائمة التطبيقات الأخيرة
  await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);

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

  // تهيئة الإشعارات
  await NotificationsService.initialize();

  // تهيئة مكتبة القرآن
  await QuranLibrary.init();

  runApp(const ProviderScope(child: TakwaApp()));
}

class TakwaApp extends ConsumerStatefulWidget {
  const TakwaApp({super.key});
  @override
  ConsumerState<TakwaApp> createState() => _TakwaAppState();
}

class _TakwaAppState extends ConsumerState<TakwaApp> {
  @override
  void initState() {
    super.initState();
    // Listen for adhan foreground task data → show overlay screen
    FlutterForegroundTask.addTaskDataCallback(_onAdhanData);
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onAdhanData);
    super.dispose();
  }

  void _onAdhanData(Object data) {
    if (data is Map) {
      final action = data['action'];
      if (action == 'show_adhan') {
        final prayerName = (data['prayer'] as String?) ?? 'الصلاة';
        NotificationRouter.navigatorKey.currentState?.pushNamed(
          '/adhan',
          arguments: prayerName,
        );
      } else if (action == 'refresh_location') {
        LocationPrayerManager.refreshLocation(ref);
      }
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
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        initialRoute: Routes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
