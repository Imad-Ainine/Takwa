import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
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

  // ── On-surface accent ramp ──
  // `gold`/`teal`/`success`/`warning`/`danger` above are FILL colors: they are
  // tuned to sit *behind* content. Using them as foregrounds on a light surface
  // fails WCAG badly (gold on white is 2.24:1). These `*Text` roles are the
  // same hues darkened until they clear AA (>=4.5:1) on the light surfaces, and
  // in dark mode they simply alias the bright fills, which already pass there.
  // Rule of thumb: filling a shape -> use `gold`; drawing text or an icon on a
  // theme surface -> use `goldText`.
  final Color goldText;
  final Color tealText;
  final Color successText;
  final Color warningText;
  final Color dangerText;

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
    required this.goldText,
    required this.tealText,
    required this.successText,
    required this.warningText,
    required this.dangerText,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDim,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.goldGradient,
    required this.tealGoldGradient,
  });

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? deep,
    Color? card,
    Color? card2,
    Color? border,
    Color? night,
    Color? gold,
    Color? goldLight,
    Color? goldDark,
    Color? goldDim,
    Color? teal,
    Color? tealDim,
    Color? success,
    Color? successDim,
    Color? danger,
    Color? dangerDim,
    Color? warning,
    Color? goldText,
    Color? tealText,
    Color? successText,
    Color? warningText,
    Color? dangerText,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDim,
    LinearGradient? backgroundGradient,
    LinearGradient? cardGradient,
    LinearGradient? goldGradient,
    LinearGradient? tealGoldGradient,
  }) => AppColorsExtension(
    background: background ?? this.background,
    deep: deep ?? this.deep,
    card: card ?? this.card,
    card2: card2 ?? this.card2,
    border: border ?? this.border,
    night: night ?? this.night,
    gold: gold ?? this.gold,
    goldLight: goldLight ?? this.goldLight,
    goldDark: goldDark ?? this.goldDark,
    goldDim: goldDim ?? this.goldDim,
    teal: teal ?? this.teal,
    tealDim: tealDim ?? this.tealDim,
    success: success ?? this.success,
    successDim: successDim ?? this.successDim,
    danger: danger ?? this.danger,
    dangerDim: dangerDim ?? this.dangerDim,
    warning: warning ?? this.warning,
    goldText: goldText ?? this.goldText,
    tealText: tealText ?? this.tealText,
    successText: successText ?? this.successText,
    warningText: warningText ?? this.warningText,
    dangerText: dangerText ?? this.dangerText,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textDim: textDim ?? this.textDim,
    backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    cardGradient: cardGradient ?? this.cardGradient,
    goldGradient: goldGradient ?? this.goldGradient,
    tealGoldGradient: tealGoldGradient ?? this.tealGoldGradient,
  );

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
      goldText: Color.lerp(goldText, other.goldText, t)!,
      tealText: Color.lerp(tealText, other.tealText, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
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
    // On dark surfaces the bright fills already clear AA as foregrounds
    // (>=5:1 on `card`), so the on-surface ramp aliases them.
    goldText: Color(0xFFC8A96E),
    tealText: Color(0xFF3AAFA9),
    successText: Color(0xFF4CAF7D),
    warningText: Color(0xFFE0A044),
    dangerText: Color(0xFFE07070),
    textPrimary: Color(0xFFE8EDF3),
    textSecondary: Color(0xFF8FA3BB),
    // Was 0xFF4A6070 — only 2.40:1 on `card`, i.e. failing AA everywhere it
    // was used as text (nav labels, captions, chevrons). 0xFF8299B2 clears
    // 4.5:1 on card / card2 / background / deep.
    textDim: Color(0xFF8299B2),
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
    // Darkened hues so accents are legible as text/icons on white & near-white.
    goldText: Color(0xFF6B5320), // 7.28:1 on #FFFFFF (fill gold was 2.24:1)
    tealText: Color(0xFF0F5C57), // 7.81:1 (fill teal was 2.66:1)
    successText: Color(0xFF197045), // 6.10:1 (fill success was 2.71:1)
    warningText: Color(0xFF7A5210), // 6.90:1 (fill warning was 2.26:1)
    dangerText: Color(0xFFA81E17), // 7.33:1 (fill danger was 3.12:1)
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
  AppTypographyExtension copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? headingLarge,
    TextStyle? headingMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? caption,
    TextStyle? quranicVerse,
    TextStyle? taqwaScore,
  }) => AppTypographyExtension(
    displayLarge: displayLarge ?? this.displayLarge,
    displayMedium: displayMedium ?? this.displayMedium,
    headingLarge: headingLarge ?? this.headingLarge,
    headingMedium: headingMedium ?? this.headingMedium,
    bodyLarge: bodyLarge ?? this.bodyLarge,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    bodySmall: bodySmall ?? this.bodySmall,
    labelLarge: labelLarge ?? this.labelLarge,
    labelMedium: labelMedium ?? this.labelMedium,
    caption: caption ?? this.caption,
    quranicVerse: quranicVerse ?? this.quranicVerse,
    taqwaScore: taqwaScore ?? this.taqwaScore,
  );

  @override
  ThemeExtension<AppTypographyExtension> lerp(
    ThemeExtension<AppTypographyExtension>? other,
    double t,
  ) {
    if (other is! AppTypographyExtension) return this;
    return AppTypographyExtension(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      headingLarge: TextStyle.lerp(headingLarge, other.headingLarge, t)!,
      headingMedium: TextStyle.lerp(headingMedium, other.headingMedium, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      quranicVerse: TextStyle.lerp(quranicVerse, other.quranicVerse, t)!,
      taqwaScore: TextStyle.lerp(taqwaScore, other.taqwaScore, t)!,
    );
  }

  /// [locale] picks the font: Arabic keeps Amiri; English uses Poppins
  /// paired with Tajawal as fallback so Arabic content renders in clean, modern Tajawal.
  // This scale used to run 13-40px with no consistent step, and bodyLarge
  // (20px) / bodyMedium (18px) / bodySmall (16px) were themselves sized like
  // headings — "display sizes masquerading as body" — which is why ~46
  // call sites across the app resorted to a raw `.copyWith(fontSize: 11)`
  // or similar just to get an actually-body-sized body. It also silently
  // diverged from RamadanTheme's own separately hand-built TextTheme (see
  // that class before it was collapsed into this one), so the two disagreed
  // on every role's size by 2-6px. Rebuilt as one 12-32px scale with a
  // 12px floor — nothing in UI chrome renders smaller than that — and each
  // role's line-height tuned for its size rather than left unset.
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
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.gold,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.3,
      ),
      headingLarge: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.3,
      ),
      headingMedium: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.35,
      ),
      bodyLarge: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
        height: 1.4,
      ),
      caption: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.textDim,
        height: 1.35,
      ),
      quranicVerse: TextStyle(
        // Qur'anic text stays Amiri regardless of UI language — it's
        // Arabic content, not UI chrome. Fallback to Tajawal & NotoNaskhArabic.
        // Kept distinctly large — this is read-aloud recitation text, not
        // chrome, so it doesn't follow the 32px display ceiling above.
        fontFamily: 'Amiri',
        fontFamilyFallback: const ['Tajawal', 'NotoNaskhArabic'],
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: colors.goldLight,
        height: 2.0,
      ),
      taqwaScore: TextStyle(
        fontFamily: font,
        fontFamilyFallback: fallback,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: colors.gold,
        height: 1.1,
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
  AppDecorationsExtension copyWith({
    BoxDecoration? card,
    BoxDecoration? goldCard,
    BoxDecoration? tealCard,
    BoxDecoration? successRow,
    BoxDecoration? dangerRow,
    BoxDecoration? appBackground,
  }) => AppDecorationsExtension(
    card: card ?? this.card,
    goldCard: goldCard ?? this.goldCard,
    tealCard: tealCard ?? this.tealCard,
    successRow: successRow ?? this.successRow,
    dangerRow: dangerRow ?? this.dangerRow,
    appBackground: appBackground ?? this.appBackground,
  );

  @override
  ThemeExtension<AppDecorationsExtension> lerp(
    ThemeExtension<AppDecorationsExtension>? other,
    double t,
  ) {
    if (other is! AppDecorationsExtension) return this;
    return AppDecorationsExtension(
      card: BoxDecoration.lerp(card, other.card, t)!,
      goldCard: BoxDecoration.lerp(goldCard, other.goldCard, t)!,
      tealCard: BoxDecoration.lerp(tealCard, other.tealCard, t)!,
      successRow: BoxDecoration.lerp(successRow, other.successRow, t)!,
      dangerRow: BoxDecoration.lerp(dangerRow, other.dangerRow, t)!,
      appBackground: BoxDecoration.lerp(appBackground, other.appBackground, t)!,
    );
  }

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
        border: Border.all(color: colors.gold.withValues(alpha: 0.2)),
        boxShadow: shadows.goldGlow,
      ),
      tealCard: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.teal.withValues(alpha: 0.25)),
      ),
      successRow: BoxDecoration(
        color: colors.successDim,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.success.withValues(alpha: 0.25)),
      ),
      dangerRow: BoxDecoration(
        color: colors.dangerDim,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.danger.withValues(alpha: 0.2)),
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
  AppShadowsExtension copyWith({
    List<BoxShadow>? card,
    List<BoxShadow>? goldGlow,
    List<BoxShadow>? tealGlow,
  }) => AppShadowsExtension(
    card: card ?? this.card,
    goldGlow: goldGlow ?? this.goldGlow,
    tealGlow: tealGlow ?? this.tealGlow,
  );

  @override
  ThemeExtension<AppShadowsExtension> lerp(
    ThemeExtension<AppShadowsExtension>? other,
    double t,
  ) {
    if (other is! AppShadowsExtension) return this;
    return AppShadowsExtension(
      card: _lerpShadowList(card, other.card, t),
      goldGlow: _lerpShadowList(goldGlow, other.goldGlow, t),
      tealGlow: _lerpShadowList(tealGlow, other.tealGlow, t),
    );
  }

  // Every shadow list this theme produces is a single BoxShadow, but this
  // doesn't assume that: it zips up to the shorter of the two lists via
  // BoxShadow.lerp per element, rather than crashing or assuming equal
  // length.
  static List<BoxShadow> _lerpShadowList(
    List<BoxShadow> a,
    List<BoxShadow> b,
    double t,
  ) {
    final len = a.length < b.length ? a.length : b.length;
    return [for (var i = 0; i < len; i++) BoxShadow.lerp(a[i], b[i], t)!];
  }

  static AppShadowsExtension fromColors(AppColorsExtension colors) {
    // Determine if it is light mode based on background luminance
    final isLight = colors.background.computeLuminance() > 0.5;
    return AppShadowsExtension(
      card: [
        BoxShadow(
          color: isLight
              ? Colors.black.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      goldGlow: [
        BoxShadow(
          color: colors.gold.withValues(alpha: isLight ? 0.15 : 0.25),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
      tealGlow: [
        BoxShadow(
          color: colors.teal.withValues(alpha: isLight ? 0.1 : 0.2),
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
//  MOTION TOKENS
// ─────────────────────────────────────────

/// Before this, animation timing was invented per call site — durations
/// scattered across 100/150/180/200/220/250/280/300/350/420/500ms and
/// beyond, chosen ad hoc rather than from a shared scale. These three
/// buckets are drawn from where the actual usage already clustered, not
/// picked arbitrarily: pick the nearest one for new code instead of adding
/// a fourth nearby number.
class AppMotion {
  AppMotion._();

  /// Press/selection feedback, toggle and switch transitions.
  static const Duration fast = Duration(milliseconds: 180);

  /// Card and section enter/exit, most crossfades — the default for
  /// anything that isn't explicitly a quick tap response or a full
  /// page-level transition.
  static const Duration base = Duration(milliseconds: 280);

  /// Page-level transitions, the drawer's open/close.
  static const Duration slow = Duration(milliseconds: 420);

  /// Default easing for the above — a decelerating entrance/settle.
  static const Curve standard = Curves.easeOutCubic;

  /// For transitions that move through a midpoint state (cross-fades,
  /// expand/collapse) rather than settling from one side.
  static const Curve emphasized = Curves.easeInOutCubic;
}

/// Whether [context]'s platform reports the reduce-motion accessibility
/// setting. A named wrapper over MediaQuery.disableAnimationsOf so call
/// sites read as intent ("should this decorative loop run?") rather than a
/// raw platform query repeated at every site.
bool prefersReducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

extension ReducedMotionRepeat on AnimationController {
  /// Starts (or keeps running) an infinite repeat, unless the user has
  /// reduce-motion on — in which case the controller is left at rest at
  /// [restingValue] instead of ticking forever in the background.
  ///
  /// Call this from `didChangeDependencies`, not `initState`: MediaQuery
  /// dependencies are only tracked from the point a widget's build/dependency
  /// methods actually read them, so a call from initState wouldn't notice
  /// the setting being flipped mid-session without an app restart.
  ///
  /// This is for PURELY DECORATIVE, ambient loops — a breathing background
  /// shape, a twinkling starfield — the kind of motion the reduce-motion
  /// setting exists to suppress. Do NOT use it for functional motion (a
  /// loading spinner, a progress ring): those communicate that work is in
  /// progress and stopping them under reduce-motion would remove
  /// information, not just flourish, which is the opposite of what the
  /// setting is for.
  void repeatUnlessReducedMotion(
    BuildContext context, {
    bool reverse = false,
    double restingValue = 0,
    double? min,
    double? max,
    Duration? period,
  }) {
    if (prefersReducedMotion(context)) {
      if (isAnimating) stop();
      value = restingValue;
    } else if (!isAnimating) {
      repeat(reverse: reverse, min: min, max: max, period: period);
    }
  }
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
    return fromColors(AppColorsExtension.dark, Brightness.dark, locale);
  }

  static ThemeData light([Locale locale = const Locale('ar')]) {
    return fromColors(AppColorsExtension.light, Brightness.light, locale);
  }

  /// The shared builder behind [dark]/[light] and, since this was collapsed
  /// in Phase 3, `RamadanTheme.dark`/`RamadanTheme.light` too — those used to
  /// hand-roll a second, ~200-line `ThemeData` with only 6 of the 17
  /// component themes built here, and its own type scale that silently
  /// disagreed with this one on every role's size by 2-6px. Exposed publicly
  /// (rather than staying the private `_buildTheme`) because Dart's
  /// underscore privacy is per-file, not per-package: `ramadan_theme.dart`
  /// cannot reach a leading-underscore member here even though it imports
  /// this file.
  ///
  /// [appBarBackground] overrides the default opaque `colors.deep` app bar
  /// fill. RamadanTheme passes `Colors.transparent` so its animated
  /// background painter shows through behind the app bar — the one piece of
  /// intentional divergence from the base theme this collapse preserves.
  static ThemeData fromColors(
    AppColorsExtension colors,
    Brightness brightness, [
    Locale locale = const Locale('ar'),
    Color? appBarBackground,
  ]) {
    final typography = AppTypographyExtension.fromColors(colors, locale);
    final shadows = AppShadowsExtension.fromColors(colors);
    final decorations = AppDecorationsExtension.fromColors(colors, shadows);

    return _buildTheme(
      brightness,
      colors,
      typography,
      shadows,
      decorations,
      locale,
      appBarBackground,
    );
  }

  static ThemeData _buildTheme(
    Brightness brightness,
    AppColorsExtension colors,
    AppTypographyExtension typography,
    AppShadowsExtension shadows,
    AppDecorationsExtension decorations,
    Locale locale, [
    Color? appBarBackground,
  ]) {
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
        // NOT colors.background: in light mode that put #F9FAFB on gold
        // (2.15:1) on every ElevatedButton. This near-black clears 7.5:1 on
        // `gold` and 5.8:1 on `goldDark`, so it also works on the gold
        // gradient PrimaryButton paints.
        onPrimary: const Color(0xFF241B05),
        secondary: colors.teal,
        onSecondary: brightness == Brightness.dark
            ? colors.background
            : Colors.white,
        surface: colors.card,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        error: brightness == Brightness.dark
            ? colors.danger
            : colors.dangerText,
        onError: Colors.white,
        outline: colors.border,
        primaryContainer: colors.goldDim,
        onPrimaryContainer: colors.goldText,
        secondaryContainer: colors.tealDim,
        onSecondaryContainer: colors.tealText,
        tertiary: colors.success,
        onTertiary: Colors.white,
        // Explicit container ramp: unset M3 roles fall back to the baseline
        // (purple-tinted) scheme, which clashes with this palette on any
        // stock component — NavigationBar, SearchBar, Badge, DatePicker.
        surfaceContainerLowest: colors.background,
        surfaceContainerLow: colors.deep,
        surfaceContainer: colors.card,
        surfaceContainerHigh: colors.card2,
        surfaceContainerHighest: colors.card2,
        outlineVariant: colors.border,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: colors.textPrimary,
        onInverseSurface: colors.background,
        surfaceTint: Colors.transparent,
        // The remaining M3 roles this scheme was missing — same motivation
        // as the container ramp above: any adopted component that reaches
        // for these (error banners/M3 SnackBar actions/FilledButton.tonal
        // with a tertiary scheme) would otherwise fall back to baseline
        // purple. Mapped onto existing tokens rather than inventing new
        // ones: error/tertiary containers reuse the "Dim"/"Text" pairs the
        // fill ramp already has, inversePrimary is a saturated gold that
        // reads on the (light-in-dark-mode) inverseSurface, and
        // surfaceDim/surfaceBright extend the existing surface-container
        // ramp one step past its current ends.
        errorContainer: colors.dangerDim,
        onErrorContainer: colors.dangerText,
        tertiaryContainer: colors.successDim,
        onTertiaryContainer: colors.successText,
        inversePrimary: colors.goldDark,
        surfaceDim: colors.night,
        surfaceBright: colors.card2,
      ),
      // Was on stock platform transitions across all ~55 routes. One shared,
      // platform-appropriate transition instead of the default M3 fade for
      // Android and iOS's native slide.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        // Removes the shadow/elevation for all AppBars
        scrolledUnderElevation: 0.0,
        // Removes the color tint highlight for all AppBars
        surfaceTintColor: Colors.transparent,
        backgroundColor: appBarBackground ?? colors.deep,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typography.headingMedium,
        iconTheme: IconThemeData(color: colors.goldText),
        // Spelled out rather than using the SystemUiOverlayStyle.light/.dark
        // presets: those carry systemNavigationBarColor: black, which would
        // fight the theme-derived nav bar set in TakwaApp.builder wherever an
        // AppBar is present.
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness, // iOS: inverse convention
          systemNavigationBarColor: colors.background,
          systemNavigationBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
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
        selectedItemColor: colors.goldText,
        unselectedItemColor: colors.textDim,
        elevation: 0,
        selectedLabelStyle: typography.caption.copyWith(color: colors.goldText),
        unselectedLabelStyle: typography.caption,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.card,
        indicatorColor: colors.goldDim,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.goldText, size: 24);
          }
          return IconThemeData(color: colors.textDim, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return typography.caption.copyWith(color: colors.goldText);
          }
          return typography.caption;
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.gold,
          // Was colors.background — 2.15:1 in light mode.
          foregroundColor: const Color(0xFF241B05),
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
          foregroundColor: colors.goldText,
          side: BorderSide(color: colors.goldText, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: typography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.tealText,
          textStyle: typography.labelMedium.copyWith(color: colors.tealText),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.successText;
          }
          return Colors.transparent;
        }),
        // White on the successText fill is 6.10:1; on the lighter `success`
        // fill it was only 2.71:1.
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
          if (states.contains(WidgetState.selected)) return colors.successText;
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
          borderSide: BorderSide(color: colors.goldText, width: 1.5),
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
        color: colors.goldText,
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
        labelColor: colors.goldText,
        unselectedLabelColor: colors.textDim,
        indicatorColor: colors.goldText,
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
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: context.typography.caption.copyWith(color: c)),
    );
  }
}

/// takwa_ui has no localizations of its own, so the caller passes the already
/// localized text (e.g. `l10n.homeStreakDaysLabel(days)`) rather than this
/// package hardcoding one language.
class StreakBadge extends StatelessWidget {
  final String label;
  const StreakBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.successDim,
        borderRadius: AppRadius.chip,
        border: Border.all(color: context.colors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.typography.caption.copyWith(
              color: context.colors.successText,
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
          Expanded(child: Container(height: 1, color: c.withValues(alpha: 0.2))),
        ],
      ),
    );
  }
}
