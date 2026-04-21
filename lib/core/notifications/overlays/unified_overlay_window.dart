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
import 'package:google_fonts/google_fonts.dart';

import '../../providers/adhkar_providers.dart';
import 'package:takwa/features/duas/presentation/screens/duas_screen.dart';

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

// ═══════════════════════════════════════════════════════════════
//  UNIFIED OVERLAY WINDOW WIDGET
// ═══════════════════════════════════════════════════════════════
class UnifiedOverlayWindow extends StatefulWidget {
  const UnifiedOverlayWindow({super.key});

  @override
  State<UnifiedOverlayWindow> createState() => _UnifiedOverlayWindowState();
}

class _UnifiedOverlayWindowState extends State<UnifiedOverlayWindow>
    with SingleTickerProviderStateMixin {
  final _allItems = _buildAllItems();
  final _random = math.Random();
  _PopupItem? _current;
  Timer? _autoRefreshTimer;
  String? _filter; // 'adhkar' or 'dua'

  // Animation
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // ── Slide-in من اليمين ──
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideCtrl, curve: const Interval(0.0, 0.4)),
    );

    _pickRandom();
    _slideCtrl.forward();

    // تحديث كل 15 دقيقة إذا ظل الـ overlay مفتوحاً
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _pickRandom(animate: true);
    });

    // استقبال بيانات من التطبيق الرئيسي
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map) {
        if (data.containsKey('type')) {
          setState(() {
            _filter = data['type'];
            _pickRandom(animate: true);
          });
        }
      } else if (data is int && data >= 0 && data < _allItems.length) {
        setState(() => _current = _allItems[data]);
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
    super.dispose();
  }

  // ─── الألوان الثابتة (لا يمكن استخدام Theme في isolate) ───
  static const _gold = Color(0xFFC9A66B);
  static const _goldDark = Color(0xFFA07838);
  static const _cardBg = Color(0xEE1A2420); // شفافية بسيطة (EE = 93%)
  static const _textMain = Color(0xFFF5F0E8);
  static const _textSec = Color(0xFF8CA090);

  @override
  Widget build(BuildContext context) {
    if (_current == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Align(
          alignment: Alignment.center,
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final item = _current!;

    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isDua
              ? const Color(0xFF2D6A4F).withOpacity(0.5)
              : _gold.withOpacity(0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── شريط علوي ملوّن ──
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.isDua
                    ? [const Color(0xFF2D6A4F), const Color(0xFF52B788)]
                    : [_goldDark, _gold, const Color(0xFFE8D5A3)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header: Icon + تصنيف + إغلاق ──
                Row(
                  children: [
                    // أيقونة التصنيف
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: (item.isDua ? const Color(0xFF2D6A4F) : _gold)
                            .withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (item.isDua ? const Color(0xFF52B788) : _gold)
                              .withOpacity(0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.categoryName,
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              color: item.isDua
                                  ? const Color(0xFF52B788)
                                  : _gold,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            'تقوى · ${item.isDua ? 'أدعية' : 'أذكار'} 📿',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _textSec,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // زر الإغلاق
                    GestureDetector(
                      onTap: () => FlutterOverlayWindow.closeOverlay(),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: _textSec,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── فاصل رفيع ──
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _gold.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── النص العربي ──
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      item.arabic,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        color: _textMain,
                        height: 1.9,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),

                // ── معنى الدعاء (إن وُجد) ──
                if (item.isDua && item.meaning != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.meaning!,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 11,
                      color: _textSec,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // ── الفضل (أذكار) ──
                if (!item.isDua && item.fadl != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.fadl!,
                          style: TextStyle(
                            fontSize: 10,
                            color: _gold.withOpacity(0.8),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),

                // ── شريط المصدر + أزرار ──
                Row(
                  children: [
                    // نسخ
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: item.arabic));
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: _textSec,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // المصدر
                    if (item.source != null)
                      Expanded(
                        child: Text(
                          item.source!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: _textSec,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),

                    // ذكر آخر
                    GestureDetector(
                      onTap: () => _pickRandom(animate: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: item.isDua
                                ? [
                                    const Color(0xFF2D6A4F),
                                    const Color(0xFF52B788),
                                  ]
                                : [_goldDark, _gold],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.isDua ? 'دعاء آخر' : 'ذكر آخر',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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
    );
  }
}
