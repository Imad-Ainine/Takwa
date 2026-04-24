import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'background_painters.dart';

enum BackgroundPattern {
  geometric,
  duas,
  adhkar,
  qibla,
  asma,
  pattern1,
  pattern2,
  pattern3,
  pattern4,
  pattern5,
  pattern6,
  pattern7,
  pattern8,
  pattern9,
  pattern10,
  pattern11,
  pattern12,
  pattern13,
  pattern14,
  pattern15,
  pattern16,
  pattern17,
  pattern18,

  /// P01 · 12-fold star on hexagonal grid (Moroccan / Andalusian)
  twelveFoldStar,

  /// P02 · 8-pt star with square-cross fillers (Girih tile style)
  eightWithCrosses,

  /// P03 · Dense close-packed 8-pt stars
  denseEightStar,

  /// P04 · 8-pt star with curved petal / arc interlace
  curvedPetals,

  /// P05 · 10-fold decagonal star with pentagon fillers
  tenFoldStar,

  /// P06 · 8-pt star cluster with satellite diamond motifs
  starCluster,

  /// P07 · Floral rosette — 6-petal flowers on hexagonal grid
  floralRosette,

  /// P08 · Diamond interlace weave — offset rhombus grid
  diamondWeave,

  /// P09 · Chain-mail lattice — octagon + square tessellation
  chainLattice,

  /// P10 · Organic lattice — 6-pt star with bulging arc connectors
  organicLattice,

  /// P11 · Arrow-kite star — 8 angular kite motifs around a centre
  arrowKite,

  /// P12 · Micro dense stars — small 8-pt grid with square fillers
  microStar,

  /// P13 · Elongated star — stretched 8-pt with rectangular bands
  elongatedStar,

  /// P14 · Crystal facets — cut-gem rhombus / hexagon pattern
  crystalFacets,

  /// P15 · Kaleidoscope — nested 12-pt rings with fine radial spokes
  kaleidoscope,

  /// P16 · Kite-leaf star — curved kite petals, Arabesque style
  kiteLeaf,

  /// P17 · Multi-ring weave — segmented concentric rings + spokes
  multiRing,

  /// P18 · Polygon mosaic — hexagons with outward triangle satellites
  polygonMosaic,
}

class CustomPatternBackground extends ConsumerStatefulWidget {
  final BackgroundPattern pattern;
  final Color? color;
  final double? opacity;

  const CustomPatternBackground({
    super.key,
    this.pattern = BackgroundPattern.geometric,
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

    // Optimization: Stop animation if not in Ramadan mode to save resources
    if (!isRamadan && _ctrl.isAnimating) {
      _ctrl.stop();
    } else if (isRamadan && !_ctrl.isAnimating) {
      _ctrl.repeat();
    }

    if (isRamadan) {
      final brightness = Theme.of(context).brightness;
      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) => CustomPaint(
                    painter: RamadanBgPainter(
                      animT: _ctrl.value,
                      brightness: brightness,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final colors = context.colors;
    CustomPainter painter;
    final baseColor = widget.color ?? colors.gold;
    final baseOpacity = widget.opacity ?? 0.08;

    switch (widget.pattern) {
      case BackgroundPattern.twelveFoldStar:
        painter = IslamicP01Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.eightWithCrosses:
        painter = IslamicP02Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.denseEightStar:
        painter = IslamicP03Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.curvedPetals:
        painter = IslamicP04Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.tenFoldStar:
        painter = IslamicP05Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.starCluster:
        painter = IslamicP06Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.floralRosette:
        painter = IslamicP07Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.diamondWeave:
        painter = IslamicP08Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.chainLattice:
        painter = IslamicP09Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.organicLattice:
        painter = IslamicP10Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.arrowKite:
        painter = IslamicP11Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.microStar:
        painter = IslamicP12Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.elongatedStar:
        painter = IslamicP13Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.crystalFacets:
        painter = IslamicP14Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.kaleidoscope:
        painter = IslamicP15Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.kiteLeaf:
        painter = IslamicP16Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.multiRing:
        painter = IslamicP17Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.polygonMosaic:
        painter = IslamicP18Painter(color: baseColor, opacity: baseOpacity);
      case BackgroundPattern.geometric:
        painter = GeometricPainter(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.duas:
        painter = DuasBgPainter(goldColor: baseColor);
        break;
      case BackgroundPattern.adhkar:
        painter = AdhkarBgPainter(
          goldColor: baseColor,
          nightColor: colors.background,
        );
        break;
      case BackgroundPattern.qibla:
        painter = QiblaBgPainter(goldColor: baseColor);
        break;
      case BackgroundPattern.asma:
        painter = AsmaBgPainter(goldColor: baseColor);
        break;
      case BackgroundPattern.pattern1:
        painter = IslamicPattern1(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern2:
        painter = IslamicPattern2(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern3:
        painter = IslamicPattern3(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern4:
        painter = IslamicPattern4(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern5:
        painter = IslamicPattern5(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern6:
        painter = IslamicPattern6(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern7:
        painter = IslamicPattern7(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern8:
        painter = IslamicPattern8(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern9:
        painter = IslamicPattern9(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern10:
        painter = IslamicPattern10(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern11:
        painter = IslamicPattern11(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern12:
        painter = IslamicPattern12(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern13:
        painter = IslamicPattern13(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern14:
        painter = IslamicPattern14(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern15:
        painter = IslamicPattern15(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern16:
        painter = IslamicPattern16(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern17:
        painter = IslamicPattern17(color: baseColor, opacity: baseOpacity);
        break;
      case BackgroundPattern.pattern18:
        painter = IslamicPattern18(color: baseColor, opacity: baseOpacity);
        break;
    }

    return SizedBox.expand(
      child: RepaintBoundary(child: CustomPaint(painter: painter)),
    );
  }
}
