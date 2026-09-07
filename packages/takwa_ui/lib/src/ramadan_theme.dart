import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import 'app_theme.dart';

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

class RamadanTheme {
  static ThemeData theme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final locale = Localizations.localeOf(context);
    return brightness == Brightness.dark ? dark(locale) : light(locale);
  }

  /// [locale] defaults to Arabic, matching this app's default UI language.
  static ThemeData dark([Locale locale = const Locale('ar')]) {
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
      dangerDim: RamadanColors.rubyLight.withValues(alpha: 0.1),
      warning: RamadanColors.goldenAura,
      // On-surface accent ramp — see AppColorsExtension. On deep lapis the
      // gold/emerald fills already clear AA as foregrounds; rubyLight does
      // not (2.89:1), so error text gets a lifted tint.
      goldText: RamadanColors.goldenAura,
      tealText: RamadanColors.emeraldLight,
      successText: RamadanColors.emeraldLight,
      warningText: RamadanColors.goldenAura,
      dangerText: const Color(0xFFE0808C), // 6.59:1 on deepLapis
      textPrimary: RamadanColors.ivory,
      textSecondary: RamadanColors.ivoryDim,
      // 0.5 opacity landed at 3.49:1 on deepLapis; 0.72 clears AA.
      textDim: RamadanColors.ivoryDim.withValues(alpha: 0.72),
      backgroundGradient: RamadanColors.nightSky,
      cardGradient: RamadanColors.cardGlow,
      goldGradient: AppColorsExtension.dark.goldGradient,
      tealGoldGradient: AppColorsExtension.dark.tealGoldGradient,
    );

    final typography = AppTypographyExtension.fromColors(colors, locale);
    final shadows = AppShadowsExtension.fromColors(colors);
    final decorations = AppDecorationsExtension.fromColors(colors, shadows);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: appFontFamily(locale),
      extensions: [colors, typography, shadows, decorations],
      colorScheme: const ColorScheme.dark(
        primary: RamadanColors.goldenAura,
        onPrimary: Color(0xFF241B05), // 7.68:1 on goldenAura
        onError: Colors.white,
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
      textTheme: _buildTextTheme(
        RamadanColors.ivory,
        RamadanColors.goldenAura,
        locale,
      ),
      elevatedButtonTheme: _buildButtonTheme(
        RamadanColors.goldenAura,
        RamadanColors.deepLapis,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: RamadanColors.lapis,
        selectedItemColor: RamadanColors.goldenAura,
        unselectedItemColor: RamadanColors.ivoryDim.withValues(alpha: 0.4),
      ),
      dividerTheme: const DividerThemeData(color: RamadanColors.border),
      appBarTheme: _buildAppBarTheme(RamadanColors.goldenAura, locale),
    );
  }

  static ThemeData light([Locale locale = const Locale('ar')]) {
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
      dangerDim: RamadanColors.ruby.withValues(alpha: 0.1),
      warning: RamadanColors.goldenAura,
      // goldenDeep (#A07820) is only 3.84:1 on the ivory ground, so the
      // on-surface gold is darkened further; emerald and ruby already pass.
      goldText: const Color(0xFF6E5110), // 7.01:1 on ivoryLight
      tealText: RamadanColors.emerald,
      successText: RamadanColors.emerald,
      warningText: const Color(0xFF6E5110),
      dangerText: RamadanColors.ruby,
      textPrimary: RamadanColors.deepLapis,
      textSecondary: RamadanColors.deepLapis.withValues(alpha: 0.7),
      // 0.4 opacity landed at 2.56:1 on the ivory ground; 0.65 clears AA.
      textDim: RamadanColors.deepLapis.withValues(alpha: 0.65),
      backgroundGradient: RamadanColors.daySky,
      cardGradient: RamadanColors.cardGlowLight,
      goldGradient: AppColorsExtension.light.goldGradient,
      tealGoldGradient: AppColorsExtension.light.tealGoldGradient,
    );

    final typography = AppTypographyExtension.fromColors(colors, locale);
    final shadows = AppShadowsExtension.fromColors(colors);
    final decorations = AppDecorationsExtension.fromColors(colors, shadows);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: appFontFamily(locale),
      extensions: [colors, typography, shadows, decorations],
      colorScheme: const ColorScheme.light(
        primary: RamadanColors.goldenAura,
        // white on goldenAura is 2.0:1 — the same defect as the base theme.
        onPrimary: Color(0xFF241B05), // 7.68:1
        onError: Colors.white,
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
        locale,
      ),
      elevatedButtonTheme: _buildButtonTheme(
        RamadanColors.goldenAura,
        // white on goldenAura is 2.21:1
        const Color(0xFF241B05), // 7.68:1
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: RamadanColors.goldenDeep,
        unselectedItemColor: RamadanColors.deepLapis.withValues(alpha: 0.4),
      ),
      dividerTheme: const DividerThemeData(color: RamadanColors.border),
      appBarTheme: _buildAppBarTheme(RamadanColors.goldenDeep, locale),
    );
  }

  static TextTheme _buildTextTheme(Color main, Color accent, Locale locale) {
    final displayFont = appFontFamily(locale);
    final bodyFont = appBodyFontFamily(locale);
    final fallback = appFontFamilyFallback(locale);
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: fallback,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: accent,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: fallback,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: main,
      ),
      headlineLarge: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: fallback,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: main,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: fallback,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: main,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontFamilyFallback: fallback,
        fontSize: 16,
        color: main,
        height: 1.9,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFont,
        fontFamilyFallback: fallback,
        fontSize: 14,
        color: main,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontFamilyFallback: fallback,
        fontSize: 12,
        color: main.withValues(alpha: 0.7),
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFont,
        fontFamilyFallback: fallback,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: main,
      ),
    );
  }

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

  static AppBarTheme _buildAppBarTheme(Color accent, Locale locale) =>
      AppBarTheme(
        // Removes the shadow/elevation for all AppBars
        scrolledUnderElevation: 0.0,
        // Removes the color tint highlight for all AppBars
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: appFontFamily(locale),
          fontSize: 20,
          color: accent,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: accent),
      );
}

class RamadanDecorations {
  static BoxDecoration get card => BoxDecoration(
    gradient: RamadanColors.cardGlow,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: RamadanColors.border),
    boxShadow: [
      BoxShadow(
        color: RamadanColors.goldenAura.withValues(alpha: 0.06),
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
        color: RamadanColors.goldenAura.withValues(alpha: 0.15),
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

class RamadanBgPainter extends CustomPainter {
  // Was a plain `final double animT` set from a caller-read `_ctrl.value`,
  // with CustomPatternBackground rebuilding via AnimatedBuilder and
  // constructing a BRAND NEW RamadanBgPainter every animation tick (~15/s).
  // That made every field below pointless as a cache: a fresh instance
  // starts with everything null, so the whole arabesque tiling — nested
  // loops over the viewport, a 20-segment star plus 10 béziers per cell —
  // was re-recorded from scratch on every frame, and being `static` on top
  // of that meant every differently-sized CustomPatternBackground on
  // screen (there are dozens, including one inside every PrimaryButton)
  // stomped on the one shared cache.
  //
  // Passing `animation` straight to `super(repaint: animation)` fixes the
  // root cause: the render object now calls paint() again on this SAME
  // painter instance whenever the controller ticks, without rebuilding the
  // widget tree or constructing a new painter — see
  // CustomPatternBackground's Ramadan branch, which no longer wraps this in
  // AnimatedBuilder. That makes the caches below instance fields that
  // actually get reused, keyed by (size, brightness) as before.
  final Animation<double> animation;
  final Brightness brightness;
  RamadanBgPainter({required this.animation, this.brightness = Brightness.dark})
    : super(repaint: animation);

  double get animT => animation.value;

  final math.Random _rng = math.Random(7);
  List<Offset>? _stars;
  Size? _starsSize;
  Picture? _cachedArabesque;
  Size? _cachedArabesqueSize;
  Brightness? _cachedBrightness;

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
      // Dispose the outgoing recording before replacing it — a Picture
      // holds a native (Skia) resource that isn't freed just because the
      // Dart reference is overwritten.
      _cachedArabesque?.dispose();
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
    // Also now keyed by size, not just "has this ever run": the old
    // `_stars ??= ...` generated the field once for whatever size happened
    // to paint first and never regenerated it, so a later resize (rotation,
    // a different screen) left stars scattered to fit stale dimensions.
    if (_stars == null || _starsSize != size) {
      _starsSize = size;
      _stars = List.generate(
        120,
        (_) => Offset(
          _rng.nextDouble() * size.width,
          _rng.nextDouble() * size.height * 0.7,
        ),
      );
    }
    for (int i = 0; i < _stars!.length; i++) {
      final t = (math.sin(animT * 2 * math.pi + i * 0.4) + 1) / 2;
      final r = 0.5 + _rng.nextDouble() * 1.2;
      canvas.drawCircle(
        _stars![i],
        r,
        Paint()..color = RamadanColors.ivory.withValues(alpha: 0.1 + 0.5 * t),
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
            RamadanColors.goldenAura.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: 40)),
    );
  }

  void _drawLantern(Canvas canvas, Offset pos, double scale, bool isDark) {
    final flicker = (math.sin(animT * 2 * math.pi * 1.5) + 1) / 2;
    final p = Paint()
      ..color = RamadanColors.goldenAura.withValues(alpha: isDark ? 0.8 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final glowP = Paint()
      ..color = RamadanColors.goldenLight.withValues(alpha: isDark ? 0.3 * flicker : 0.15 * flicker)
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
      ..color = RamadanColors.goldenLight.withValues(alpha: isDark ? 0.5 * flicker : 0.3 * flicker)
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
        ..color = RamadanColors.goldenAura.withValues(alpha: 0.08)
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
      ..color = RamadanColors.goldenAura.withValues(alpha: isDark ? 0.07 : 0.05)
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
  void dispose() {
    // Called when this painter is finally discarded (the widget is removed,
    // or a same-runtimeType painter replaces it) — releases the cached
    // Picture's native resources instead of leaking them.
    _cachedArabesque?.dispose();
    super.dispose();
  }

  @override
  bool shouldRepaint(covariant RamadanBgPainter old) =>
      // Per-frame repaints are driven by `repaint: animation` above, not by
      // this — Flutter calls paint() again on tick regardless of what this
      // returns. This only matters on the rarer occasion a NEW painter
      // instance replaces this one (e.g. a brightness flip rebuilds
      // CustomPatternBackground), where a differing controller identity or
      // brightness is the real signal to repaint.
      old.animation != animation || old.brightness != brightness;
}

/// Theme-aware style helper used across screens that need to react to
/// Ramadan mode (`AdaptiveStyle(context, isRamadan)`), reading whichever
/// theme extensions are currently active on [context] — the caller (app
/// layer) is responsible for actually setting `theme:`/`darkTheme:` to
/// [AppTheme] or [RamadanTheme] based on its own Ramadan-mode state.
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

  /// Display/heading style — Amiri for Arabic (unchanged), Poppins for
  /// every other locale, with Tajawal fallback for Arabic glyphs.
  TextStyle amiri(
    double size, {
    Color? color,
    FontWeight? weight,
    double? height,
  }) => TextStyle(
    fontFamily: appFontFamily(Localizations.localeOf(context)),
    fontFamilyFallback: appFontFamilyFallback(Localizations.localeOf(context)),
    fontSize: size,
    color: color ?? gold,
    fontWeight: weight ?? FontWeight.w700,
    height: height,
    shadows: isRamadan
        ? [
            Shadow(
              color: gold.withValues(alpha: size > 20 ? 0.4 : 0.2),
              blurRadius: size > 20 ? 12 : 8,
            ),
          ]
        : null,
  );

  /// Body style — NotoNaskhArabic for Arabic (unchanged), Poppins for
  /// every other locale, with Tajawal fallback for Arabic glyphs.
  TextStyle naskh(
    double size, {
    Color? color,
    FontWeight? weight,
    double? height,
  }) => TextStyle(
    fontFamily: appBodyFontFamily(Localizations.localeOf(context)),
    fontFamilyFallback: appFontFamilyFallback(Localizations.localeOf(context)),
    fontSize: size,
    color: color ?? (size < 12 ? textSec : text),
    fontWeight: weight ?? FontWeight.w400,
    height: height,
  );

  /// Clean modern Arabic style using Tajawal.
  TextStyle tajawal(
    double size, {
    Color? color,
    FontWeight? weight,
    double? height,
  }) => TextStyle(
    fontFamily: 'Tajawal',
    fontFamilyFallback: appFontFamilyFallback(Localizations.localeOf(context)),
    fontSize: size,
    color: color ?? (size < 12 ? textSec : text),
    fontWeight: weight ?? FontWeight.w400,
    height: height,
  );
}
