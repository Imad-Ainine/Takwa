import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muhasabah/core/providers/database_providers.dart';
import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/theme/ramadan_theme.dart';
import 'background_painters.dart';

enum BackgroundPattern { geometric, stats, duas, adhkar, checklist, qibla }

class CustomPatternBackground extends ConsumerStatefulWidget {
  final BackgroundPattern pattern;

  const CustomPatternBackground({
    super.key,
    this.pattern = BackgroundPattern.geometric,
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
      return Positioned.fill(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) =>
              CustomPaint(painter: RamadanBgPainter(animT: _ctrl.value)),
        ),
      );
    }

    final colors = context.colors;
    CustomPainter painter;

    switch (widget.pattern) {
      case BackgroundPattern.geometric:
        painter = GeometricPainter(color: colors.gold);
        break;
      case BackgroundPattern.stats:
        painter = StatsBgPainter(
          nightColor: colors.background,
          dotColor: colors.border,
        );
        break;
      case BackgroundPattern.duas:
        painter = DuasBgPainter(goldColor: colors.gold);
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
        painter = QiblaBgPainter(goldColor: colors.gold);
        break;
    }

    return Positioned.fill(child: CustomPaint(painter: painter));
  }
}
