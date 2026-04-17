// ═══════════════════════════════════════════════════════════════
//  lib/app/animated_drawer.dart
//   — Animated Drawer تقوى
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hijri/hijri_calendar.dart';

import '../core/theme/app_theme.dart';
import '../core/providers/database_providers.dart';
import '../core/database/daos.dart';
import '../core/supabase/sync_manager.dart';
import '../core/supabase/supabase_providers.dart';
import '../core/widgets/custom_pattern_background.dart';
import '../core/routes/app_routes.dart';

// ─────────────────────────────────────────
//  DRAWER STATE PROVIDER
// ─────────────────────────────────────────
final drawerOpenProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────
//  DRAWER SCAFFOLD WRAPPER
//  يُغلّف الـ AppShell بالكامل
// ─────────────────────────────────────────
class DrawerScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const DrawerScaffold({super.key, required this.child});

  @override
  ConsumerState<DrawerScaffold> createState() => _DrawerScaffoldState();
}

class _DrawerScaffoldState extends ConsumerState<DrawerScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _rotate;
  late final Animation<BorderRadius?> _radius;

  static const _drawerWidth = 280.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _slide = Tween<double>(
      begin: 0,
      end: _drawerWidth,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fade = Tween<double>(
      begin: 0.0,
      end: 0.65,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _rotate = Tween<double>(
      begin: 0.0,
      end: -0.05,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _radius = BorderRadiusTween(
      begin: BorderRadius.zero,
      end: BorderRadius.circular(28),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open() {
    HapticFeedback.mediumImpact();
    ref.read(drawerOpenProvider.notifier).state = true;
    _ctrl.forward();
    SyncManager.fullSync(ref); // Trigger sync when opening
  }

  void _close() {
    HapticFeedback.lightImpact();
    ref.read(drawerOpenProvider.notifier).state = false;
    _ctrl.reverse();
  }

  void _toggle() {
    if (_ctrl.isAnimating) return;
    ref.read(drawerOpenProvider) ? _close() : _open();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // ── الـ Drawer (خلف الشاشة) ──
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: _drawerWidth,
            child: _DrawerContent(onClose: _close),
          ),

          // ── الشاشة الرئيسية (فوق الـ Drawer) ──
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Transform(
              transform: Matrix4.identity()
                ..translate(_slide.value, 0.0)
                ..scale(_scale.value)
                ..rotateZ(_rotate.value),
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: _radius.value ?? BorderRadius.zero,
                child: child,
              ),
            ),
            child: Stack(
              children: [
                widget.child,

                // overlay عند فتح الـ Drawer
                AnimatedBuilder(
                  animation: _fade,
                  builder: (_, __) => _fade.value > 0
                      ? GestureDetector(
                          onTap: _close,
                          child: Container(
                            color: Colors.black.withOpacity(_fade.value),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // expose toggle للخارج
  static _DrawerScaffoldState of(BuildContext context) =>
      context.findAncestorStateOfType<_DrawerScaffoldState>()!;
}

// ─────────────────────────────────────────
//  DRAWER CONTENT
// ─────────────────────────────────────────
class _DrawerContent extends ConsumerWidget {
  final VoidCallback onClose;
  const _DrawerContent({required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(monthStatsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final hijri = HijriCalendar.now();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.deep, context.colors.deep],
        ),
      ),
      child: Stack(
        children: [
          // نمط خلفية عصري
          const Positioned.fill(
            child: CustomPatternBackground(
              pattern: BackgroundPattern.geometric,
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── رأس الـ Drawer ──
                _DrawerHeader(
                  hijri: hijri,
                  statsAsync: statsAsync,
                  streakAsync: streakAsync,
                ),

                const SizedBox(height: 8),
                Container(height: 1, color: context.colors.border),
                const SizedBox(height: 8),

                // ── قائمة التنقل ──
                Expanded(child: _DrawerNav(onClose: onClose)),

                // ── تذييل ──
                _DrawerFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── رأس الـ Drawer ──
class _DrawerHeader extends ConsumerWidget {
  final HijriCalendar hijri;
  final AsyncValue<MonthStats> statsAsync;
  final AsyncValue<int> streakAsync;

  const _DrawerHeader({
    required this.hijri,
    required this.statsAsync,
    required this.streakAsync,
  });

  static String _hijriMonth(int m) => const [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ][m - 1];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRamadan = hijri.hMonth == 9;
    final profileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile section in header
          profileAsync.when(
            data: (profile) {
              final username = profile?['username'] ?? 'مستخدم تقوى';
              final avatar = profile?['avatar_emoji'] ?? '🌙';
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.pushNamed(context, Routes.profile);
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.goldDim,
                        border: Border.all(
                          color: context.colors.gold.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.gold.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            username,
                            style: context.typography.headingLarge.copyWith(
                              fontSize: 18,
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'عرض البروفايل',
                                style: context.typography.caption.copyWith(
                                  fontSize: 11,
                                  color: context.colors.gold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 8,
                                color: context.colors.gold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 52),
            error: (_, __) => const SizedBox(height: 52),
          ),

          const SizedBox(height: 20),

          // التاريخ الهجري
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.goldDim,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colors.gold.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  '${hijri.hDay} ${_hijriMonth(hijri.hMonth)} ${hijri.hYear}',
                  style: context.typography.headingMedium.copyWith(
                    fontSize: 14,
                    color: context.colors.goldLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Stats row
          Row(
            children: [
              Expanded(
                child: statsAsync.when(
                  loading: () => const SizedBox(height: 48),
                  error: (_, __) => const SizedBox(),
                  data: (s) => _MiniStatCard(
                    value: '${s.totalPoints}',
                    label: 'نقطة التقوى',
                    icon: '🌟',
                    color: context.colors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: streakAsync.when(
                  loading: () => const SizedBox(height: 48),
                  error: (_, __) => const SizedBox(),
                  data: (s) => _MiniStatCard(
                    value: '$s',
                    label: 'يوم متواصل',
                    icon: '🔥',
                    color: context.colors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Level & Progress
          statsAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (s) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المستوى: ${s.levelLabel}',
                      style: context.typography.caption.copyWith(
                        color: context.colors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${s.totalPoints} / 600',
                      style: context.typography.caption.copyWith(
                        fontSize: 9,
                        color: context.colors.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (s.totalPoints / 600).clamp(0, 1),
                    backgroundColor: context.colors.gold.withOpacity(0.1),
                    color: context.colors.gold,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String value, label, icon;
  final Color color;
  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.18)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: context.typography.bodyLarge.copyWith(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: context.typography.caption.copyWith(
                fontSize: 9,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── قائمة التنقل ──
class _DrawerNav extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  const _DrawerNav({required this.onClose});

  @override
  ConsumerState<_DrawerNav> createState() => _DrawerNavState();
}

class _DrawerNavState extends ConsumerState<_DrawerNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final List<Animation<double>> _itemAnims;

  static const _items = [
    _NavItem('🏠', 'الرئيسية', '/home', 0),
    _NavItem('✅', 'محاسبة اليوم', '/checklist', 1),
    _NavItem('🕌', 'أوقات الصلاة', '/prayer', 2),
    _NavItem('📊', 'الإحصائيات', '/statistics', 3),
    _NavItem('🏆', 'الإنجازات', '/achievements', 4),
    _NavItem('👤', 'الملف الشخصي', '/profile', 5),
    _NavItem('⚙️', 'الإعدادات', '/settings', 6),
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _itemAnims = List.generate(_items.length, (i) {
      final s = i * 0.1, e = (s + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final item = _items[i];
        return FadeTransition(
          opacity: _itemAnims[i],
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(-0.2, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _staggerCtrl,
                    curve: Interval(
                      i * 0.1,
                      (i * 0.1 + 0.4).clamp(0, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
            child: _NavRow(
              item: item,
              isActive: currentRoute == item.route,
              onTap: () {
                widget.onClose();
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pushNamed(context, item.route);
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class _NavRow extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  const _NavRow({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<_NavRow> with SingleTickerProviderStateMixin {
  late final AnimationController _hover;

  @override
  void initState() {
    super.initState();
    _hover = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _hover.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _hover.reverse();
        widget.onTap();
      },
      onTapCancel: () => _hover.reverse(),
      child: AnimatedBuilder(
        animation: _hover,
        builder: (_, __) => Transform.scale(
          scale: 1.0 - 0.02 * _hover.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              gradient: widget.isActive
                  ? LinearGradient(
                      colors: [
                        context.colors.gold.withOpacity(0.15),
                        context.colors.teal.withOpacity(0.08),
                      ],
                    )
                  : null,
              color: widget.isActive ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isActive
                    ? context.colors.gold.withOpacity(0.25)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                // Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3,
                  height: widget.isActive ? 22 : 0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [context.colors.gold, context.colors.teal],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: widget.isActive ? 8 : 0),

                Text(
                  widget.item.emoji,
                  style: TextStyle(
                    fontSize: 20,
                    shadows: widget.isActive
                        ? [
                            Shadow(
                              color: context.colors.gold.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: context.typography.bodyMedium.copyWith(
                      fontSize: 14,
                      color: widget.isActive
                          ? context.colors.gold
                          : context.colors.textPrimary.withOpacity(0.75),
                      fontWeight: widget.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),

                if (widget.isActive)
                  Icon(Icons.circle, size: 6, color: context.colors.gold),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── تذييل الـ Drawer ──
class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Container(height: 1, color: context.colors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '❁',
                style: TextStyle(color: context.colors.gold, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"حَاسِبُوا أَنفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا"',
                  style: context.typography.bodySmall.copyWith(
                    fontSize: 11,
                    color: context.colors.textDim,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '❁',
                style: TextStyle(color: context.colors.gold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ' v1.0',
            style: context.typography.caption.copyWith(
              fontSize: 10,
              color: context.colors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Menu Button (للـ AppBar) ──
class DrawerMenuButton extends ConsumerWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(drawerOpenProvider);

    return GestureDetector(
      onTap: () => _DrawerScaffoldState.of(context)._toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isOpen
              ? context.colors.goldDim
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOpen
                ? context.colors.gold.withOpacity(0.3)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isOpen
                ? Icon(
                    Icons.close_rounded,
                    key: const ValueKey('close'),
                    size: 18,
                    color: context.colors.gold,
                  )
                : _HamburgerIcon(
                    key: const ValueKey('menu'),
                    color: context.colors.textPrimary,
                  ),
          ),
        ),
      ),
    );
  }
}

// ── أيقونة الـ Hamburger المتحركة ──
class _HamburgerIcon extends StatelessWidget {
  final Color color;
  const _HamburgerIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _HLine(color: color, width: 16),
        const SizedBox(height: 4),
        _HLine(color: color, width: 11),
        const SizedBox(height: 4),
        _HLine(color: color, width: 14),
      ],
    );
  }
}

class _HLine extends StatelessWidget {
  final Color color;
  final double width;
  const _HLine({required this.color, required this.width});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 1.8,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(1),
    ),
  );
}

// ─────────────────────────────────────────
//  BACKGROUND PAINTER
// ─────────────────────────────────────────
class _DrawerBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // نقاط هندسية
    final p = Paint()..color = const Color(0x0AC8A96E);
    for (double x = 16; x < size.width; x += 24) {
      for (double y = 16; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
    // خطوط مائلة
    final lp = Paint()
      ..color = const Color(0x06C8A96E)
      ..strokeWidth = 0.5;
    for (double x = -size.height; x < size.width + size.height; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), lp);
    }
    // glow أسفل يسار
    canvas.drawCircle(
      Offset(0, size.height),
      160,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0x14C8A96E), Colors.transparent],
            ).createShader(
              Rect.fromCircle(center: Offset(0, size.height), radius: 160),
            ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ─────────────────────────────────────────
//  DATA CLASS
// ─────────────────────────────────────────
class _NavItem {
  final String emoji, label, route;
  final int index;
  const _NavItem(this.emoji, this.label, this.route, this.index);
}
