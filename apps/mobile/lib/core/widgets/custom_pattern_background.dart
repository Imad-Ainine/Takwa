import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'background_painters.dart';

// Was 41 variants (§M15) — GeometricPainter, DuasBgPainter, AsmaBgPainter,
// pattern1-18, and P02-P18 were declared, painted, and switched on below,
// but auditing every CustomPatternBackground(pattern: ...) call site in the
// app found none of them actually used anywhere: every screen reaches for
// `adhkar` except the Qibla screen (`qibla`) and the Misbaha counter's accent
// (`twelveFoldStar`). Curated down to those three real ones; see
// background_painters.dart for where the other 38 painter classes went.
enum BackgroundPattern {
  /// The app-wide default — used on nearly every screen.
  adhkar,

  /// The Qibla compass screen's background.
  qibla,

  /// P01 · 12-fold star on hexagonal grid (Moroccan / Andalusian) — the
  /// Misbaha counter's accent pattern.
  twelveFoldStar,
}

class CustomPatternBackground extends ConsumerStatefulWidget {
  final BackgroundPattern pattern;
  final Color? color;
  final double? opacity;

  const CustomPatternBackground({
    super.key,
    this.pattern = BackgroundPattern.adhkar,
    this.color,
    this.opacity,
  });

  @override
  ConsumerState<CustomPatternBackground> createState() =>
      _CustomPatternBackgroundState();
}

class _CustomPatternBackgroundState
    extends ConsumerState<CustomPatternBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    // This drives a purely decorative starfield twinkle + lantern flicker
    // (see RamadanBgPainter) — exactly the ambient motion the platform's
    // reduce-motion setting exists to suppress. The painter still renders
    // its static content at whatever frame the controller is parked on;
    // only the animation itself stops.
    final reduceMotion = prefersReducedMotion(context);

    // Optimization: stop the animation outside Ramadan mode, or when the
    // user prefers reduced motion, to save resources.
    if ((!isRamadan || reduceMotion) && _ctrl.isAnimating) {
      _ctrl.stop();
    } else if (isRamadan && !reduceMotion && !_ctrl.isAnimating) {
      _ctrl.repeat();
    }

    if (isRamadan) {
      final brightness = Theme.of(context).brightness;
      // No AnimatedBuilder here on purpose: RamadanBgPainter is constructed
      // with `repaint: _ctrl` (see its constructor), so the render object
      // calls paint() again on this SAME painter instance every animation
      // tick without rebuilding this subtree or constructing a new painter.
      // That's what lets the painter's internal Picture/star caches (see
      // that class) actually get reused instead of being rebuilt from
      // scratch ~15 times a second.
      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: RamadanBgPainter(
                    animation: _ctrl,
                    brightness: brightness,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    CustomPainter painter;
    final baseColor = widget.color ?? colors.gold;
    // In light mode, use a lower default opacity so the pattern stays subtle.
    final baseOpacity = widget.opacity ?? (isDark ? 0.08 : 0.04);

    switch (widget.pattern) {
      case BackgroundPattern.twelveFoldStar:
        painter = IslamicP01Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.adhkar:
        painter = AdhkarBgPainter(
          goldColor: baseColor,
          nightColor: colors.background,
        );
      case BackgroundPattern.qibla:
        painter = QiblaBgPainter(goldColor: baseColor);
    }

    return SizedBox.expand(
      child: RepaintBoundary(child: CustomPaint(painter: painter)),
    );
  }
}
