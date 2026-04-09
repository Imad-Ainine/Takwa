// ═══════════════════════════════════════════════════════════════
//  lib/core/theme/app_theme.dart
//  محاسبة النفس — Complete Design System
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────
//  COLOR TOKENS
// ─────────────────────────────────────────
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color night = Color(0xFF0D1117);
  static const Color deep = Color(0xFF111827);
  static const Color card = Color(0xFF1A2332);
  static const Color card2 = Color(0xFF1E2D40);
  static const Color border = Color(0xFF2A3A50);

  // Brand — Gold
  static const Color gold = Color(0xFFC8A96E);
  static const Color goldLight = Color(0xFFE4C98A);
  static const Color goldDark = Color(0xFFB8920E);
  static const Color goldDim = Color(0x26C8A96E); // 15% opacity

  // Brand — Teal
  static const Color teal = Color(0xFF3AAFA9);
  static const Color tealDim = Color(0x1F3AAFA9); // 12%

  // Semantic
  static const Color success = Color(0xFF4CAF7D);
  static const Color successDim = Color(0x1F4CAF7D);
  static const Color danger = Color(0xFFE07070);
  static const Color dangerDim = Color(0x1FE07070);
  static const Color warning = Color(0xFFE0A044);

  // Text
  static const Color textPrimary = Color(0xFFE8EDF3);
  static const Color textSecondary = Color(0xFF8FA3BB);
  static const Color textDim = Color(0xFF4A6070);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, Color(0xFFB8920E)],
  );

  static const LinearGradient tealGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, gold],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [night, deep, night],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x20C8A96E), Color(0x0D3AAFA9)],
  );
}

// ─────────────────────────────────────────
//  TYPOGRAPHY TOKENS
// ─────────────────────────────────────────
class AppTypography {
  AppTypography._();

  // Amiri for headings & decorative Arabic text
  static TextStyle get displayLarge => GoogleFonts.amiri(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        height: 1.3,
      );

  static TextStyle get displayMedium => GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get headingLarge => GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get headingMedium => GoogleFonts.amiri(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Noto Naskh Arabic for body text
  static TextStyle get bodyLarge => GoogleFonts.notoNaskhArabic(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.8,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoNaskhArabic(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle get bodySmall => GoogleFonts.notoNaskhArabic(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.notoNaskhArabic(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.notoNaskhArabic(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.notoNaskhArabic(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textDim,
      );

  static TextStyle get quranicVerse => GoogleFonts.amiri(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: AppColors.goldLight,
        height: 2.0,
      );

  static TextStyle get taqwaScore => GoogleFonts.notoNaskhArabic(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
      );
}

// ─────────────────────────────────────────
//  SPACING TOKENS
// ─────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets chipPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 6);
}

// ─────────────────────────────────────────
//  BORDER RADIUS TOKENS
// ─────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 100.0;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(full);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get input => BorderRadius.circular(md);
}

// ─────────────────────────────────────────
//  SHADOW TOKENS
// ─────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: AppColors.gold.withOpacity(0.25),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get tealGlow => [
        BoxShadow(
          color: AppColors.teal.withOpacity(0.2),
          blurRadius: 16,
        ),
      ];
}

// ─────────────────────────────────────────
//  MAIN THEME
// ─────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          onPrimary: AppColors.night,
          secondary: AppColors.teal,
          onSecondary: AppColors.night,
          surface: AppColors.card,
          onSurface: AppColors.textPrimary,
          error: AppColors.danger,
          outline: AppColors.border,
          primaryContainer: AppColors.goldDim,
          secondaryContainer: AppColors.tealDim,
        ),

        scaffoldBackgroundColor: AppColors.night,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.deep,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.headingMedium,
          iconTheme: const IconThemeData(color: AppColors.gold),
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.textDim,
          elevation: 0,
          selectedLabelStyle:
              AppTypography.caption.copyWith(color: AppColors.gold),
          unselectedLabelStyle: AppTypography.caption,
        ),

        // NavigationBar (Material 3)
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.card,
          indicatorColor: AppColors.goldDim,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.gold, size: 24);
            }
            return const IconThemeData(color: AppColors.textDim, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.caption.copyWith(color: AppColors.gold);
            }
            return AppTypography.caption;
          }),
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.night,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.night,
            ),
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: const BorderSide(color: AppColors.gold, width: 1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.teal,
            textStyle:
                AppTypography.labelMedium.copyWith(color: AppColors.teal),
          ),
        ),

        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.success;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: const BorderSide(color: AppColors.border, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.textDim;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.success;
            return AppColors.border;
          }),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card2,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
          hintStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.textDim),
          labelStyle: AppTypography.labelMedium,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.card,
          side: const BorderSide(color: AppColors.border),
          labelStyle: AppTypography.labelMedium,
          padding: AppSpacing.chipPadding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        ),

        // Progress Indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.gold,
          linearTrackColor: AppColors.border,
          circularTrackColor: AppColors.border,
        ),

        // Slider
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.gold,
          inactiveTrackColor: AppColors.border,
          thumbColor: AppColors.gold,
          overlayColor: AppColors.goldDim,
        ),

        // Tab Bar
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textDim,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTypography.labelLarge,
          unselectedLabelStyle: AppTypography.labelMedium,
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: const BorderSide(color: AppColors.border),
          ),
          titleTextStyle: AppTypography.headingMedium,
          contentTextStyle: AppTypography.bodyMedium,
        ),

        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.card2,
          contentTextStyle: AppTypography.bodyMedium,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          behavior: SnackBarBehavior.floating,
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          headlineLarge: AppTypography.headingLarge,
          headlineMedium: AppTypography.headingMedium,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.caption,
        ),
      );
}

// ─────────────────────────────────────────
//  REUSABLE DECORATION HELPERS
// ─────────────────────────────────────────
class AppDecorations {
  AppDecorations._();

  /// Standard dark card
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      );

  /// Glowing gold card (for highlights)
  static BoxDecoration get goldCard => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x20C8A96E), Color(0x0D3AAFA9)],
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        boxShadow: AppShadows.goldGlow,
      );

  /// Teal-accented card
  static BoxDecoration get tealCard => BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.teal.withOpacity(0.25)),
      );

  /// Success (done) row
  static BoxDecoration get successRow => BoxDecoration(
        color: AppColors.successDim,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      );

  /// Danger row
  static BoxDecoration get dangerRow => BoxDecoration(
        color: AppColors.dangerDim,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
      );

  /// Background with geometric overlay
  static BoxDecoration get appBackground => const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      );
}

// ─────────────────────────────────────────
//  COMMON WIDGET STYLES
// ─────────────────────────────────────────

/// Gold badge / pill
class TaqwaBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? bgColor;

  const TaqwaBadge({
    super.key,
    required this.label,
    this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.gold;
    final bg = bgColor ?? AppColors.goldDim;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.chip,
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: c),
      ),
    );
  }
}

/// Streak fire badge
class StreakBadge extends StatelessWidget {
  final int days;
  const StreakBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successDim,
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$days يوم متواصل',
            style: AppTypography.caption.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

/// Section divider with label
class SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const SectionLabel({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: c),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 1, color: c.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}
