// ═══════════════════════════════════════════════════════════════
//  lib/app/main_shell.dart — Shell with BottomNavigationBar
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/providers/database_providers.dart';
import '../core/notifications/notifications_service.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/checklist/checklist_screen.dart';
import '../features/statistics/statistics_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/asma/presentation/screens/asma_screen.dart';
import '../features/qiyam/presentation/screens/qiyam_dashboard_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../app/animated_drawer.dart';
import '../core/providers/auth_providers.dart';
import '../features/auth/presentation/pages/auth_choice_screen.dart';
import '../core/widgets/custom_pattern_background.dart';
import '../core/notifications/overlay_background_service.dart';

// ─────────────────────────────────────────
//  CURRENT TAB PROVIDER
// ─────────────────────────────────────────
final currentTabProvider = StateProvider<int>((ref) => 0);

// ─────────────────────────────────────────
//  APP SHELL
// ─────────────────────────────────────────
class MainShell extends ConsumerStatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with TickerProviderStateMixin {
  late final PageController _pageCtrl;
  late List<AnimationController> _tabAnims;

  static const _tabs = [
    _TabInfo('🏠', 'الرئيسية', 0),
    _TabInfo('🌙', 'قيام', 1),
    _TabInfo('✅', 'المحاسبة', 2),
    _TabInfo('📊', 'إحصائيات', 3),
    _TabInfo('✨', 'أسماء الله', 4),
    _TabInfo('⚙️', 'الإعدادات', 5),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: widget.initialIndex);

    _tabAnims = List.generate(
      _tabs.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    // تفعيل التبويب الأول
    _tabAnims[widget.initialIndex].forward();

    // جدولة الإشعارات عند أول تشغيل (بعد استكمال التهيئة فقط)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final done = await ref.read(onboardingDoneProvider.future);
      if (done) {
        _initializePostOnboardingServices();
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final a in _tabAnims) {
      a.dispose();
    }
    super.dispose();
  }

  void _switchTab(int idx, {bool updateProvider = true}) {
    final current = ref.read(currentTabProvider);
    // Use closer comparison for double values check from PageController if needed,
    // but round() is usually fine for discrete tab indexes.
    if (current == idx &&
        _pageCtrl.hasClients &&
        _pageCtrl.page?.round() == idx) {
      return;
    }

    HapticFeedback.selectionClick();

    // Animate out current, animate in new
    if (current != idx) {
      _tabAnims[current].reverse();
      _tabAnims[idx].forward();
    }

    if (updateProvider) {
      ref.read(currentTabProvider.notifier).state = idx;
    }

    if (_pageCtrl.hasClients && _pageCtrl.page?.round() != idx) {
      _pageCtrl.animateToPage(
        idx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _initializePostOnboardingServices() {
    ref.read(notificationsManagerProvider).scheduleAll();
    OverlayBackgroundService.start();
  }

  @override
  Widget build(BuildContext context) {
    // تشغيل الخدمات فور اكتمال التهيئة
    ref.listen(onboardingDoneProvider, (prev, next) {
      if (next.value == true && prev?.value != true) {
        _initializePostOnboardingServices();
      }
    });

    // Listen for external tab changes (e.g. from Home screen)
    ref.listen(currentTabProvider, (prev, next) {
      if (_pageCtrl.hasClients && _pageCtrl.page?.round() != next) {
        _switchTab(next, updateProvider: false);
      }
    });

    // Avoid rebuilding unnecessarily on each new frame
    final onboardAsync = ref.watch(onboardingDoneProvider);

    return onboardAsync.when(
      loading: () => const _SplashScreen(),
      error: (_, _) => const _SplashScreen(),
      data: (done) {
        if (!done) {
          return const OnboardingScreen();
        }

        // Check Auth Status
        final authStatus = ref.watch(authStatusProvider);
        if (authStatus == AuthStatus.unauthenticated) {
          return const AuthChoiceScreen();
        }

        return _buildShell();
      },
    );
  }

  Widget _buildShell() {
    // Robustness check: If tabs were added/removed during hot reload, re-initialize controllers
    if (_tabAnims.length != _tabs.length) {
      for (final a in _tabAnims) {
        a.dispose();
      }
      _tabAnims = List.generate(
        _tabs.length,
        (i) => AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        ),
      );
      // Ensure current index is still valid
      final currentIdx = ref.read(currentTabProvider);
      if (currentIdx >= _tabs.length) {
        ref.read(currentTabProvider.notifier).state = 0;
      }
      _tabAnims[ref.read(currentTabProvider)].forward();
    }

    final currentIdx = ref.watch(currentTabProvider);

    return DrawerScaffold(
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(), // manual nav only
          children: const [
            HomeScreen(),
            QiyamDashboardScreen(),
            ChecklistScreen(),
            StatisticsScreen(),
            AsmaScreen(),
            SettingsScreen(),
          ],
          onPageChanged: (idx) {
            // If swiped
            if (ref.read(currentTabProvider) != idx) {
              _tabAnims[ref.read(currentTabProvider)].reverse();
              _tabAnims[idx].forward();
              ref.read(currentTabProvider.notifier).state = idx;
            }
          },
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: currentIdx,
          tabs: _tabs,
          onTap: _switchTab,
          tabAnims: _tabAnims,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  CUSTOM BOTTOM NAV
// ─────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_TabInfo> tabs;
  final void Function(int) onTap;
  final List<AnimationController> tabAnims;

  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
    required this.tabAnims,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: context.colors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle pattern background for BottomNav
          const Positioned.fill(
            child: ClipRect(
              child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final tab = tabs[i];
                  final isActive = currentIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: AnimatedBuilder(
                        animation: tabAnims[i],
                        builder: (_, _) {
                          final t = tabAnims[i].value;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Improved Active indicator with glow
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: isActive ? 24 : 0,
                                height: 3,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.colors.gold,
                                      context.colors.teal,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1.5),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: context.colors.gold
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),

                              // Icon with scale bounce
                              Transform.scale(
                                scale: isActive ? 1.0 + 0.15 * t : 1.0,
                                child: Text(
                                  tab.emoji,
                                  style: TextStyle(
                                    fontSize: 22,
                                    shadows: isActive
                                        ? [
                                            Shadow(
                                              color: context.colors.gold
                                                  .withOpacity(0.6 * t),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),

                              // Label
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: context.typography.caption.copyWith(
                                  fontSize: 10,
                                  color: isActive
                                      ? context.colors.gold
                                      : context.colors.textDim,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  letterSpacing: isActive ? 0.2 : 0,
                                ),
                                child: Text(tab.label),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SPLASH SCREEN
// ─────────────────────────────────────────
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo ring
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ...List.generate(
                        3,
                        (i) => Container(
                          width: 100 - i * 20.0,
                          height: 100 - i * 20.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.gold.withOpacity(
                                0.3 - i * 0.08,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const Text('🌙', style: TextStyle(fontSize: 32)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'تقوى',
                  style: context.typography.displayMedium.copyWith(
                    fontSize: 32,
                    color: context.colors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"حَاسِبُوا أَنفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا"',
                  style: context.typography.quranicVerse.copyWith(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  DATA CLASSES
// ─────────────────────────────────────────
class _TabInfo {
  final String emoji, label;
  final int index;
  const _TabInfo(this.emoji, this.label, this.index);
}
