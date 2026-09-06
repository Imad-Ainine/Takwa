import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────
//  COLOR TOKENS & EXTENSION
// ─────────────────────────────────────────

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color deep;
  final Color card;
  final Color card2;
  final Color border;
  final Color night;

  final Color gold;
  final Color goldLight;
  final Color goldDark;
  final Color goldDim;

  final Color teal;
  final Color tealDim;

  final Color success;
  final Color successDim;
  final Color danger;
  final Color dangerDim;
  final Color warning;

  final Color textPrimary;
  final Color textSecondary;
  final Color textDim;

  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final LinearGradient goldGradient;
  final LinearGradient tealGoldGradient;

  const AppColorsExtension({
    required this.background,
    required this.deep,
    required this.card,
    required this.card2,
    required this.border,
    required this.night,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.goldDim,
    required this.teal,
    required this.tealDim,
    required this.success,
    required this.successDim,
    required this.danger,
    required this.dangerDim,
    required this.warning,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDim,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.goldGradient,
    required this.tealGoldGradient,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith() => this;

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      deep: Color.lerp(deep, other.deep, t)!,
      card: Color.lerp(card, other.card, t)!,
      card2: Color.lerp(card2, other.card2, t)!,
      border: Color.lerp(border, other.border, t)!,
      night: Color.lerp(night, other.night, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      goldDark: Color.lerp(goldDark, other.goldDark, t)!,
      goldDim: Color.lerp(goldDim, other.goldDim, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      tealDim: Color.lerp(tealDim, other.tealDim, t)!,
      success: Color.lerp(success, other.success, t)!,
      successDim: Color.lerp(successDim, other.successDim, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerDim: Color.lerp(dangerDim, other.dangerDim, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      )!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      goldGradient: LinearGradient.lerp(goldGradient, other.goldGradient, t)!,
      tealGoldGradient: LinearGradient.lerp(
        tealGoldGradient,
        other.tealGoldGradient,
        t,
      )!,
    );
  }

  // --- Dark Colors ---
  static const dark = AppColorsExtension(
    background: Color(0xFF04011e),
    deep: Color(0xFF111827),
    card: Color(0xFF1A2332),
    card2: Color(0xFF1E2D40),
    border: Color(0xFF2A3A50),
    night: Color(0xFF0D1117),
    gold: Color(0xFFC8A96E),
    goldLight: Color(0xFFE4C98A),
    goldDark: Color(0xFFB8920E),
    goldDim: Color(0x26C8A96E), // 15% opacity
    teal: Color(0xFF3AAFA9),
    tealDim: Color(0x1F3AAFA9), // 12%
    success: Color(0xFF4CAF7D),
    successDim: Color(0x1F4CAF7D),
    danger: Color(0xFFE07070),
    dangerDim: Color(0x1FE07070),
    warning: Color(0xFFE0A044),
    textPrimary: Color(0xFFE8EDF3),
    textSecondary: Color(0xFF8FA3BB),
    textDim: Color(0xFF4A6070),
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0D1117), Color(0xFF111827), Color(0xFF0D1117)],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x20C8A96E), Color(0x0D3AAFA9)],
    ),
    goldGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE4C98A), Color(0xFFC8A96E), Color(0xFFB8920E)],
    ),
    tealGoldGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3AAFA9), Color(0xFFC8A96E)],
    ),
  );

  // --- Light Colors ---
  static const light = AppColorsExtension(
    background: Color(0xFFF9FAFB),
    deep: Color(0xFFF3F4F6),
    card: Color(0xFFFFFFFF),
    card2: Color(0xFFF3F4F6), // Slightly off-white for filled cards
    border: Color(0xFFE2E8F0),
    night: Color(0xFFF9FAFB),
    gold: Color(0xFFC8A96E), // Gold usually stands well on light too
    goldLight: Color(0xFFE4C98A),
    goldDark: Color(0xFFB8920E),
    goldDim: Color(0x1FC8A96E), // 12% opacity
    teal: Color(0xFF3AAFA9),
    tealDim: Color(0x1F3AAFA9), // 12%
    success: Color(0xFF4CAF7D),
    successDim: Color(0x1F4CAF7D),
    danger: Color(0xFFE07070),
    dangerDim: Color(0x1FE07070),
    warning: Color(0xFFE0A044),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textDim: Color(0xFF6B7280),
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6), Color(0xFFF9FAFB)],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x10C8A96E), Color(0x0A3AAFA9)],
    ),
    goldGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE4C98A), Color(0xFFC8A96E), Color(0xFFB8920E)],
    ),
    tealGoldGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3AAFA9), Color(0xFFC8A96E)],
    ),
  );
}

// Keep AppColors for simple backward compatibility where static const is required,
// but all new and refactored code should use `context.colors`.
// We alias it to Dark mode colors to avoid breaking some unmigrated things immediately.
class AppColors {
  AppColors._();
  static const night = Color(0xFF0D1117);
  static const deep = Color(0xFF111827);
  static const card = Color(0xFF1A2332);
  static const card2 = Color(0xFF1E2D40);
  static const border = Color(0xFF2A3A50);
  static const gold = Color(0xFFC8A96E);
  static const goldLight = Color(0xFFE4C98A);
  static const goldDark = Color(0xFFB8920E);
  static const goldDim = Color(0x26C8A96E);
  static const teal = Color(0xFF3AAFA9);
  static const tealDim = Color(0x1F3AAFA9);
  static const success = Color(0xFF4CAF7D);
  static const successDim = Color(0x1F4CAF7D);
  static const danger = Color(0xFFE07070);
  static const dangerDim = Color(0x1FE07070);
  static const warning = Color(0xFFE0A044);
  static const textPrimary = Color(0xFFE8EDF3);
  static const textSecondary = Color(0xFF8FA3BB);
  static const textDim = Color(0xFF4A6070);
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1117), Color(0xFF111827), Color(0xFF0D1117)],
  );
}

// ─────────────────────────────────────────
//  TYPOGRAPHY EXTENSION
// ─────────────────────────────────────────

class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle headingLarge;
  final TextStyle headingMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle caption;
  final TextStyle quranicVerse;
  final TextStyle taqwaScore;

  const AppTypographyExtension({
    required this.displayLarge,
    required this.displayMedium,
    required this.headingLarge,
    required this.headingMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.caption,
    required this.quranicVerse,
    required this.taqwaScore,
  });

  @override
  ThemeExtension<AppTypographyExtension> copyWith() => this;

  @override
  ThemeExtension<AppTypographyExtension> lerp(
    ThemeExtension<AppTypographyExtension>? other,
    double t,
  ) => this;

  /// [locale] picks the font: Arabic keeps Amiri; English uses Poppins
  /// paired with Tajawal as fallback so Arabic content renders in clean, modern Tajawal.
  static AppTypographyExtension fromColors(
    AppColorsExtension colors, [
    Locale locale = const Locale('ar'),
  ]) {
    final font = appFontFamily(locale);
    final fallback = appFontFamilyFallback(locale);
    return AppTypographyExtension(
      displayLarge: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: colors.gold,
        height: 1.3,
      ),
      displayMedium: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.4,
      ),
      headingLarge: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.4,
      ),
      headingMedium: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.8,
      ),
      bodyMedium: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      ),
      caption: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colors.textDim,
      ),
      quranicVerse: TextStyle(
        // Qur'anic text stays Amiri regardless of UI language — it's
        // Arabic content, not UI chrome. Fallback to Tajawal & NotoNaskhArabic.
        fontFamily: 'Amiri',
        fontFamilyFallback: const ['Tajawal', 'NotoNaskhArabic'],
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: colors.goldLight,
        height: 2.0,
      ),
      taqwaScore: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: colors.gold,
      ),
    );
  }
}

/// The UI font for [locale]: Arabic renders in Amiri; every other
/// locale (English today) uses Poppins. Shared by [AppTypographyExtension],
/// [RamadanTheme]'s text theme, and [AdaptiveStyle]'s `amiri()`/`naskh()`
/// helpers so the choice lives in exactly one place.
String appFontFamily(Locale locale) =>
    locale.languageCode == 'ar' ? 'Amiri' : 'Poppins';

/// The UI body font for [locale]: Arabic keeps NotoNaskhArabic
/// (better long-run Arabic body legibility than Amiri); English uses
/// Poppins, same as [appFontFamily].
String appBodyFontFamily(Locale locale) =>
    locale.languageCode == 'ar' ? 'NotoNaskhArabic' : 'Poppins';

/// Fallback fonts: When locale is English, Poppins is paired with Tajawal so that
/// any Arabic text (Quranic quotes, Dhikr, book titles, untranslated content)
/// renders in clean, modern Tajawal font instead of harsh system fallbacks.
List<String> appFontFamilyFallback(Locale locale) =>
    const ['Tajawal', 'NotoNaskhArabic', 'Amiri'];

// ─────────────────────────────────────────
//  DECORATIONS & SHADOWS EXTENSIONS
// ─────────────────────────────────────────

class AppDecorationsExtension extends ThemeExtension<AppDecorationsExtension> {
  final BoxDecoration card;
  final BoxDecoration goldCard;
  final BoxDecoration tealCard;
  final BoxDecoration successRow;
  final BoxDecoration dangerRow;
  final BoxDecoration appBackground;

  const AppDecorationsExtension({
    required this.card,
    required this.goldCard,
    required this.tealCard,
    required this.successRow,
    required this.dangerRow,
    required this.appBackground,
  });

  @override
  ThemeExtension<AppDecorationsExtension> copyWith() => this;

  @override
  ThemeExtension<AppDecorationsExtension> lerp(
    ThemeExtension<AppDecorationsExtension>? other,
    double t,
  ) => this;

  static AppDecorationsExtension fromColors(
    AppColorsExtension colors,
    AppShadowsExtension shadows,
  ) {
    return AppDecorationsExtension(
      card: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.border),
      ),
      goldCard: BoxDecoration(
        gradient: colors.cardGradient,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.gold.withOpacity(0.2)),
        boxShadow: shadows.goldGlow,
      ),
      tealCard: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.teal.withOpacity(0.25)),
      ),
      successRow: BoxDecoration(
        color: colors.successDim,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.success.withOpacity(0.25)),
      ),
      dangerRow: BoxDecoration(
        color: colors.dangerDim,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.danger.withOpacity(0.2)),
      ),
      appBackground: BoxDecoration(gradient: colors.backgroundGradient),
    );
  }
}

class AppShadowsExtension extends ThemeExtension<AppShadowsExtension> {
  final List<BoxShadow> card;
  final List<BoxShadow> goldGlow;
  final List<BoxShadow> tealGlow;

  const AppShadowsExtension({
    required this.card,
    required this.goldGlow,
    required this.tealGlow,
  });

  @override
  ThemeExtension<AppShadowsExtension> copyWith() => this;

  @override
  ThemeExtension<AppShadowsExtension> lerp(
    ThemeExtension<AppShadowsExtension>? other,
    double t,
  ) => this;

  static AppShadowsExtension fromColors(AppColorsExtension colors) {
    // Determine if it is light mode based on background luminance
    final isLight = colors.background.computeLuminance() > 0.5;
    return AppShadowsExtension(
      card: [
        BoxShadow(
          color: isLight
              ? Colors.black.withOpacity(0.05)
              : Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      goldGlow: [
        BoxShadow(
          color: colors.gold.withOpacity(isLight ? 0.15 : 0.25),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
      tealGlow: [
        BoxShadow(
          color: colors.teal.withOpacity(isLight ? 0.1 : 0.2),
          blurRadius: 16,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  CONTEXT EXTENSION HELPERS
// ─────────────────────────────────────────

extension ThemeContextExt on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
  AppTypographyExtension get typography =>
      Theme.of(this).extension<AppTypographyExtension>()!;
  AppDecorationsExtension get decorations =>
      Theme.of(this).extension<AppDecorationsExtension>()!;
  AppShadowsExtension get shadows =>
      Theme.of(this).extension<AppShadowsExtension>()!;
}

// ─────────────────────────────────────────
//  SPACING & RADIUS TOKENS
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
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
}

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
//  MAIN THEME DEFINITIONS
// ─────────────────────────────────────────

class AppTheme {
  AppTheme._();

  /// [locale] defaults to Arabic, matching this app's default UI language
  /// and keeping every existing no-argument call site (there shouldn't be
  /// any left, but this is a cheap safety net) behaving exactly as before.
  static ThemeData dark([Locale locale = const Locale('ar')]) {
    const colors = AppColorsExtension.dark;
    final typography = AppTypographyExtension.fromColors(colors, locale);
    final shadows = AppShadowsExtension.fromColors(colors);
    final decorations = AppDecorationsExtension.fromColors(colors, shadows);

    return _buildTheme(
      Brightness.dark,
      colors,
      typography,
      shadows,
      decorations,
      locale,
    );
  }

  static ThemeData light([Locale locale = const Locale('ar')]) {
    const colors = AppColorsExtension.light;
    final typography = AppTypographyExtension.fromColors(colors, locale);
    final shadows = AppShadowsExtension.fromColors(colors);
    final decorations = AppDecorationsExtension.fromColors(colors, shadows);

    return _buildTheme(
      Brightness.light,
      colors,
      typography,
      shadows,
      decorations,
      locale,
    );
  }

  static ThemeData _buildTheme(
    Brightness brightness,
    AppColorsExtension colors,
    AppTypographyExtension typography,
    AppShadowsExtension shadows,
    AppDecorationsExtension decorations,
    Locale locale,
  ) {
    final mainFont = appFontFamily(locale);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: mainFont,
      textTheme: TextTheme(
        displayLarge: typography.displayLarge,
        displayMedium: typography.displayMedium,
        headlineLarge: typography.headingLarge,
        headlineMedium: typography.headingMedium,
        headlineSmall: typography.headingMedium.copyWith(fontSize: 18),
        titleLarge: typography.headingMedium.copyWith(fontSize: 16),
        titleMedium: typography.labelLarge,
        titleSmall: typography.labelMedium,
        bodyLarge: typography.bodyLarge,
        bodyMedium: typography.bodyMedium,
        bodySmall: typography.bodySmall,
        labelLarge: typography.labelLarge,
        labelMedium: typography.labelMedium,
        labelSmall: typography.caption,
      ),
      extensions: [colors, typography, shadows, decorations],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.gold,
        onPrimary: colors.background,
        secondary: colors.teal,
        onSecondary: colors.background,
        surface: colors.card,
        onSurface: colors.textPrimary,
        error: colors.danger,
        onError: Colors.white,
        outline: colors.border,
        primaryContainer: colors.goldDim,
        secondaryContainer: colors.tealDim,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        // Removes the shadow/elevation for all AppBars
        scrolledUnderElevation: 0.0,
        // Removes the color tint highlight for all AppBars
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.deep,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typography.headingMedium,
        iconTheme: IconThemeData(color: colors.gold),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: colors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.card,
        selectedItemColor: colors.gold,
        unselectedItemColor: colors.textDim,
        elevation: 0,
        selectedLabelStyle: typography.caption.copyWith(color: colors.gold),
        unselectedLabelStyle: typography.caption,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.card,
        indicatorColor: colors.goldDim,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.gold, size: 24);
          }
          return IconThemeData(color: colors.textDim, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return typography.caption.copyWith(color: colors.gold);
          }
          return typography.caption;
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.gold,
          foregroundColor: colors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: typography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.gold,
          side: BorderSide(color: colors.gold, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: typography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.teal,
          textStyle: typography.labelMedium.copyWith(color: colors.teal),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.success;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: colors.border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return colors.textDim;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.success;
          return colors.border;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.gold, width: 1.5),
        ),
        hintStyle: typography.bodyMedium.copyWith(color: colors.textDim),
        labelStyle: typography.labelMedium,
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.card,
        side: BorderSide(color: colors.border),
        labelStyle: typography.labelMedium,
        padding: AppSpacing.chipPadding,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.gold,
        linearTrackColor: colors.border,
        circularTrackColor: colors.border,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.gold,
        inactiveTrackColor: colors.border,
        thumbColor: colors.gold,
        overlayColor: colors.goldDim,
      ),
      tabBarTheme: TabBarThemeData(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: colors.gold,
        unselectedLabelColor: colors.textDim,
        indicatorColor: colors.gold,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: typography.labelLarge,
        unselectedLabelStyle: typography.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: colors.border),
        ),
        titleTextStyle: typography.headingMedium,
        contentTextStyle: typography.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.card2,
        contentTextStyle: typography.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─────────────────────────────────────────
//  COMMON WIDGET STYLES
// ─────────────────────────────────────────

class TaqwaBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? bgColor;

  const TaqwaBadge({super.key, required this.label, this.color, this.bgColor});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.gold;
    final bg = bgColor ?? context.colors.goldDim;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.chip,
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(label, style: context.typography.caption.copyWith(color: c)),
    );
  }
}

class StreakBadge extends StatelessWidget {
  final int days;
  const StreakBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.successDim,
        borderRadius: AppRadius.chip,
        border: Border.all(color: context.colors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$days يوم متواصل',
            style: context.typography.caption.copyWith(
              color: context.colors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const SectionLabel({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.teal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: context.typography.caption.copyWith(color: c)),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: c.withOpacity(0.2))),
        ],
      ),
    );
  }
}
