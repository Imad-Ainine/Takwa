// ═══════════════════════════════════════════════════════════════
//  lib/app/animated_drawer.dart
//  محاسبة النفس — Animated Drawer
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';

import '../core/theme/app_theme.dart';
import '../core/providers/database_providers.dart';
import '../core/database/daos.dart';

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
      backgroundColor: const Color(0xFF060A10),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0F1A), Color(0xFF111827)],
        ),
      ),
      child: Stack(
        children: [
          // نمط خلفية
          Positioned.fill(child: CustomPaint(painter: _DrawerBgPainter())),

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
                Container(height: 1, color: AppColors.border),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo + name
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withOpacity(0.2),
                      AppColors.gold.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'محاسبة النفس',
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    isRamadan ? '🌙 رمضان كريم' : 'رفيقك اليومي',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // التاريخ الهجري
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  '${hijri.hDay} ${_hijriMonth(hijri.hMonth)} ${hijri.hYear}',
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: AppColors.goldLight,
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
                    color: AppColors.gold,
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
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
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
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 9,
                color: AppColors.textSecondary,
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
    _NavItem('⚙️', 'الإعدادات', '/settings', 5),
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
                  ? const LinearGradient(
                      colors: [Color(0x22C8A96E), Color(0x113AAFA9)],
                    )
                  : null,
              color: widget.isActive ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isActive
                    ? AppColors.gold.withOpacity(0.25)
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
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.gold, AppColors.teal],
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
                              color: AppColors.gold.withOpacity(0.5),
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
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 14,
                      color: widget.isActive
                          ? AppColors.gold
                          : AppColors.textPrimary.withOpacity(0.75),
                      fontWeight: widget.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),

                if (widget.isActive)
                  const Icon(Icons.circle, size: 6, color: AppColors.gold),
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
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '❁',
                style: TextStyle(color: AppColors.gold, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"حَاسِبُوا أَنفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا"',
                  style: GoogleFonts.amiri(
                    fontSize: 11,
                    color: AppColors.textDim,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '❁',
                style: TextStyle(color: AppColors.gold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'محاسبة النفس v1.0',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 10,
              color: AppColors.textDim,
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
          color: isOpen ? AppColors.goldDim : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOpen
                ? AppColors.gold.withOpacity(0.3)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isOpen
                ? const Icon(
                    Icons.close_rounded,
                    key: ValueKey('close'),
                    size: 18,
                    color: AppColors.gold,
                  )
                : const _HamburgerIcon(
                    key: ValueKey('menu'),
                    color: AppColors.textPrimary,
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
