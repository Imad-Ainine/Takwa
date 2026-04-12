// ═══════════════════════════════════════════════════════════════
//  lib/main.dart — محاسبة النفس
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:takwa/core/notifications/notifications_service.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/theme_provider.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/supabase/supabase_config.dart';

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

  runApp(const ProviderScope(child: TakwaApp()));
}

class TakwaApp extends ConsumerWidget {
  const TakwaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;

    return MaterialApp(
      title: 'محاسبة النفس',
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
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      initialRoute: Routes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
