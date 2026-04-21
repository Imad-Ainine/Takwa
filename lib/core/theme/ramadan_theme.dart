// ═══════════════════════════════════════════════════════════════
//  lib/core/theme/ramadan_theme.dart
//  تقوى — Ramadan Dynamic Theme System
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/widgets/primary_switch.dart';
import 'package:takwa/core/notifications/notifications_service.dart';
import 'package:takwa/core/supabase/sync_manager.dart';

// ═══════════════════════════════════════════════════════════════
//  RAMADAN COLOR PALETTE  (تجاوز الألوان الأساسية)
// ═══════════════════════════════════════════════════════════════
class RamadanColors {
  // Deep lapis + gold + emerald — ألوان الفسيفساء الإسلامية
  static const deepLapis = Color(0xFF0A1628);
  static const lapis = Color(0xFF0F2044);
  static const lapisLight = Color(0xFF0C1B3C);
  static const lapisCard = Color(0xBD101A32);

  static const goldenAura = Color(0xFFD4A843);
  static const goldenLight = Color(0xFFEDD278);
  static const goldenDeep = Color(0xFFA07820);
  static const goldenDim = Color(0x30D4A843);

  static const emerald = Color(0xFF1B6B4E);
  static const emeraldLight = Color(0xFF2A9E73);
  static const emeraldDim = Color(0x20278055);

  static const ruby = Color(0xFF8B2635);
  static const rubyLight = Color(0xFFB03040);

  static const ivory = Color(0xFFF5ECD7);
  static const ivoryLight = Color(0xFFFCF9F2);
  static const ivoryDim = Color(0xFFD4C4A0);
  static const ivoryGhost = Color(0x15F5ECD7);

  static const border = Color(0x40D4A843);
  static const borderLight = Color(0x60EDD278);

  // Gradients
  static const LinearGradient nightSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF050D1A), Color(0xFF0A1628), Color(0xFF0F2044)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient daySky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFCF9F2), Color(0xFFF5ECD7), Color(0xFFE8DDC3)],
  );

  static const LinearGradient goldenGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x28D4A843), Color(0x121B6B4E)],
  );

  static const LinearGradient cardGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2044), Color.fromARGB(255, 3, 18, 52)],
  );

  static const LinearGradient cardGlowLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFCF9F2)],
  );
}

// ═══════════════════════════════════════════════════════════════
//  RAMADAN THEME DATA
// ═══════════════════════════════════════════════════════════════
class RamadanTheme {
  static ThemeData theme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? dark : light;
  }

  static ThemeData get dark {
    final colors = AppColorsExtension(
      background: RamadanColors.deepLapis,
      deep: RamadanColors.lapis,
      card: RamadanColors.lapisCard,
      card2: RamadanColors.lapisCard,
      border: RamadanColors.border,
      night: RamadanColors.deepLapis,
      gold: RamadanColors.goldenAura,
      goldLight: RamadanColors.goldenLight,
      goldDark: RamadanColors.goldenDeep,
      goldDim: RamadanColors.goldenDim,
      teal: RamadanColors.emeraldLight,
      tealDim: RamadanColors.emeraldDim,
      success: RamadanColors.emeraldLight,
      successDim: RamadanColors.emeraldDim,
      danger: RamadanColors.rubyLight,
      dangerDim: RamadanColors.rubyLight.withOpacity(0.1),
      warning: RamadanColors.goldenAura,
      textPrimary: RamadanColors.ivory,
      textSecondary: RamadanColors.ivoryDim,
      textDim: RamadanColors.ivoryDim.withOpacity(0.5),
      backgroundGradient: RamadanColors.nightSky,
      cardGradient: RamadanColors.cardGlow,
      goldGradient: AppColorsExtension.dark.goldGradient,
      tealGoldGradient: AppColorsExtension.dark.tealGoldGradient,
    );

    final typography = AppTypographyExtension.fromColors(colors);
    final shadows = AppShadowsExtension.fromColors(colors);
    final decorations = AppDecorationsExtension.fromColors(colors, shadows);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: [colors, typography, shadows, decorations],
      colorScheme: const ColorScheme.dark(
        primary: RamadanColors.goldenAura,
        onPrimary: RamadanColors.deepLapis,
        secondary: RamadanColors.emeraldLight,
        onSecondary: RamadanColors.deepLapis,
        surface: RamadanColors.lapisCard,
        onSurface: RamadanColors.ivory,
        error: RamadanColors.rubyLight,
        outline: RamadanColors.border,
        primaryContainer: RamadanColors.goldenDim,
        secondaryContainer: RamadanColors.emeraldDim,
      ),
      scaffoldBackgroundColor: RamadanColors.deepLapis,
      cardTheme: CardThemeData(
        color: RamadanColors.lapisCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: RamadanColors.border, width: 1),
        ),
      ),
      textTheme: _buildTextTheme(RamadanColors.ivory, RamadanColors.goldenAura),
      elevatedButtonTheme: _buildButtonTheme(
        RamadanColors.goldenAura,
        RamadanColors.deepLapis,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: RamadanColors.lapis,
        selectedItemColor: RamadanColors.goldenAura,
        unselectedItemColor: RamadanColors.ivoryDim.withOpacity(0.4),
      ),
      dividerTheme: const DividerThemeData(color: RamadanColors.border),
      appBarTheme: _buildAppBarTheme(RamadanColors.goldenAura),
    );
  }

  static ThemeData get light {
    final colors = AppColorsExtension(
      background: RamadanColors.ivoryLight,
      deep: RamadanColors.ivory,
      card: Colors.white,
      card2: RamadanColors.ivoryLight,
      border: RamadanColors.border,
      night: RamadanColors.deepLapis,
      gold: RamadanColors.goldenAura,
      goldLight: RamadanColors.goldenLight,
      goldDark: RamadanColors.goldenDeep,
      goldDim: RamadanColors.goldenDim,
      teal: RamadanColors.emerald,
      tealDim: RamadanColors.emeraldDim,
      success: RamadanColors.emerald,
      successDim: RamadanColors.emeraldDim,
      danger: RamadanColors.ruby,
      dangerDim: RamadanColors.ruby.withOpacity(0.1),
      warning: RamadanColors.goldenAura,
      textPrimary: RamadanColors.deepLapis,
      textSecondary: RamadanColors.deepLapis.withOpacity(0.7),
      textDim: RamadanColors.deepLapis.withOpacity(0.4),
      backgroundGradient: RamadanColors.daySky,
      cardGradient: RamadanColors.cardGlowLight,
      goldGradient: AppColorsExtension.light.goldGradient,
      tealGoldGradient: AppColorsExtension.light.tealGoldGradient,
    );

    final typography = AppTypographyExtension.fromColors(colors);
    final shadows = AppShadowsExtension.fromColors(colors);
    final decorations = AppDecorationsExtension.fromColors(colors, shadows);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: [colors, typography, shadows, decorations],
      colorScheme: const ColorScheme.light(
        primary: RamadanColors.goldenAura,
        onPrimary: Colors.white,
        secondary: RamadanColors.emerald,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: RamadanColors.deepLapis,
        error: RamadanColors.ruby,
        outline: RamadanColors.border,
        primaryContainer: RamadanColors.goldenDim,
        secondaryContainer: RamadanColors.emeraldDim,
      ),
      scaffoldBackgroundColor: RamadanColors.ivoryLight,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: RamadanColors.border, width: 1),
        ),
      ),
      textTheme: _buildTextTheme(
        RamadanColors.deepLapis,
        RamadanColors.goldenDeep,
      ),
      elevatedButtonTheme: _buildButtonTheme(
        RamadanColors.goldenAura,
        Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: RamadanColors.goldenDeep,
        unselectedItemColor: RamadanColors.deepLapis.withOpacity(0.4),
      ),
      dividerTheme: const DividerThemeData(color: RamadanColors.border),
      appBarTheme: _buildAppBarTheme(RamadanColors.goldenDeep),
    );
  }

  static TextTheme _buildTextTheme(Color main, Color accent) => TextTheme(
    displayLarge: GoogleFonts.amiri(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: accent,
    ),
    displayMedium: GoogleFonts.amiri(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: main,
    ),
    headlineLarge: GoogleFonts.amiri(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: main,
    ),
    headlineMedium: GoogleFonts.amiri(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: main,
    ),
    bodyLarge: GoogleFonts.notoNaskhArabic(
      fontSize: 16,
      color: main,
      height: 1.9,
    ),
    bodyMedium: GoogleFonts.notoNaskhArabic(fontSize: 14, color: main),
    bodySmall: GoogleFonts.notoNaskhArabic(
      fontSize: 12,
      color: main.withOpacity(0.7),
    ),
    labelLarge: GoogleFonts.notoNaskhArabic(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: main,
    ),
  );

  static ElevatedButtonThemeData _buildButtonTheme(Color bg, Color fg) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      );

  static AppBarTheme _buildAppBarTheme(Color accent) => AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: GoogleFonts.amiri(
      fontSize: 20,
      color: accent,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: accent),
  );
}

// ═══════════════════════════════════════════════════════════════
//  RAMADAN DECORATIONS
// ═══════════════════════════════════════════════════════════════
class RamadanDecorations {
  static BoxDecoration get card => BoxDecoration(
    gradient: RamadanColors.cardGlow,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: RamadanColors.border),
    boxShadow: [
      BoxShadow(
        color: RamadanColors.goldenAura.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get heroCard => BoxDecoration(
    gradient: RamadanColors.goldenGlow,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: RamadanColors.borderLight),
    boxShadow: [
      BoxShadow(
        color: RamadanColors.goldenAura.withOpacity(0.15),
        blurRadius: 24,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration get pill => BoxDecoration(
    color: RamadanColors.goldenDim,
    borderRadius: BorderRadius.circular(100),
    border: Border.all(color: RamadanColors.border),
  );

  static BoxDecoration get page =>
      const BoxDecoration(gradient: RamadanColors.nightSky);
}

// ═══════════════════════════════════════════════════════════════
//  RAMADAN BACKGROUND PAINTER  (مزخرف إسلامي)
// ═══════════════════════════════════════════════════════════════
class RamadanBgPainter extends CustomPainter {
  final double animT;
  final Brightness brightness;
  RamadanBgPainter({this.animT = 0, this.brightness = Brightness.dark});

  static final _rng = math.Random(7);
  static List<Offset>? _stars;
  static Picture? _cachedArabesque;
  static Size? _cachedArabesqueSize;
  static Brightness? _cachedBrightness;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final isDark = brightness == Brightness.dark;

    // Background gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = (isDark ? RamadanColors.nightSky : RamadanColors.daySky)
            .createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    if (isDark) {
      _drawNightElements(canvas, size);
    } else {
      _drawDayElements(canvas, size);
    }

    // Pattern - Caching expensive arabesque
    if (_cachedArabesque == null ||
        _cachedArabesqueSize != size ||
        _cachedBrightness != brightness) {
      _cachedArabesqueSize = size;
      _cachedBrightness = brightness;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);
      _drawArabesque(c, size, isDark);
      _cachedArabesque = recorder.endRecording();
    }
    canvas.drawPicture(_cachedArabesque!);

    // Lanterns (Fanoos)
    _drawLantern(canvas, Offset(size.width * 0.15, 60), 1.0, isDark);
    _drawLantern(canvas, Offset(size.width * 0.85, 40), 0.8, isDark);
  }

  void _drawNightElements(Canvas canvas, Size size) {
    _stars ??= List.generate(
      120,
      (_) => Offset(
        _rng.nextDouble() * size.width,
        _rng.nextDouble() * size.height * 0.7,
      ),
    );
    for (int i = 0; i < _stars!.length; i++) {
      final t = (math.sin(animT * 2 * math.pi + i * 0.4) + 1) / 2;
      final r = 0.5 + _rng.nextDouble() * 1.2;
      canvas.drawCircle(
        _stars![i],
        r,
        Paint()..color = RamadanColors.ivory.withOpacity(0.1 + 0.5 * t),
      );
    }
    _drawCrescent(canvas, Offset(size.width * 0.82, size.height * 0.09), true);
  }

  void _drawDayElements(Canvas canvas, Size size) {
    // Subtle sun glow
    final sunCenter = Offset(size.width * 0.82, size.height * 0.12);
    canvas.drawCircle(
      sunCenter,
      40,
      Paint()
        ..shader = RadialGradient(
          colors: [
            RamadanColors.goldenAura.withOpacity(0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: 40)),
    );
  }

  void _drawLantern(Canvas canvas, Offset pos, double scale, bool isDark) {
    final flicker = (math.sin(animT * 2 * math.pi * 1.5) + 1) / 2;
    final p = Paint()
      ..color = RamadanColors.goldenAura.withOpacity(isDark ? 0.8 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final glowP = Paint()
      ..color = RamadanColors.goldenLight.withOpacity(
        isDark ? 0.3 * flicker : 0.15 * flicker,
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(pos + const Offset(0, 15), 15 * scale, glowP);

    final path = Path();
    final w = 12.0 * scale;
    final h = 25.0 * scale;

    // Top
    path.moveTo(pos.dx - w * 0.5, pos.dy);
    path.lineTo(pos.dx + w * 0.5, pos.dy);
    path.lineTo(pos.dx + w * 0.2, pos.dy - 8 * scale);
    path.lineTo(pos.dx - w * 0.2, pos.dy - 8 * scale);
    path.close();

    // Body
    path.moveTo(pos.dx - w * 0.5, pos.dy);
    path.lineTo(pos.dx - w, pos.dy + h * 0.4);
    path.lineTo(pos.dx - w * 0.6, pos.dy + h);
    path.lineTo(pos.dx + w * 0.6, pos.dy + h);
    path.lineTo(pos.dx + w, pos.dy + h * 0.4);
    path.lineTo(pos.dx + w * 0.5, pos.dy);

    // Bottom
    path.moveTo(pos.dx - w * 0.6, pos.dy + h);
    path.lineTo(pos.dx + w * 0.6, pos.dy + h);
    path.lineTo(pos.dx + w * 0.3, pos.dy + h + 6 * scale);
    path.lineTo(pos.dx - w * 0.3, pos.dy + h + 6 * scale);
    path.close();

    canvas.drawPath(path, p);

    // Inner light
    final innerP = Paint()
      ..color = RamadanColors.goldenLight.withOpacity(
        isDark ? 0.5 * flicker : 0.3 * flicker,
      )
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: pos + Offset(0, h * 0.5),
        width: w * 0.6,
        height: h * 0.4,
      ),
      innerP,
    );
  }

  void _drawCrescent(Canvas canvas, Offset center, bool isDark) {
    const r = 20.0;
    canvas.drawCircle(
      center,
      r + 8,
      Paint()
        ..color = RamadanColors.goldenAura.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFFFF0B3));
    canvas.drawCircle(
      Offset(center.dx + r * 0.55, center.dy - r * 0.05),
      r * 0.88,
      Paint()..color = const Color(0xFF040C1E),
    );
  }

  void _drawArabesque(Canvas canvas, Size size, bool isDark) {
    final p = Paint()
      ..color = RamadanColors.goldenAura.withOpacity(isDark ? 0.07 : 0.05)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    const s = 100.0;
    for (double x = 0; x < size.width + s; x += s) {
      for (double y = 0; y < size.height + s; y += s) {
        final isOdd = (x / s).round().isOdd;
        final py = isOdd ? y + s / 2 : y;
        _drawTenFoldArabesque(canvas, Offset(x, py), s * 0.45, p);
      }
    }
  }

  void _drawTenFoldArabesque(Canvas canvas, Offset c, double r, Paint p) {
    // 10-point star base
    final Path star = Path();
    for (int i = 0; i < 20; i++) {
      final a = i * math.pi / 10;
      final dist = i.isEven ? r : r * 0.7;
      final px = c.dx + dist * math.cos(a);
      final py = c.dy + dist * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    // Interlacing "vine" paths
    final Path vines = Path();
    for (int i = 0; i < 10; i++) {
      final a1 = i * math.pi / 5;
      final a2 = (i + 1) * math.pi / 5;

      final p1 = Offset(c.dx + r * math.cos(a1), c.dy + r * math.sin(a1));
      final p2 = Offset(c.dx + r * math.cos(a2), c.dy + r * math.sin(a2));
      final cp = Offset(
        c.dx + r * 1.4 * math.cos((a1 + a2) / 2),
        c.dy + r * 1.4 * math.sin((a1 + a2) / 2),
      );

      vines.moveTo(p1.dx, p1.dy);
      vines.quadraticBezierTo(cp.dx, cp.dy, p2.dx, p2.dy);
    }
    canvas.drawPath(vines, p);

    // Core detail
    canvas.drawCircle(c, r * 0.3, p);
    _drawSmallStar(canvas, c, r * 0.15, p);
  }

  void _drawSmallStar(Canvas canvas, Offset c, double r, Paint p) {
    final Path s = Path();
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final dist = i.isEven ? r : r * 0.5;
      final px = c.dx + dist * math.cos(a);
      final py = c.dy + dist * math.sin(a);
      if (i == 0) {
        s.moveTo(px, py);
      } else {
        s.lineTo(px, py);
      }
    }
    s.close();
    canvas.drawPath(s, p);
  }

  @override
  bool shouldRepaint(RamadanBgPainter old) =>
      old.animT != animT || old.brightness != brightness;
}

// ═══════════════════════════════════════════════════════════════
//  RAMADAN TOGGLE WIDGET  (الزر المميز)
// ═══════════════════════════════════════════════════════════════

class RamadanToggle extends ConsumerWidget {
  const RamadanToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: isRamadan ? style.gold.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isRamadan ? '🌙' : '☽', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          PrimarySwitch(
            value: isRamadan,
            onChanged: (v) async {
              HapticFeedback.mediumImpact();
              final dao = ref.read(settingsDaoProvider);
              await dao.setBool('ramadanMode', v);
              ref.invalidate(ramadanModeProvider);

              // ── Sync with Cloud & Reschedule Notifications ──
              await NotificationsManager.reschedule(ref);
              await SyncManager.syncSettings(ref);
            },
            accentColor: style.gold,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ADAPTIVE STYLES  (يتكيف مع وضع رمضان)
// ═══════════════════════════════════════════════════════════════
class AdaptiveStyle {
  final BuildContext context;
  final bool isRamadan;
  const AdaptiveStyle(this.context, this.isRamadan);

  AppColorsExtension get _colors =>
      Theme.of(context).extension<AppColorsExtension>()!;
  AppDecorationsExtension get _decorations =>
      Theme.of(context).extension<AppDecorationsExtension>()!;

  Color get gold => _colors.gold;
  Color get goldLight => _colors.goldLight;
  Color get goldDark => _colors.goldDark;
  Color get goldDim => _colors.goldDim;
  Color get teal => _colors.teal;
  Color get success => _colors.success;
  Color get danger => _colors.danger;
  Color get bg => _colors.background;
  Color get deep => _colors.deep;
  Color get card => _colors.card;
  Color get border => _colors.border;
  Color get text => _colors.textPrimary;
  Color get textSec => _colors.textSecondary;
  Color get textDim => _colors.textDim;

  BoxDecoration get cardDeco => _decorations.card;
  BoxDecoration get heroDeco => _decorations.goldCard;

  TextStyle amiri(
    double size, {
    Color? color,
    FontWeight? weight,
    double? height,
  }) => GoogleFonts.amiri(
    fontSize: size,
    color: color ?? gold,
    fontWeight: weight ?? FontWeight.w700,
    height: height,
    shadows: isRamadan
        ? [
            Shadow(
              color: gold.withOpacity(size > 20 ? 0.4 : 0.2),
              blurRadius: size > 20 ? 12 : 8,
            ),
          ]
        : null,
  );

  TextStyle naskh(
    double size, {
    Color? color,
    FontWeight? weight,
    double? height,
  }) => GoogleFonts.notoNaskhArabic(
    fontSize: size,
    color: color ?? (size < 12 ? textSec : text),
    fontWeight: weight ?? FontWeight.w400,
    height: height,
  );
}

// ─────────────────────────────────────────
