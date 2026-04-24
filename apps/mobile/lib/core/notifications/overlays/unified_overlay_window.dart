// import 'dart:async';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter_overlay_window/flutter_overlay_window.dart';

// import '../../providers/adhkar_providers.dart';
// import '../../theme/app_theme.dart';
// import '../../widgets/custom_pattern_background.dart';
// import 'package:takwa/features/duas/data/duas_data.dart';

// // ─────────────────────────────────────────
// //  نموذج بيانات موحّد للعرض
// // ─────────────────────────────────────────
// class _PopupItem {
//   final String arabic;
//   final String? meaning;
//   final String? fadl;
//   final String? source;
//   final String emoji;
//   final String categoryName;
//   final bool isDua;

//   const _PopupItem({
//     required this.arabic,
//     required this.emoji,
//     required this.categoryName,
//     required this.isDua,
//     this.meaning,
//     this.fadl,
//     this.source,
//   });
// }

// // ─────────────────────────────────────────
// //  بناء قائمة موحّدة من كل الأذكار والأدعية
// // ─────────────────────────────────────────
// List<_PopupItem> _buildAllItems() {
//   final items = <_PopupItem>[];

//   // ── الأذكار ──
//   final catNames = {
//     AdhkarCategory.morning: ('🌅', 'أذكار الصباح'),
//     AdhkarCategory.evening: ('🌆', 'أذكار المساء'),
//     AdhkarCategory.afterPrayer: ('🕌', 'أذكار بعد الصلاة'),
//     AdhkarCategory.sleep: ('🌙', 'أذكار النوم'),
//     AdhkarCategory.misc: ('📿', 'أذكار متنوعة'),
//   };
//   for (final entry in kAdhkarData.entries) {
//     final meta = catNames[entry.key]!;
//     for (final d in entry.value) {
//       items.add(
//         _PopupItem(
//           arabic: d.arabic,
//           fadl: d.fadl,
//           source: d.source,
//           emoji: meta.$1,
//           categoryName: meta.$2,
//           isDua: false,
//         ),
//       );
//     }
//   }

//   // ── الأدعية ──
//   const duaCatNames = {
//     DuaCategory.morning: ('🌅', 'دعاء الصباح'),
//     DuaCategory.distress: ('🌊', 'دعاء الكرب'),
//     DuaCategory.guidance: ('🌟', 'دعاء الهداية'),
//     DuaCategory.forgiveness: ('🌿', 'دعاء المغفرة'),
//     DuaCategory.rizq: ('🌾', 'دعاء الرزق'),
//     DuaCategory.health: ('🫀', 'دعاء الصحة'),
//     DuaCategory.parents: ('❤️', 'دعاء الوالدين'),
//     DuaCategory.travel: ('✈️', 'دعاء السفر'),
//     DuaCategory.rain: ('🌧️', 'دعاء الاستسقاء'),
//     DuaCategory.general: ('🤲', 'دعاء عام'),
//   };
//   for (final entry in kDuasData.entries) {
//     final meta = duaCatNames[entry.key];
//     if (meta == null) continue;
//     for (final d in entry.value) {
//       items.add(
//         _PopupItem(
//           arabic: d.arabic,
//           meaning: d.meaning,
//           source: d.source,
//           emoji: d.emoji,
//           categoryName: meta.$2,
//           isDua: true,
//         ),
//       );
//     }
//   }

//   return items;
// }

// class UnifiedOverlayWindow extends StatefulWidget {
//   const UnifiedOverlayWindow({super.key});

//   @override
//   State<UnifiedOverlayWindow> createState() => _UnifiedOverlayWindowState();
// }

// class _UnifiedOverlayWindowState extends State<UnifiedOverlayWindow>
//     with TickerProviderStateMixin {
//   final _allItems = _buildAllItems();
//   final _random = math.Random();
//   _PopupItem? _current;
//   Timer? _autoRefreshTimer;
//   Timer? _closeTimer;
//   String? _filter;
//   final Duration _displayDuration = const Duration(seconds: 15);

//   // Animation
//   late final AnimationController _slideCtrl;
//   late final Animation<Offset> _slideAnim;
//   late final Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();

//     // ── Slide-in Animation ──
//     _slideCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _slideAnim = Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _slideCtrl,
//             curve: Curves.elasticOut,
//             reverseCurve: Curves.easeInBack,
//           ),
//         );
//     _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn);

//     _pickRandom();
//     _slideCtrl.forward();

//     // Refresh if stays open
//     _autoRefreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
//       _pickRandom(animate: true);
//     });

//     _startCloseTimer();

//     // Listen to data from main isolate
//     FlutterOverlayWindow.overlayListener.listen((data) {
//       if (data is Map) {
//         if (data.containsKey('type')) {
//           setState(() {
//             _filter = data['type'];
//             _pickRandom(animate: true);
//           });
//         }
//       } else if (data is int && data >= 0 && data < _allItems.length) {
//         setState(() {
//           _current = _allItems[data];
//           _slideCtrl.forward(from: 0);
//           _startCloseTimer();
//         });
//       } else {
//         _pickRandom(animate: true);
//       }
//     });
//   }

//   void _startCloseTimer() {
//     _closeTimer?.cancel();
//     _closeTimer = Timer(_displayDuration, () {
//       if (mounted) _closeOverlay();
//     });
//   }

//   void _closeOverlay() {
//     _slideCtrl.reverse().then((_) {
//       FlutterOverlayWindow.closeOverlay();
//     });
//   }

//   void _pickRandom({bool animate = false}) {
//     if (_allItems.isEmpty) return;

//     List<_PopupItem> pool = _allItems;
//     if (_filter == 'adhkar') {
//       pool = _allItems.where((i) => !i.isDua).toList();
//     } else if (_filter == 'dua') {
//       pool = _allItems.where((i) => i.isDua).toList();
//     }

//     if (pool.isEmpty) pool = _allItems;

//     final next = pool[_random.nextInt(pool.length)];
//     if (animate) {
//       _slideCtrl.reverse().then((_) {
//         if (mounted) {
//           setState(() => _current = next);
//           _slideCtrl.forward();
//           _startCloseTimer();
//         }
//       });
//     } else {
//       setState(() => _current = next);
//     }
//   }

//   @override
//   void dispose() {
//     _autoRefreshTimer?.cancel();
//     _closeTimer?.cancel();
//     _slideCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_current == null) return const SizedBox.shrink();

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Stack(
//           children: [
//             // ── Transparent Dismissible Area ──
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: _closeOverlay,
//                 child: Container(color: Colors.transparent),
//               ),
//             ),

//             // ── Card Position (Top Banner) ──
//             Positioned(
//               top: 160,
//               left: 12,
//               right: 12,
//               child: SlideTransition(
//                 position: _slideAnim,
//                 child: FadeTransition(
//                   opacity: _fadeAnim,
//                   child: GestureDetector(onTap: () {}, child: _buildCard()),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCard() {
//     final item = _current!;
//     final colors = context.colors;

//     return Container(
//       decoration: BoxDecoration(
//         color: colors.card.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: colors.gold.withOpacity(0.4), width: 1.2),
//         boxShadow: [
//           BoxShadow(
//             color: colors.gold.withOpacity(0.15),
//             blurRadius: 25,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Stack(
//         children: [
//           // ── Background Pattern ──
//           const Positioned.fill(
//             child: CustomPatternBackground(
//               pattern: BackgroundPattern.geometric,
//             ),
//           ),

//           // ── Progress Bar ──
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: TweenAnimationBuilder<double>(
//               key: ValueKey(item.arabic),
//               tween: Tween(begin: 1.0, end: 0.0),
//               duration: _displayDuration,
//               builder: (context, value, _) {
//                 return LinearProgressIndicator(
//                   value: value,
//                   minHeight: 3,
//                   backgroundColor: Colors.transparent,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     colors.gold.withOpacity(0.6),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ── Main Content ──
//           SizedBox(
//             width: double.infinity,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Header ──
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 38,
//                         height: 38,
//                         decoration: BoxDecoration(
//                           color: colors.gold.withOpacity(0.12),
//                           shape: BoxShape.circle,
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           item.emoji,
//                           style: const TextStyle(fontSize: 20),
//                         ),
//                       ),
//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item.categoryName,
//                               maxLines: 1,
//                               overflow: TextOverflow
//                                   .ellipsis, // ✅ FIX: منع overflow النص
//                               style: TextStyle(
//                                 fontFamily: 'Amiri',
//                                 fontSize: 16,
//                                 color: colors.gold,
//                                 fontWeight: FontWeight.w700,
//                                 height: 1.2,
//                               ),
//                             ),
//                             Text(
//                               'انقر للمتابعة',
//                               style: context.typography.caption.copyWith(
//                                 color: colors.textSecondary,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         width: 32,
//                         height: 32,
//                         child: IconButton(
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                           icon: Icon(
//                             Icons.close_rounded,
//                             color: colors.textDim,
//                             size: 18,
//                           ),
//                           onPressed: _closeOverlay,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 16),

//                   // ── Arabic Content ──
//                   ConstrainedBox(
//                     constraints: const BoxConstraints(maxHeight: 160),
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: Text(
//                           item.arabic,
//                           textAlign: TextAlign.right,
//                           style: context.typography.quranicVerse.copyWith(
//                             fontSize: 22,
//                             color: colors.textPrimary,
//                             height: 1.6,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ── Source / Meaning ──
//                   if (item.source != null || item.fadl != null) ...[
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: colors.teal.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.menu_book_rounded,
//                             color: colors.teal,
//                             size: 14,
//                           ),
//                           const SizedBox(width: 6),
//                           Flexible(
//                             child: Text(
//                               item.source ?? item.fadl!,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: context.typography.caption.copyWith(
//                                 color: colors.teal,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../../providers/adhkar_providers.dart';
import 'package:takwa/features/duas/data/duas_data.dart';

// ═══════════════════════════════════════════════════
//  ISLAMIC GOLD PALETTE
// ═══════════════════════════════════════════════════
class _IGold {
  // static const deep = Color(0xFF0B0F1C); // خلفية عميقة
  // static const card = Color(0xFF111827); // بطاقة
  // static const border = Color(0xFF12192E); // حدود داخلية
  static const gold1 = Color(0xFFF0C040); // ذهبي فاتح
  static const gold2 = Color(0xFFC8960C); // ذهبي وسط
  static const gold3 = Color(0xFF7A5500); // ذهبي غامق
  static const teal = Color(0xFF3ABFA8); // فيروزي
  static const white80 = Color(0xCCF5F0E8); // أبيض دافئ
  static const white50 = Color(0x80F5F0E8);
  // static const white30 = Color(0x4DF5F0E8);
  // static const glow = Color(0x33F0C040); // هالة ذهبية
}

// ═══════════════════════════════════════════════════
//  DATA MODEL
// ═══════════════════════════════════════════════════
class _PopupItem {
  final String arabic;
  final String? meaning;
  final String? fadl;
  final String? source;
  final String emoji;
  final String categoryName;
  final bool isDua;

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

List<_PopupItem> _buildAllItems() {
  final items = <_PopupItem>[];

  final catNames = {
    AdhkarCategory.morning: ('🌅', 'أذكار الصباح'),
    AdhkarCategory.evening: ('🌆', 'أذكار المساء'),
    AdhkarCategory.afterPrayer: ('🕌', 'أذكار بعد الصلاة'),
    AdhkarCategory.sleep: ('🌙', 'أذكار النوم'),
    AdhkarCategory.misc: ('📿', 'أذكار متنوعة'),
    AdhkarCategory.wakingUp: ('📿', 'الاستيقاظ من النوم'),
    AdhkarCategory.food: ('📿', 'أذكار الطعام'),
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

// ═══════════════════════════════════════════════════
//  ISLAMIC GEOMETRIC BACKGROUND PAINTER
// ═══════════════════════════════════════════════════
class _IslamicPatternPainter extends CustomPainter {
  final double opacity;
  const _IslamicPatternPainter({this.opacity = 0.07});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _IGold.gold1.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const step = 28.0;
    // نجمة إسلامية ثمانية الأضلاع مكررة
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar8(canvas, Offset(x, y), step * 0.42, paint);
      }
    }
    // خطوط الشبكة الهندسية
    final gridPaint = Paint()
      ..color = _IGold.gold1.withOpacity(opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawStar8(Canvas canvas, Offset center, double r, Paint paint) {
    const sides = 8;
    const innerRatio = 0.38;
    final path = Path();
    for (int i = 0; i < sides * 2; i++) {
      final angle = (i * math.pi / sides) - math.pi / 2;
      final radius = i.isEven ? r : r * innerRatio;
      final pt = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IslamicPatternPainter old) => old.opacity != opacity;
}

// ═══════════════════════════════════════════════════
//  CORNER ORNAMENT PAINTER
// ═══════════════════════════════════════════════════
class _CornerOrnamentPainter extends CustomPainter {
  const _CornerOrnamentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [_IGold.gold1, _IGold.gold2],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const len = 18.0;
    const r = 6.0;

    // ── أعلى يمين ──
    canvas.drawLine(
      Offset(size.width - len, 0),
      Offset(size.width - r, 0),
      paint,
    );
    canvas.drawLine(Offset(size.width, r), Offset(size.width, len), paint);
    canvas.drawArc(
      Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2),
      -math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );

    // ── أعلى يسار ──
    canvas.drawLine(const Offset(len, 0), const Offset(r, 0), paint);
    canvas.drawLine(const Offset(0, r), const Offset(0, len), paint);
    canvas.drawArc(
      const Rect.fromLTWH(0, 0, r * 2, r * 2),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );

    // ── أسفل يمين ──
    canvas.drawLine(
      Offset(size.width - len, size.height),
      Offset(size.width - r, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - r),
      Offset(size.width, size.height - len),
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2),
      0,
      math.pi / 2,
      false,
      paint,
    );

    // ── أسفل يسار ──
    canvas.drawLine(Offset(len, size.height), Offset(r, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height - r),
      Offset(0, size.height - len),
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════
//  GOLDEN DIVIDER
// ═══════════════════════════════════════════════════
class _GoldDivider extends StatelessWidget {
  const _GoldDivider();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _IGold.gold2, Colors.transparent],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '✦',
            style: TextStyle(
              color: _IGold.gold1.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _IGold.gold2, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  SHIMMER PROGRESS BAR
// ═══════════════════════════════════════════════════
class _GoldProgressBar extends StatefulWidget {
  final Duration duration;
  final Key barKey;
  const _GoldProgressBar({required this.duration, required this.barKey})
    : super(key: barKey);
  @override
  State<_GoldProgressBar> createState() => _GoldProgressBarState();
}

class _GoldProgressBarState extends State<_GoldProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: widget.barKey,
      tween: Tween(begin: 1.0, end: 0.0),
      duration: widget.duration,
      builder: (ctx, value, _) {
        return AnimatedBuilder(
          animation: _shimmer,
          builder: (_, __) {
            return Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [_IGold.gold3, _IGold.gold1, _IGold.gold3],
                  stops: [
                    (_shimmer.value - 0.3).clamp(0.0, 1.0),
                    _shimmer.value.clamp(0.0, 1.0),
                    (_shimmer.value + 0.3).clamp(0.0, 1.0),
                  ],
                ),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_IGold.gold3, _IGold.gold1],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════
//  MAIN WIDGET
// ═══════════════════════════════════════════════════
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
  Timer? _closeTimer;
  String? _filter;
  final Duration _displayDuration = const Duration(seconds: 15);

  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    // ── Slide Animation ──
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(1.6, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideCtrl,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeInCubic,
          ),
        );
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn);

    // ── Glow Pulse ──
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _pickRandom();
    _slideCtrl.forward();

    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _pickRandom(animate: true);
    });
    _startCloseTimer();

    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map && data.containsKey('type')) {
        setState(() {
          _filter = data['type'];
        });
        _pickRandom(animate: true);
      } else if (data is int && data >= 0 && data < _allItems.length) {
        setState(() {
          _current = _allItems[data];
        });
        _slideCtrl.forward(from: 0);
        _startCloseTimer();
      } else {
        _pickRandom(animate: true);
      }
    });
  }

  void _startCloseTimer() {
    _closeTimer?.cancel();
    _closeTimer = Timer(_displayDuration, () {
      if (mounted) _closeOverlay();
    });
  }

  void _closeOverlay() {
    _slideCtrl.reverse().then((_) {
      FlutterOverlayWindow.closeOverlay();
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
        if (!mounted) return;
        setState(() => _current = next);
        _slideCtrl.forward();
        _startCloseTimer();
      });
    } else {
      setState(() => _current = next);
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _closeTimer?.cancel();
    _slideCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ── Dismiss Area ──
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),

            // ── Card: center right ──
            Positioned(
              top: 220,
              left: 12,
              right: 12,
              child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 30),
                child: SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: GestureDetector(onTap: () {}, child: _buildCard()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  CARD
  // ═══════════════════════════════════════
  Widget _buildCard() {
    final item = _current!;

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // ── Multi-layer glow ──
          boxShadow: [
            BoxShadow(
              color: _IGold.gold2.withOpacity(_glowAnim.value * 0.2),
              blurRadius: 15,
              spreadRadius: 0.5,
              offset: const Offset(-3, 0),
            ),
            BoxShadow(
              color: _IGold.gold1.withOpacity(_glowAnim.value * 0.05),
              blurRadius: 25,
              spreadRadius: 1,
              offset: const Offset(-6, 0),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 20,
              offset: const Offset(2, 6),
            ),
          ],
        ),
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF141C2E), // أزرق داكن عميق
                Color(0xFF0D1220), // أعمق
                Color(0xFF0A0F1A), // أسود إسلامي
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // ── Islamic Pattern Background ──
              const Positioned.fill(
                child: CustomPaint(
                  painter: _IslamicPatternPainter(opacity: 0.055),
                ),
              ),

              // ── Top gold gradient wash ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _IGold.gold3.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Outer gold border ──
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _IGold.gold2.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                ),
              ),

              // ── Inner thin border ──
              Positioned(
                top: 3,
                left: 3,
                right: 3,
                bottom: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _IGold.gold1.withOpacity(0.08),
                      width: 0.8,
                    ),
                  ),
                ),
              ),

              // ── Corner ornaments ──
              const Positioned.fill(
                child: CustomPaint(painter: _CornerOrnamentPainter()),
              ),

              // ── Shimmer progress bar at bottom ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                  child: _GoldProgressBar(
                    duration: _displayDuration,
                    barKey: ValueKey('progress_${item.arabic.hashCode}'),
                  ),
                ),
              ),

              // ── Main Content ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(item),
                    const SizedBox(height: 10),
                    const _GoldDivider(),
                    const SizedBox(height: 12),
                    _buildArabicText(item),
                    if (item.source != null || item.fadl != null) ...[
                      const SizedBox(height: 10),
                      const _GoldDivider(),
                      const SizedBox(height: 8),
                      _buildSource(item),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────
  //  HEADER ROW
  // ─────────────────────────────
  Widget _buildHeader(_PopupItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Emoji في دائرة ذهبية
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF2A1F00), Color(0xFF0D1220)],
            ),
            border: Border.all(
              color: _IGold.gold2.withOpacity(0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _IGold.gold2.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: 0.5,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(item.emoji, style: const TextStyle(fontSize: 19)),
        ),

        const SizedBox(width: 10),

        // اسم التصنيف
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_IGold.gold1, _IGold.gold2, _IGold.gold1],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Text(
                  item.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white, // يُطغى عليه بـ ShaderMask
                    height: 1.2,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    item.isDua ? 'دعاء' : 'ذكر',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 10,
                      color: _IGold.teal.withOpacity(0.85),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '•',
                    style: TextStyle(color: _IGold.gold3, fontSize: 8),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'اضغط خارجاً للإغلاق',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 10,
                      color: _IGold.white50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // زر الإغلاق الذهبي
        GestureDetector(
          onTap: _closeOverlay,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _IGold.gold3.withOpacity(0.25),
              border: Border.all(
                color: _IGold.gold2.withOpacity(0.4),
                width: 0.8,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.close_rounded,
              color: _IGold.gold1.withOpacity(0.8),
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────
  //  ARABIC TEXT
  // ─────────────────────────────
  Widget _buildArabicText(_PopupItem item) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 210),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // زخرفة بسملة صغيرة
              Text(
                '﷽',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13,
                  color: _IGold.gold2.withOpacity(0.55),
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                item.arabic,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 21,
                  color: _IGold.white80,
                  height: 1.85,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────
  //  SOURCE BADGE
  // ─────────────────────────────
  Widget _buildSource(_PopupItem item) {
    final text = item.source ?? item.fadl ?? '';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              _IGold.gold3.withOpacity(0.3),
              _IGold.gold3.withOpacity(0.15),
            ],
          ),
          border: Border.all(color: _IGold.gold2.withOpacity(0.35), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              color: _IGold.gold2,
              size: 12,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 11,
                  color: _IGold.gold1.withOpacity(0.85),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
