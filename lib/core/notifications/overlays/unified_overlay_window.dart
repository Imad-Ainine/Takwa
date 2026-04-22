// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/overlays/unified_overlay_window.dart
//  تقوى — نافذة Overlay موحّدة (أذكار + أدعية)
//  • تظهر من يمين الشاشة، منتصف الارتفاع
//  • تعرض ذكرًا أو دعاءً عشوائياً من جميع القوائم
//  • تعمل حتى لو التطبيق مغلق (isolate مستقل)
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../../providers/adhkar_providers.dart';
import 'package:takwa/features/duas/data/duas_data.dart';

// ─────────────────────────────────────────
//  نموذج بيانات موحّد للعرض
// ─────────────────────────────────────────
class _PopupItem {
  final String arabic;
  final String? meaning;
  final String? fadl;
  final String? source;
  final String emoji;
  final String categoryName;
  final bool isDua; // لتمييز الخلفية

  const _PopupItem({
    required this.arabic,
    required this.emoji,
    required this.categoryName,
    required this.isDua,
    this.meaning,
    this.fadl,
    this.source,
  });
}

// ─────────────────────────────────────────
//  بناء قائمة موحّدة من كل الأذكار والأدعية
// ─────────────────────────────────────────
List<_PopupItem> _buildAllItems() {
  final items = <_PopupItem>[];

  // ── الأذكار ──
  final catNames = {
    AdhkarCategory.morning: ('🌅', 'أذكار الصباح'),
    AdhkarCategory.evening: ('🌆', 'أذكار المساء'),
    AdhkarCategory.afterPrayer: ('🕌', 'أذكار بعد الصلاة'),
    AdhkarCategory.sleep: ('🌙', 'أذكار النوم'),
    AdhkarCategory.misc: ('📿', 'أذكار متنوعة'),
  };
  for (final entry in kAdhkarData.entries) {
    final meta = catNames[entry.key]!;
    for (final d in entry.value) {
      items.add(
        _PopupItem(
          arabic: d.arabic,
          fadl: d.fadl,
          source: d.source,
          emoji: meta.$1,
          categoryName: meta.$2,
          isDua: false,
        ),
      );
    }
  }

  // ── الأدعية ──
  const duaCatNames = {
    DuaCategory.morning: ('🌅', 'دعاء الصباح'),
    DuaCategory.distress: ('🌊', 'دعاء الكرب'),
    DuaCategory.guidance: ('🌟', 'دعاء الهداية'),
    DuaCategory.forgiveness: ('🌿', 'دعاء المغفرة'),
    DuaCategory.rizq: ('🌾', 'دعاء الرزق'),
    DuaCategory.health: ('🫀', 'دعاء الصحة'),
    DuaCategory.parents: ('❤️', 'دعاء الوالدين'),
    DuaCategory.travel: ('✈️', 'دعاء السفر'),
    DuaCategory.rain: ('🌧️', 'دعاء الاستسقاء'),
    DuaCategory.general: ('🤲', 'دعاء عام'),
  };
  for (final entry in kDuasData.entries) {
    final meta = duaCatNames[entry.key];
    if (meta == null) continue;
    for (final d in entry.value) {
      items.add(
        _PopupItem(
          arabic: d.arabic,
          meaning: d.meaning,
          source: d.source,
          emoji: d.emoji,
          categoryName: meta.$2,
          isDua: true,
        ),
      );
    }
  }

  return items;
}

// ─── Colors (Static because of isolate) ───
const _gold = Color(0xFFD4AF37);
const _goldDark = Color(0xFFA07838);
const _cardBg = Color(0xFFFFFFFF); // Premium Light Theme
const _textMain = Color(0xFF1A1A1A); // Dark text for readability
const _textSec = Color(0xFF666666);

class UnifiedOverlayWindow extends StatefulWidget {
  const UnifiedOverlayWindow({super.key});

  @override
  State<UnifiedOverlayWindow> createState() => _UnifiedOverlayWindowState();
}

class _UnifiedOverlayWindowState extends State<UnifiedOverlayWindow>
    with TickerProviderStateMixin {
  final _allItems = _buildAllItems();
  final _random = math.Random();
  _PopupItem? _current;
  Timer? _autoRefreshTimer;
  String? _filter; // 'adhkar' or 'dua'

  // Animation
  late final AnimationController _slideCtrl;
  late final AnimationController _starsCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // ── Slide-in Animation ──
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideCtrl, curve: const Interval(0.0, 0.6)),
    );

    // ── Background Stars Animation ──
    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _pickRandom();
    _slideCtrl.forward();

    // Refresh every 15 minutes if overlay stays open
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _pickRandom(animate: true);
    });

    // Auto-close after 15 seconds
    Timer(const Duration(seconds: 15), () {
      if (mounted) FlutterOverlayWindow.closeOverlay();
    });

    // Listen to data from main isolate
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map) {
        if (data.containsKey('type')) {
          setState(() {
            _filter = data['type'];
            _pickRandom(animate: true);
          });
        }
      } else if (data is int && data >= 0 && data < _allItems.length) {
        setState(() {
          _current = _allItems[data];
          _slideCtrl.forward(from: 0);
        });
      } else {
        _pickRandom(animate: true);
      }
    });
  }

  void _pickRandom({bool animate = false}) {
    if (_allItems.isEmpty) return;

    List<_PopupItem> pool = _allItems;
    if (_filter == 'adhkar') {
      pool = _allItems.where((i) => !i.isDua).toList();
    } else if (_filter == 'dua') {
      pool = _allItems.where((i) => i.isDua).toList();
    }

    if (pool.isEmpty) pool = _allItems;

    final next = pool[_random.nextInt(pool.length)];
    if (animate) {
      _slideCtrl.reverse().then((_) {
        if (mounted) {
          setState(() => _current = next);
          _slideCtrl.forward();
        }
      });
    } else {
      setState(() => _current = next);
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _slideCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => FlutterOverlayWindow.closeOverlay(),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              // ── Background Stars ──
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _starsCtrl,
                  builder: (_, _) => CustomPaint(
                    painter: _OverlayStarsPainter(progress: _starsCtrl.value),
                  ),
                ),
              ),

              // ── Card Alignment ──
              Align(
                alignment: Alignment.topCenter,
                child: SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 50, // Padding for status bar
                      ),
                      child: GestureDetector(
                        onTap:
                            () {}, // Prevent closing when tapping the card itself
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: _buildCard(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final item = _current!;
    final accentColor = item.isDua ? const Color(0xFF2DD4BF) : _gold;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _gold.withOpacity(0.5),
          width: 2,
        ), // Slightly thicker gold border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Background Geometric Pattern ──
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _OverlayPatternPainter(color: _gold)),
            ),
          ),
          // ── Mosque Silhouette ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _OverlayMosquePainter(
                color: accentColor.withOpacity(0.08),
              ),
              size: const Size(double.infinity, 80),
            ),
          ),

          // ── Main Content ──
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Gradient Bar ──
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.isDua
                        ? [const Color(0xFF2DD4BF), const Color(0xFF14B8A6)]
                        : [_goldDark, _gold, const Color(0xFFFDE68A)],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ──
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.categoryName,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 18,
                                  color: accentColor,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              const Text(
                                'تطبيق تقوى ✨',
                                style: TextStyle(fontSize: 11, color: _textSec),
                              ),
                            ],
                          ),
                        ),
                        // Close
                        GestureDetector(
                          onTap: () => FlutterOverlayWindow.closeOverlay(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.04),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: _textSec,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Arabic Text ──
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          item.arabic,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            color: _textMain,
                            height: 1.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // ── Fadl / Meaning ──
                    if (item.fadl != null || item.meaning != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _gold.withOpacity(0.1)),
                        ),
                        child: Text(
                          item.fadl ?? item.meaning ?? '',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            color: accentColor.withOpacity(0.85),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Actions ──
                    Row(
                      children: [
                        _ActionIcon(
                          icon: Icons.copy_rounded,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: item.arabic));
                            HapticFeedback.mediumImpact();
                          },
                        ),
                        const SizedBox(width: 8),
                        const Spacer(),
                        // Next Button
                        GestureDetector(
                          onTap: () => _pickRandom(animate: true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: item.isDua
                                    ? [
                                        const Color(0xFF2DD4BF),
                                        const Color(0xFF14B8A6),
                                      ]
                                    : [_gold, _goldDark],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: Color(0xFF02061A),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.isDua ? 'دعاء آخر' : 'ذكر آخر',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF02061A),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Icon(icon, size: 20, color: _textMain),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  PAINTERS
// ─────────────────────────────────────────

class _OverlayStarsPainter extends CustomPainter {
  final double progress;
  _OverlayStarsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint();

    for (int i = 0; i < 70; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final twinkle = math.sin((progress * math.pi * 2) + i * 0.7);
      final opacity = (0.1 + 0.5 * ((twinkle + 1) / 2)).clamp(0.0, 1.0);
      final radius = 0.5 + rng.nextDouble() * 1.5;

      paint.color = Colors.white.withOpacity(opacity * 0.4);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OverlayStarsPainter old) => old.progress != progress;
}

class _OverlayMosquePainter extends CustomPainter {
  final Color color;
  _OverlayMosquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final path = Path();

    path.moveTo(0, h);
    path.lineTo(w, h);

    // Right minaret
    path.lineTo(w * 0.92, h);
    path.lineTo(w * 0.92, h * 0.4);
    path.lineTo(w * 0.89, h * 0.2);
    path.lineTo(w * 0.86, h * 0.4);
    path.lineTo(w * 0.86, h);

    // Left minaret
    path.lineTo(w * 0.14, h);
    path.lineTo(w * 0.14, h * 0.4);
    path.lineTo(w * 0.11, h * 0.2);
    path.lineTo(w * 0.08, h * 0.4);
    path.lineTo(w * 0.08, h);

    // Dome
    path.moveTo(w * 0.7, h);
    path.quadraticBezierTo(w * 0.5, h * -0.1, w * 0.3, h);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OverlayMosquePainter old) => false;
}

class _OverlayPatternPainter extends CustomPainter {
  final Color color;
  _OverlayPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OverlayPatternPainter old) => false;
}
