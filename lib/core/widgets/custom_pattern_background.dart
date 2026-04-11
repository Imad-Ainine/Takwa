import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muhasabah/core/providers/database_providers.dart';
import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/theme/ramadan_theme.dart';
import 'dart:ui';
import 'background_painters.dart';

enum BackgroundPattern { geometric, stats, duas, adhkar, checklist, qibla }

class CustomPatternBackground extends ConsumerStatefulWidget {
  final BackgroundPattern pattern;
  final double blurAmount;

  const CustomPatternBackground({
    super.key,
    this.pattern = BackgroundPattern.geometric,
    this.blurAmount = 2.0,
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

    if (isRamadan) {
      final brightness = Theme.of(context).brightness;
      return Positioned.fill(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: RamadanBgPainter(
                    animT: _ctrl.value,
                    brightness: brightness,
                  ),
                ),
              ),
            ),
            if (widget.blurAmount > 0)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blurAmount,
                    sigmaY: widget.blurAmount,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        ),
      );
    }

    final colors = context.colors;
    CustomPainter painter;

    switch (widget.pattern) {
      case BackgroundPattern.geometric:
        painter = GeometricPainter(color: colors.gold, blur: 0.5);
        break;
      case BackgroundPattern.stats:
        painter = StatsBgPainter(
          nightColor: colors.background,
          dotColor: colors.border,
        );
        break;
      case BackgroundPattern.duas:
        painter = DuasBgPainter(goldColor: colors.gold, blur: 0.8);
        break;
      case BackgroundPattern.adhkar:
        painter = AdhkarBgPainter(
          nightColor: colors.background,
          goldColor: colors.gold,
        );
        break;
      case BackgroundPattern.checklist:
        painter = SubtleBgPainter(
          nightColor: colors.background,
          goldColor: colors.gold,
        );
        break;
      case BackgroundPattern.qibla:
        painter = QiblaBgPainter(goldColor: colors.gold, blur: 1.0);
        break;
    }

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: painter)),
          if (widget.blurAmount > 0)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blurAmount,
                  sigmaY: widget.blurAmount,
                ),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}
