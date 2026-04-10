// // ═══════════════════════════════════════════════════════════════
// //  lib/main.dart + lib/app/app_shell.dart
// //  محاسبة النفس — Main Entry Point + Navigation Shell
// // ═══════════════════════════════════════════════════════════════

// // ─────────────────────────────────────────  main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'core/theme/app_theme.dart';
// import 'core/notifications/notifications_service.dart';
// import 'app/app_shell.dart';

// // تلقي الإشعارات والتطبيق في الخلفية
// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse response) {
//   NotificationRouter.route(response.payload ?? '');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // إخفاء شريط الحالة الافتراضي
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//     ),
//   );

//   // قفل الاتجاه عمودياً
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   // تهيئة الإشعارات
//   await NotificationsService.initialize();

//   runApp(const ProviderScope(child: MuhasabaApp()));
// }

// // ─────────────────────────────────────────
// //  ROOT APP
// // ─────────────────────────────────────────
// class MuhasabaApp extends ConsumerWidget {
//   const MuhasabaApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return MaterialApp(
//       title: 'محاسبة النفس',
//       debugShowCheckedModeBanner: false,
//       navigatorKey: NotificationRouter.navigatorKey,
//       theme: AppTheme.dark,
//       locale: const Locale('ar', 'SA'),
//       supportedLocales: const [Locale('ar', 'SA')],

//       // RTL
//       builder: (context, child) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: child!,
//       ),

//       // Named routes
//       initialRoute: '/',
//       routes: {
//         '/':          (_) => const AppShell(),
//         '/checklist': (_) => const _ChecklistRoute(),
//         '/statistics':(_) => const _StatisticsRoute(),
//         '/settings':  (_) => const _SettingsRoute(),
//         '/onboarding':(_) => const _OnboardingRoute(),
//       },

//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           default:
//             return MaterialPageRoute(builder: (_) => const AppShell());
//         }
//       },
//     );
//   }
// }

// // Lazy route wrappers (avoid importing all screens at once)
// class _ChecklistRoute extends StatelessWidget {
//   const _ChecklistRoute();
//   @override
//   Widget build(BuildContext context) =>
//       const AppShell(initialIndex: 1);
// }

// class _StatisticsRoute extends StatelessWidget {
//   const _StatisticsRoute();
//   @override
//   Widget build(BuildContext context) =>
//       const AppShell(initialIndex: 2);
// }

// class _SettingsRoute extends StatelessWidget {
//   const _SettingsRoute();
//   @override
//   Widget build(BuildContext context) =>
//       const AppShell(initialIndex: 3);
// }

// class _OnboardingRoute extends StatelessWidget {
//   const _OnboardingRoute();
//   @override
//   Widget build(BuildContext context) => const OnboardingScreen();
// }

// // ═══════════════════════════════════════════════════════════════
// //  APP SHELL  (lib/app/app_shell.dart)
// // ═══════════════════════════════════════════════════════════════
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../core/theme/app_theme.dart';
// import '../core/database/database_providers.dart';
// import '../core/notifications/notifications_service.dart';
// import '../features/home/presentation/screens/home_screen.dart';
// import '../features/checklist/presentation/screens/checklist_screen.dart';
// import '../features/statistics/presentation/screens/statistics_screen.dart';
// import '../features/settings/presentation/screens/settings_screen.dart';
// import '../features/onboarding/onboarding_screen.dart';

// // ─────────────────────────────────────────
// //  CURRENT TAB PROVIDER
// // ─────────────────────────────────────────
// final _currentTabProvider = StateProvider<int>((ref) => 0);

// // ─────────────────────────────────────────
// //  ONBOARDING CHECK
// // ─────────────────────────────────────────
// final _onboardingDoneProvider = FutureProvider<bool>((ref) async {
//   final v = await ref.watch(settingsDaoProvider).get('onboardingDone');
//   return v == 'true';
// });

// // ─────────────────────────────────────────
// //  APP SHELL
// // ─────────────────────────────────────────
// class AppShell extends ConsumerStatefulWidget {
//   final int initialIndex;
//   const AppShell({super.key, this.initialIndex = 0});

//   @override
//   ConsumerState<AppShell> createState() => _AppShellState();
// }

// class _AppShellState extends ConsumerState<AppShell>
//     with TickerProviderStateMixin {
//   late final PageController _pageCtrl;
//   late final List<AnimationController> _tabAnims;

//   static const _tabs = [
//     _TabInfo('🏠', 'الرئيسية',   0),
//     _TabInfo('✅', 'المحاسبة',   1),
//     _TabInfo('📊', 'إحصائيات',  2),
//     _TabInfo('⚙️', 'الإعدادات', 3),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageCtrl = PageController(initialPage: widget.initialIndex);

//     _tabAnims = List.generate(_tabs.length, (i) =>
//       AnimationController(vsync: this,
//           duration: const Duration(milliseconds: 300)));

//     // تفعيل التبويب الأول
//     _tabAnims[widget.initialIndex].forward();

//     // جدولة الإشعارات عند أول تشغيل
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       NotificationsManager.scheduleAll(ref);
//     });
//   }

//   @override
//   void dispose() {
//     _pageCtrl.dispose();
//     for (final a in _tabAnims) { a.dispose(); }
//     super.dispose();
//   }

//   void _switchTab(int idx) {
//     final current = ref.read(_currentTabProvider);
//     if (current == idx) return;

//     HapticFeedback.selectionClick();

//     // Animate out current, animate in new
//     _tabAnims[current].reverse();
//     _tabAnims[idx].forward();

//     ref.read(_currentTabProvider.notifier).state = idx;
//     _pageCtrl.animateToPage(idx,
//         duration: const Duration(milliseconds: 350),
//         curve: Curves.easeInOutCubic);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final onboardAsync = ref.watch(_onboardingDoneProvider);

//     return onboardAsync.when(
//       loading: () => const _SplashScreen(),
//       error: (_, __) => const _SplashScreen(),
//       data: (done) {
//         if (!done) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Navigator.pushReplacementNamed(context, '/onboarding');
//           });
//           return const _SplashScreen();
//         }
//         return _buildShell();
//       },
//     );
//   }

//   Widget _buildShell() {
//     final currentIdx = ref.watch(_currentTabProvider);

//     return Scaffold(
//       backgroundColor: AppColors.night,
//       body: PageView(
//         controller: _pageCtrl,
//         physics: const NeverScrollableScrollPhysics(), // manual nav only
//         children: const [
//           HomeScreen(),
//           ChecklistScreen(),
//           StatisticsScreen(),
//           SettingsScreen(),
//         ],
//         onPageChanged: (idx) {
//           ref.read(_currentTabProvider.notifier).state = idx;
//         },
//       ),
//       bottomNavigationBar: _BottomNav(
//         currentIndex: currentIdx,
//         tabs: _tabs,
//         onTap: _switchTab,
//         tabAnims: _tabAnims,
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────
// //  CUSTOM BOTTOM NAV
// // ─────────────────────────────────────────
// class _BottomNav extends StatelessWidget {
//   final int currentIndex;
//   final List<_TabInfo> tabs;
//   final void Function(int) onTap;
//   final List<AnimationController> tabAnims;

//   const _BottomNav({
//     required this.currentIndex,
//     required this.tabs,
//     required this.onTap,
//     required this.tabAnims,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 20,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             children: List.generate(tabs.length, (i) {
//               final tab = tabs[i];
//               final isActive = currentIndex == i;
//               return Expanded(
//                 child: GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   onTap: () => onTap(i),
//                   child: AnimatedBuilder(
//                     animation: tabAnims[i],
//                     builder: (_, __) {
//                       final t = tabAnims[i].value;
//                       return Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Active indicator
//                           AnimatedContainer(
//                             duration: const Duration(milliseconds: 250),
//                             width: isActive ? 28 : 0,
//                             height: 2,
//                             margin: const EdgeInsets.only(bottom: 4),
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                   colors: [AppColors.gold, AppColors.teal]),
//                               borderRadius: BorderRadius.circular(1),
//                             ),
//                           ),

//                           // Icon with scale bounce
//                           Transform.scale(
//                             scale: isActive ? 1.0 + 0.1 * t : 1.0,
//                             child: Text(
//                               tab.emoji,
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 shadows: isActive ? [
//                                   Shadow(
//                                     color: AppColors.gold.withOpacity(0.5 * t),
//                                     blurRadius: 10,
//                                   ),
//                                 ] : null,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 2),

//                           // Label
//                           AnimatedDefaultTextStyle(
//                             duration: const Duration(milliseconds: 200),
//                             style: GoogleFonts.notoNaskhArabic(
//                               fontSize: 10,
//                               color: isActive ? AppColors.gold : AppColors.textDim,
//                               fontWeight: isActive
//                                   ? FontWeight.w600
//                                   : FontWeight.w400,
//                             ),
//                             child: Text(tab.label),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────
// //  SPLASH SCREEN
// // ─────────────────────────────────────────
// class _SplashScreen extends StatefulWidget {
//   const _SplashScreen();

//   @override
//   State<_SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<_SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _fade;
//   late final Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 800));
//     _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
//     _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
//         CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
//     _ctrl.forward();
//   }

//   @override
//   void dispose() { _ctrl.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.night,
//       body: Center(
//         child: FadeTransition(
//           opacity: _fade,
//           child: ScaleTransition(
//             scale: _scale,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Logo ring
//                 SizedBox(
//                   width: 100, height: 100,
//                   child: Stack(alignment: Alignment.center, children: [
//                     ...List.generate(3, (i) => Container(
//                       width: 100 - i * 20.0,
//                       height: 100 - i * 20.0,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: AppColors.gold.withOpacity(0.3 - i * 0.08),
//                           width: 1,
//                         ),
//                       ),
//                     )),
//                     const Text('🌙', style: TextStyle(fontSize: 32)),
//                   ]),
//                 ),
//                 const SizedBox(height: 24),
//                 Text('محاسبة النفس',
//                     style: GoogleFonts.amiri(
//                         fontSize: 32, color: AppColors.gold,
//                         fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 8),
//                 Text('"حَاسِبُوا أَنفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا"',
//                     style: GoogleFonts.amiri(
//                         fontSize: 14, color: AppColors.textSecondary),
//                     textAlign: TextAlign.center),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  ONBOARDING  (lib/features/onboarding/onboarding_screen.dart)
// // ═══════════════════════════════════════════════════════════════
// class OnboardingScreen extends ConsumerStatefulWidget {
//   const OnboardingScreen({super.key});
//   @override
//   ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
//     with TickerProviderStateMixin {
//   final _pageCtrl = PageController();
//   int _page = 0;
//   late final AnimationController _bgCtrl;

//   static const _pages = [
//     _OnboardPage(
//       emoji: '🌙',
//       title: 'مرحباً بك',
//       subtitle: '"حَاسِبُوا أَنفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا"\n— عمر بن الخطاب رضي الله عنه',
//       features: [],
//     ),
//     _OnboardPage(
//       emoji: '✅',
//       title: 'تتبع عباداتك',
//       subtitle: 'سجّل صلواتك وأذكارك وقراءة القرآن يومياً',
//       features: [
//         ('🕌', 'الصلوات الخمس'),
//         ('📖', 'تلاوة القرآن'),
//         ('⭐', 'الأذكار والأدعية'),
//       ],
//     ),
//     _OnboardPage(
//       emoji: '📊',
//       title: 'حاسب نفسك',
//       subtitle: 'إحصائيات أسبوعية وشهرية لمعرفة تقدمك',
//       features: [
//         ('🌟', 'نقاط التقوى'),
//         ('🔥', 'سلسلة الأيام المتواصلة'),
//         ('🏆', 'إنجازات وشارات'),
//       ],
//     ),
//     _OnboardPage(
//       emoji: '🔔',
//       title: 'لا تنسَ',
//       subtitle: 'تذكيرات ذكية بأوقات الصلاة والأذكار والمحاسبة',
//       features: [
//         ('📍', 'أوقات الصلاة حسب موقعك'),
//         ('🌅', 'تنبيه قبل الفجر'),
//         ('📝', 'تذكير مسائي للمحاسبة'),
//       ],
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _bgCtrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 600));
//     _bgCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _pageCtrl.dispose();
//     _bgCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _finish() async {
//     // طلب الإذن
//     await NotificationsService.requestPermissions();
//     await ref.read(settingsDaoProvider).set('onboardingDone', 'true');
//     await NotificationsManager.scheduleAll(ref);

//     if (mounted) {
//       Navigator.pushReplacementNamed(context, '/');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLast = _page == _pages.length - 1;

//     return Scaffold(
//       backgroundColor: AppColors.night,
//       body: Stack(children: [
//         // Animated background glow
//         AnimatedPositioned(
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOut,
//           top: -100,
//           left: (_page / (_pages.length - 1)) *
//               (MediaQuery.of(context).size.width - 200) - 50,
//           child: Container(
//             width: 300, height: 300,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: RadialGradient(colors: [
//                 AppColors.gold.withOpacity(0.1), Colors.transparent]),
//             ),
//           ),
//         ),

//         SafeArea(
//           child: Column(children: [
//             // Skip button
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: !isLast ? TextButton(
//                   onPressed: _finish,
//                   child: Text('تخطي',
//                       style: GoogleFonts.notoNaskhArabic(
//                           fontSize: 13, color: AppColors.textDim)),
//                 ) : const SizedBox(),
//               ),
//             ),

//             // Pages
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageCtrl,
//                 onPageChanged: (i) {
//                   setState(() => _page = i);
//                   _bgCtrl..reset()..forward();
//                 },
//                 itemCount: _pages.length,
//                 itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
//               ),
//             ),

//             // Dots
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(_pages.length, (i) {
//                 final isActive = i == _page;
//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 250),
//                   width: isActive ? 24 : 7,
//                   height: 7,
//                   margin: const EdgeInsets.symmetric(horizontal: 3),
//                   decoration: BoxDecoration(
//                     gradient: isActive ? const LinearGradient(
//                         colors: [AppColors.gold, AppColors.teal]) : null,
//                     color: isActive ? null : AppColors.border,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 );
//               }),
//             ),
//             const SizedBox(height: 28),

//             // Button
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isLast
//                       ? _finish
//                       : () => _pageCtrl.nextPage(
//                           duration: const Duration(milliseconds: 400),
//                           curve: Curves.easeInOut),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.gold,
//                     foregroundColor: AppColors.night,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     elevation: 0,
//                     shadowColor: AppColors.gold.withOpacity(0.4),
//                   ),
//                   child: Text(
//                     isLast ? 'ابدأ رحلة المحاسبة 🤲' : 'التالي ←',
//                     style: GoogleFonts.notoNaskhArabic(
//                         fontSize: 15, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// class _OnboardPageView extends StatelessWidget {
//   final _OnboardPage page;
//   const _OnboardPageView({required this.page});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 28),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Emoji with rings
//           SizedBox(
//             width: 120, height: 120,
//             child: Stack(alignment: Alignment.center, children: [
//               ...List.generate(3, (i) => Container(
//                 width: 120 - i * 22.0, height: 120 - i * 22.0,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: AppColors.gold.withOpacity(0.25 - i * 0.06),
//                     width: 1,
//                   ),
//                 ),
//               )),
//               Container(
//                 width: 72, height: 72,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(colors: [
//                     AppColors.gold.withOpacity(0.15), Colors.transparent]),
//                 ),
//                 child: Center(child: Text(page.emoji,
//                     style: const TextStyle(fontSize: 32))),
//               ),
//             ]),
//           ),
//           const SizedBox(height: 28),

//           Text(page.title,
//               style: GoogleFonts.amiri(
//                   fontSize: 28, color: AppColors.gold,
//                   fontWeight: FontWeight.w700),
//               textAlign: TextAlign.center),
//           const SizedBox(height: 12),
//           Text(page.subtitle,
//               style: GoogleFonts.notoNaskhArabic(
//                   fontSize: 14, color: AppColors.textSecondary, height: 1.9),
//               textAlign: TextAlign.center),
//           const SizedBox(height: 24),

//           if (page.features.isNotEmpty) ...[
//             ...page.features.map((f) => Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.card,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: Row(children: [
//                   Text(f.$1, style: const TextStyle(fontSize: 18)),
//                   const SizedBox(width: 10),
//                   Text(f.$2,
//                       style: GoogleFonts.notoNaskhArabic(
//                           fontSize: 13, color: AppColors.textPrimary)),
//                   const Spacer(),
//                   const Icon(Icons.check_circle_rounded,
//                       color: AppColors.success, size: 16),
//                 ]),
//               ),
//             )),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────
// //  DATA CLASSES
// // ─────────────────────────────────────────
// class _TabInfo {
//   final String emoji, label;
//   final int index;
//   const _TabInfo(this.emoji, this.label, this.index);
// }

// class _OnboardPage {
//   final String emoji, title, subtitle;
//   final List<(String, String)> features;
//   const _OnboardPage({
//     required this.emoji, required this.title,
//     required this.subtitle, required this.features,
//   });
// }
