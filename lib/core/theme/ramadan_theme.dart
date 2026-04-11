// ═══════════════════════════════════════════════════════════════
//  lib/core/theme/ramadan_theme.dart
//  محاسبة النفس — Ramadan Dynamic Theme System
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/providers/database_providers.dart';

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
}

// ═══════════════════════════════════════════════════════════════
//  RAMADAN THEME DATA
// ═══════════════════════════════════════════════════════════════
class RamadanTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
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
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: RamadanColors.border, width: 1),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.amiri(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: RamadanColors.goldenAura,
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: RamadanColors.ivory,
      ),
      headlineLarge: GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: RamadanColors.ivory,
      ),
      headlineMedium: GoogleFonts.amiri(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: RamadanColors.ivory,
      ),
      bodyLarge: GoogleFonts.notoNaskhArabic(
        fontSize: 16,
        color: RamadanColors.ivory,
        height: 1.9,
      ),
      bodyMedium: GoogleFonts.notoNaskhArabic(
        fontSize: 14,
        color: RamadanColors.ivory,
      ),
      bodySmall: GoogleFonts.notoNaskhArabic(
        fontSize: 12,
        color: RamadanColors.ivoryDim,
      ),
      labelLarge: GoogleFonts.notoNaskhArabic(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: RamadanColors.ivory,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RamadanColors.goldenAura,
        foregroundColor: RamadanColors.deepLapis,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: RamadanColors.lapis,
      selectedItemColor: RamadanColors.goldenAura,
      unselectedItemColor: RamadanColors.ivoryDim.withOpacity(0.4),
    ),
    dividerTheme: const DividerThemeData(color: RamadanColors.border),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.amiri(
        fontSize: 20,
        color: RamadanColors.goldenAura,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: RamadanColors.goldenAura),
    ),
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
  RamadanBgPainter({this.animT = 0});

  static final _rng = math.Random(7);
  static List<Offset>? _stars;

  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF030810), Color(0xFF0A1628), Color(0xFF0F2044)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Stars
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

    // Crescent
    _drawCrescent(canvas, Offset(size.width * 0.82, size.height * 0.09));

    // Geometric arabesque border top
    _drawArabesque(canvas, size);

    // Golden glow at horizon
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                RamadanColors.goldenAura.withOpacity(0.04),
              ],
            ).createShader(
              Rect.fromLTWH(
                0,
                size.height * 0.6,
                size.width,
                size.height * 0.4,
              ),
            ),
    );
  }

  void _drawCrescent(Canvas canvas, Offset center) {
    const r = 20.0;
    // Outer glow
    canvas.drawCircle(
      center,
      r + 8,
      Paint()
        ..color = RamadanColors.goldenAura.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // Moon body
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFFFF0B3));
    // Cut
    canvas.drawCircle(
      Offset(center.dx + r * 0.55, center.dy - r * 0.05),
      r * 0.88,
      Paint()..color = const Color(0xFF040C1E),
    );
    // Stars near moon
    for (int i = 0; i < 5; i++) {
      final angle = i * math.pi * 0.4 - math.pi * 0.2;
      final dist = 30.0 + i * 8;
      final sx = center.dx + dist * math.cos(angle);
      final sy = center.dy + dist * math.sin(angle);
      canvas.drawCircle(
        Offset(sx, sy),
        1.2 - i * 0.15,
        Paint()..color = RamadanColors.goldenLight.withOpacity(0.6),
      );
    }
  }

  void _drawArabesque(Canvas canvas, Size size) {
    final p = Paint()
      ..color = RamadanColors.goldenAura.withOpacity(0.06)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    const s = 48.0;
    for (double x = 0; x < size.width + s; x += s) {
      for (double y = 0; y < size.height + s; y += s) {
        _drawGeomStar(canvas, Offset(x, y), s * 0.3, p);
      }
    }
  }

  void _drawGeomStar(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 8;
      final rr = i.isEven ? r : r * 0.42;
      final pt = Offset(c.dx + rr * math.cos(a), c.dy + rr * math.sin(a));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(RamadanBgPainter old) => old.animT != animT;
}

// ═══════════════════════════════════════════════════════════════
//  RAMADAN TOGGLE WIDGET  (الزر المميز)
// ═══════════════════════════════════════════════════════════════
class RamadanToggle extends ConsumerStatefulWidget {
  const RamadanToggle({super.key});

  @override
  ConsumerState<RamadanToggle> createState() => _RamadanToggleState();
}

class _RamadanToggleState extends ConsumerState<RamadanToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _scale = Tween<double>(
      begin: 0.97,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Uses ramadanModeProvider from database_providers.dart
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final dao = ref.read(settingsDaoProvider);
        await dao.setBool('ramadanMode', !isRamadan);
        ref.invalidate(ramadanModeProvider);
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: isRamadan ? _scale.value : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: isRamadan
                  ? const LinearGradient(
                      colors: [
                        RamadanColors.goldenDeep,
                        RamadanColors.goldenAura,
                      ],
                    )
                  : null,
              color: isRamadan ? null : AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isRamadan
                    ? RamadanColors.goldenLight.withOpacity(_glow.value)
                    : AppColors.border,
                width: isRamadan ? 1.5 : 1,
              ),
              boxShadow: isRamadan
                  ? [
                      BoxShadow(
                        color: RamadanColors.goldenAura.withOpacity(
                          0.3 * _glow.value,
                        ),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isRamadan ? '🌙' : '☽',
                    key: ValueKey(isRamadan),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isRamadan ? 'رمضان كريم' : 'وضع رمضان',
                  style: GoogleFonts.amiri(
                    fontSize: 13,
                    color: isRamadan
                        ? RamadanColors.deepLapis
                        : AppColors.textSecondary,
                    fontWeight: isRamadan ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
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
      Theme.of(context).extension<AppColorsExtension>() ??
      AppColorsExtension.dark;
  AppDecorationsExtension get _decorations =>
      Theme.of(context).extension<AppDecorationsExtension>() ??
      AppDecorationsExtension.fromColors(
        _colors,
        AppShadowsExtension.fromColors(_colors),
      );

  Color get gold => isRamadan ? RamadanColors.goldenAura : _colors.gold;
  Color get goldLight =>
      isRamadan ? RamadanColors.goldenLight : _colors.goldLight;
  Color get goldDim => isRamadan ? RamadanColors.goldenDim : _colors.goldDim;
  Color get teal => isRamadan ? RamadanColors.emeraldLight : _colors.teal;
  Color get bg => isRamadan ? RamadanColors.deepLapis : _colors.background;
  Color get card => isRamadan ? RamadanColors.lapisCard : _colors.card;
  Color get border => isRamadan ? RamadanColors.border : _colors.border;
  Color get text => isRamadan ? RamadanColors.ivory : _colors.textPrimary;
  Color get textSec =>
      isRamadan ? RamadanColors.ivoryDim : _colors.textSecondary;
  Color get success => isRamadan ? RamadanColors.emeraldLight : _colors.success;

  BoxDecoration get cardDeco =>
      isRamadan ? RamadanDecorations.card : _decorations.card;

  BoxDecoration get heroDeco =>
      isRamadan ? RamadanDecorations.heroCard : _decorations.goldCard;

  TextStyle amiri(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.amiri(
        fontSize: size,
        color: color ?? gold,
        fontWeight: weight ?? FontWeight.w700,
        shadows: isRamadan
            ? [Shadow(color: gold.withOpacity(0.3), blurRadius: 10)]
            : null,
      );

  TextStyle naskh(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.notoNaskhArabic(
        fontSize: size,
        color: color ?? text,
        fontWeight: weight ?? FontWeight.w400,
      );
}

// ─────────────────────────────────────────
