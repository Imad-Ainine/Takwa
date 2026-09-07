import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ── Shared Helpers ───────────────────────────────────────────────────────────

Path _starPath(
  Offset c,
  double outer,
  double inner,
  int n, {
  double rot = 0.0,
}) {
  final p = Path();
  for (int i = 0; i < n * 2; i++) {
    final a = rot + i * math.pi / n;
    final dist = i.isEven ? outer : inner;
    final x = c.dx + dist * math.cos(a);
    final y = c.dy + dist * math.sin(a);
    i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
  }
  return p..close();
}

Path _polyPath(Offset c, double r, int n, {double rot = 0.0}) {
  final p = Path();
  for (int i = 0; i < n; i++) {
    final a = rot + i * 2 * math.pi / n;
    final x = c.dx + r * math.cos(a);
    final y = c.dy + r * math.sin(a);
    i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
  }
  return p..close();
}

// ── Base Islamic Painter for Optimization and Consistency ──
abstract class IslamicBasePainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double strokeWidth;
  final double spacing;

  IslamicBasePainter({
    required this.color,
    this.opacity = 0.1,
    this.strokeWidth = 0.7,
    this.spacing = 80.0,
  });

  Picture? _cached;
  Size? _cachedSize;
  Color? _cachedColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (_cached == null || _cachedSize != size || _cachedColor != color) {
      _cachedSize = size;
      _cachedColor = color;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);

      final p = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      drawPattern(c, size, p);
      _cached = recorder.endRecording();
    }
    canvas.drawPicture(_cached!);
  }

  void drawPattern(Canvas canvas, Size size, Paint paint);

  @override
  bool shouldRepaint(covariant IslamicBasePainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.strokeWidth != strokeWidth ||
      old.spacing != spacing;
}

// ── Pattern 1: Interlaced 8-Point Star (Rub el Hizb Grid) ──
class IslamicPattern1 extends IslamicBasePainter {
  IslamicPattern1({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar1(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawStar1(Canvas canvas, Offset c, double r, Paint p) {
    for (int i = 0; i < 2; i++) {
      final rotation = i * math.pi / 4;
      final square = Path();
      for (int j = 0; j < 4; j++) {
        final a = j * math.pi / 2 + rotation;
        final px = c.dx + r * math.cos(a);
        final py = c.dy + r * math.sin(a);
        if (j == 0) {
          square.moveTo(px, py);
        } else {
          square.lineTo(px, py);
        }
      }
      square.close();
      canvas.drawPath(square, p);
    }
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        c,
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        p,
      );
    }
  }
}

// ── Pattern 2: 8-Point Star with Surrounding Hexagons ──
class IslamicPattern2 extends IslamicBasePainter {
  IslamicPattern2({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 1.2;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final isOdd = (x / step).round().isOdd;
        final py = isOdd ? y + step * 0.5 : y;
        _drawStar2(canvas, Offset(x, py), step * 0.4, paint);
      }
    }
  }

  void _drawStar2(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final d = i.isEven ? r : r * 0.65;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    // Outer hexagonal border
    final hex = Path();
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final px = c.dx + r * 1.2 * math.cos(a);
      final py = c.dy + r * 1.2 * math.sin(a);
      if (i == 0) {
        hex.moveTo(px, py);
      } else {
        hex.lineTo(px, py);
      }
    }
    hex.close();
    canvas.drawPath(hex, p);
  }
}

// ── Pattern 3: 10-Point Star Lattice ──
class IslamicPattern3 extends IslamicBasePainter {
  IslamicPattern3({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 1.4;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar3(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawStar3(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 20; i++) {
      final a = i * math.pi / 10;
      final d = i.isEven ? r : r * 0.6;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    canvas.drawCircle(c, r * 0.3, p);
    for (int i = 0; i < 10; i++) {
      final a = i * math.pi / 5;
      canvas.drawLine(
        c,
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        p,
      );
    }
  }
}

// ── Pattern 4: 8-Point Star with Symmetric Pentagons ──
class IslamicPattern4 extends IslamicBasePainter {
  IslamicPattern4({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar4(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawStar4(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final d = i.isEven ? r : r * 0.55;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + math.pi / 8;
      final px1 = c.dx + r * 0.55 * math.cos(a);
      final py1 = c.dy + r * 0.55 * math.sin(a);
      final px2 = c.dx + r * 1.1 * math.cos(a);
      final py2 = c.dy + r * 1.1 * math.sin(a);
      canvas.drawLine(Offset(px1, py1), Offset(px2, py2), p);
    }
  }
}

// ── Pattern 5: Complex 12-Fold Radial Pattern ──
class IslamicPattern5 extends IslamicBasePainter {
  IslamicPattern5({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 1.6;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar5(canvas, Offset(x, y), step * 0.48, paint);
      }
    }
  }

  void _drawStar5(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 24; i++) {
      final a = i * math.pi / 12;
      final d = i.isEven ? r : r * 0.75;
      final px = c.dx + d * math.cos(a);
      final py = d * math.sin(a) + c.dy;
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    canvas.drawCircle(c, r * 0.4, p);
    canvas.drawCircle(c, r * 0.15, p);
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      canvas.drawLine(
        Offset(c.dx + r * 0.15 * math.cos(a), c.dy + r * 0.15 * math.sin(a)),
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        p,
      );
    }
  }
}

// ── Pattern 6: Hexagonal Lattice with Interlaced Stars ──
class IslamicPattern6 extends IslamicBasePainter {
  IslamicPattern6({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    final hStep = step * 1.5;
    final vStep = step * 0.866;
    for (double x = -step; x < size.width + step; x += hStep) {
      for (double y = -step; y < size.height + step; y += vStep) {
        final isOdd = (x / hStep).round().isOdd;
        final py = isOdd ? y + vStep / 2 : y;
        _drawStar6(canvas, Offset(x, py), step * 0.45, paint);
      }
    }
  }

  void _drawStar6(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final d = i.isEven ? r : r * 0.577;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final px1 = c.dx + r * math.cos(a);
      final py1 = c.dy + r * math.sin(a);
      final px2 = c.dx + r * 1.5 * math.cos(a);
      final py2 = c.dy + r * 1.5 * math.sin(a);
      canvas.drawLine(Offset(px1, py1), Offset(px2, py2), p);
    }
  }
}

// ── Pattern 7: 10-Point Geometric Mandala ──
class IslamicPattern7 extends IslamicBasePainter {
  IslamicPattern7({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 1.5;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar7(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawStar7(Canvas canvas, Offset c, double r, Paint p) {
    for (int i = 0; i < 10; i++) {
      final a1 = i * 2 * math.pi / 10;
      final a2 = (i + 3) * 2 * math.pi / 10;
      canvas.drawLine(
        Offset(c.dx + r * math.cos(a1), c.dy + r * math.sin(a1)),
        Offset(c.dx + r * math.cos(a2), c.dy + r * math.sin(a2)),
        p,
      );
    }
    canvas.drawCircle(c, r * 0.35, p);
  }
}

// ── Pattern 8: 8-Point Star with Square Insets ──
class IslamicPattern8 extends IslamicBasePainter {
  IslamicPattern8({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar8(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawStar8(Canvas canvas, Offset c, double r, Paint p) {
    for (int i = 0; i < 2; i++) {
      final rot = i * math.pi / 4;
      final path = Path();
      for (int j = 0; j < 4; j++) {
        final a = j * math.pi / 2 + rot;
        final px = c.dx + r * math.cos(a);
        final py = c.dy + r * math.sin(a);
        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, p);
    }
    final dr = r * 0.3;
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            c.dx + r * 1.1 * math.cos(a),
            c.dy + r * 1.1 * math.sin(a),
          ),
          width: dr,
          height: dr,
        ),
        p,
      );
    }
  }
}

// ── Pattern 9: 12-Fold Symmetry with Petals ──
class IslamicPattern9 extends IslamicBasePainter {
  IslamicPattern9({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 1.6;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar9(canvas, Offset(x, y), step * 0.48, paint);
      }
    }
  }

  void _drawStar9(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 24; i++) {
      final a = i * math.pi / 12;
      final d = i.isEven ? r : r * 0.85;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    for (int i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      canvas.drawCircle(
        Offset(c.dx + r * 0.6 * math.cos(a), c.dy + r * 0.6 * math.sin(a)),
        r * 0.1,
        p,
      );
    }
  }
}

// ── Pattern 10: Dense Zellij Texture ──
class IslamicPattern10 extends IslamicBasePainter {
  IslamicPattern10({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 0.8;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawZellij(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawZellij(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final px = c.dx + r * math.cos(a);
      final py = c.dy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, p);

    // Cross lines
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        Offset(
          c.dx + r * math.cos(a + math.pi),
          c.dy + r * math.sin(a + math.pi),
        ),
        p,
      );
    }
  }
}

// ── Pattern 11: 8-Point Star with Inner Diamonds ──
class IslamicPattern11 extends IslamicBasePainter {
  IslamicPattern11({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar11(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawStar11(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final d = i.isEven ? r : r * 0.6;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    final dr = r * 0.2;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: dr, height: dr),
      p,
    );
    canvas.restore();
  }
}

// ── Pattern 12: Complex 12-Fold Architectural Pattern ──
class IslamicPattern12 extends IslamicBasePainter {
  IslamicPattern12({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 1.5;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar12(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawStar12(Canvas canvas, Offset c, double r, Paint p) {
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final px = c.dx + r * math.cos(a);
      final py = c.dy + r * math.sin(a);
      canvas.drawLine(c, Offset(px, py), p);
      canvas.drawCircle(Offset(px, py), r * 0.15, p);
    }
    canvas.drawCircle(c, r * 0.5, p);
  }
}

// ── Pattern 13: Dense Geometric Mesh ──
class IslamicPattern13 extends IslamicBasePainter {
  IslamicPattern13({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 0.8;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawMesh(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawMesh(Canvas canvas, Offset c, double r, Paint p) {
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final px1 = c.dx + r * math.cos(a);
      final py1 = c.dy + r * math.sin(a);
      final px2 = c.dx + r * math.cos(a + math.pi / 2);
      final py2 = c.dy + r * math.sin(a + math.pi / 2);
      canvas.drawLine(Offset(px1, py1), Offset(px2, py2), p);
    }
    _drawStar11(canvas, c, r * 0.7, p);
  }

  void _drawStar11(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final d = i.isEven ? r : r * 0.6;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);
  }
}

// ── Pattern 14: Large 8-Point Rub el Hizb ──
class IslamicPattern14 extends IslamicBasePainter {
  IslamicPattern14({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 1.3;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar14(canvas, Offset(x, y), step * 0.48, paint);
      }
    }
  }

  void _drawStar14(Canvas canvas, Offset c, double r, Paint p) {
    for (int i = 0; i < 2; i++) {
      final rot = i * math.pi / 4;
      final path = Path();
      for (int j = 0; j < 4; j++) {
        final a = j * math.pi / 2 + rot;
        final px = c.dx + r * math.cos(a);
        final py = c.dy + r * math.sin(a);
        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, p);
    }
    canvas.drawCircle(c, r * 0.2, p);
  }
}

// ── Pattern 15: Star and Cross Tessellation ──
class IslamicPattern15 extends IslamicBasePainter {
  IslamicPattern15({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawPattern15(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawPattern15(Canvas canvas, Offset c, double r, Paint p) {
    final Path star = Path();
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final d = i.isEven ? r : r * 0.6;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      final px1 = c.dx + r * 0.6 * math.cos(a);
      final py1 = c.dy + r * 0.6 * math.sin(a);
      final px2 = c.dx + r * 1.2 * math.cos(a);
      final py2 = c.dy + r * 1.2 * math.sin(a);
      canvas.drawLine(Offset(px1, py1), Offset(px2, py2), p);
    }
  }
}

// ── Pattern 16: Nested Geometric Octagons ──
class IslamicPattern16 extends IslamicBasePainter {
  IslamicPattern16({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawNestedOct(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawNestedOct(Canvas canvas, Offset c, double r, Paint p) {
    _drawOct(canvas, c, r, p);
    _drawOct(canvas, c, r * 0.7, p);
    _drawOct(canvas, c, r * 0.4, p);
  }

  void _drawOct(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + math.pi / 8;
      final px = c.dx + r * math.cos(a);
      final py = c.dy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, p);
  }
}

// ── Pattern 17: Interlocking Diamond Lattice ──
class IslamicPattern17 extends IslamicBasePainter {
  IslamicPattern17({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing * 0.9;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawDiamond(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawDiamond(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    path.moveTo(c.dx, c.dy - r);
    path.lineTo(c.dx + r, c.dy);
    path.lineTo(c.dx, c.dy + r);
    path.lineTo(c.dx - r, c.dy);
    path.close();
    canvas.drawPath(path, p);

    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(
        c,
        Offset(c.dx + r * 1.2 * math.cos(a), c.dy + r * 1.2 * math.sin(a)),
        p,
      );
    }
  }
}

// ── Pattern 18: Square Based Islamic Geometric ──
class IslamicPattern18 extends IslamicBasePainter {
  IslamicPattern18({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawSquarePattern(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawSquarePattern(Canvas canvas, Offset c, double r, Paint p) {
    canvas.drawRect(Rect.fromCenter(center: c, width: r * 2, height: r * 2), p);
    _drawStar1(canvas, c, r * 0.8, p);
  }

  void _drawStar1(Canvas canvas, Offset c, double r, Paint p) {
    for (int i = 0; i < 2; i++) {
      final rot = i * math.pi / 4;
      final path = Path();
      for (int j = 0; j < 4; j++) {
        final a = j * math.pi / 2 + rot;
        final px = c.dx + r * math.cos(a);
        final py = c.dy + r * math.sin(a);
        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, p);
    }
  }
}

// ── Islamic P-Series Painters (Migrated from background_bg_painters.dart) ──

// Shared Helpers

// P01 · 12-fold Star — Moroccan/Andalusian hex grid
class IslamicP01Painter extends IslamicBasePainter {
  IslamicP01Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.7,
    super.spacing = 96.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        final off = ((x / s).round().isOdd) ? s / 2 : 0.0;
        _motif(cv, Offset(x, y + off), s * 0.44, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_starPath(c, r, r * 0.5, 12, rot: -math.pi / 2), p);
    cv.drawPath(_polyPath(c, r * 0.32, 12, rot: -math.pi / 2), p);
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi / 6 - math.pi / 2;
      cv.drawLine(
        Offset(c.dx + r * 0.32 * math.cos(a), c.dy + r * 0.32 * math.sin(a)),
        Offset(c.dx + r * 0.5 * math.cos(a), c.dy + r * 0.5 * math.sin(a)),
        p,
      );
    }
  }
}

// P02 · 8-fold Star with Square Crosses — Girih tile style
class IslamicP02Painter extends IslamicBasePainter {
  IslamicP02Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 82.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _star(cv, Offset(x, y), s * 0.42, p);
        _cross(cv, Offset(x + s / 2, y + s / 2), s * 0.18, p);
      }
    }
  }

  void _star(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_starPath(c, r, r * 0.414, 8, rot: -math.pi / 8), p);
    cv.drawPath(_polyPath(c, r * 0.28, 8, rot: -math.pi / 8), p);
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      cv.drawLine(
        Offset(c.dx + r * 0.28 * math.cos(a), c.dy + r * 0.28 * math.sin(a)),
        Offset(c.dx + r * 0.414 * math.cos(a), c.dy + r * 0.414 * math.sin(a)),
        p,
      );
    }
  }

  void _cross(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_polyPath(c, r, 4, rot: math.pi / 4), p);
    cv.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), p);
    cv.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), p);
  }
}

// P03 · Dense 8-pt Stars — close-packed tessellation
class IslamicP03Painter extends IslamicBasePainter {
  IslamicP03Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.6,
    super.spacing = 58.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _motif(cv, Offset(x, y), s * 0.46, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_starPath(c, r, r * 0.38, 8, rot: math.pi / 8), p);
    cv.drawPath(_starPath(c, r * 0.62, r * 0.24, 8, rot: math.pi / 8), p);
    cv.drawPath(_polyPath(c, r * 0.18, 4, rot: 0), p);
  }
}

// P04 · Curved Petal Weave — overlapping arcs / interlace
class IslamicP04Painter extends IslamicBasePainter {
  IslamicP04Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 72.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _motif(cv, Offset(x, y), s * 0.44, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    for (int i = 0; i < 8; i++) {
      final a1 = i * math.pi / 4;
      final a2 = (i + 1) * math.pi / 4;
      final mid = (a1 + a2) / 2;
      final p1 = Offset(c.dx + r * math.cos(a1), c.dy + r * math.sin(a1));
      final p2 = Offset(c.dx + r * math.cos(a2), c.dy + r * math.sin(a2));
      final ctrl = Offset(
        c.dx + r * 0.55 * math.cos(mid),
        c.dy + r * 0.55 * math.sin(mid),
      );
      cv.drawPath(
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, p2.dx, p2.dy),
        p,
      );
    }
    cv.drawPath(_starPath(c, r * 0.56, r * 0.28, 8, rot: math.pi / 8), p);
    for (int i = 0; i < 8; i++) {
      final a1 = i * math.pi / 4 + math.pi / 8;
      final a2 = (i + 1) * math.pi / 4 + math.pi / 8;
      final mid = (a1 + a2) / 2;
      final p1 = Offset(
        c.dx + r * 0.56 * math.cos(a1),
        c.dy + r * 0.56 * math.sin(a1),
      );
      final p2 = Offset(
        c.dx + r * 0.56 * math.cos(a2),
        c.dy + r * 0.56 * math.sin(a2),
      );
      final ctrl = Offset(
        c.dx + r * 0.33 * math.cos(mid),
        c.dy + r * 0.33 * math.sin(mid),
      );
      cv.drawPath(
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, p2.dx, p2.dy),
        p,
      );
    }
  }
}

// P05 · 10-fold Star — decagonal with pentagon fillers
class IslamicP05Painter extends IslamicBasePainter {
  IslamicP05Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 100.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    final hS = s * 1.902;
    final vS = s * 1.176;
    for (double x = -hS; x < size.width + hS; x += hS) {
      for (double y = -vS; y < size.height + vS; y += vS) {
        _motif(cv, Offset(x, y), s * 0.44, p);
        _motif(cv, Offset(x + hS / 2, y + vS / 2), s * 0.44, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_starPath(c, r, r * 0.618, 10, rot: -math.pi / 2), p);
    cv.drawPath(_polyPath(c, r * 0.35, 5, rot: -math.pi / 2), p);
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5 - math.pi / 2;
      final pos = Offset(
        c.dx + r * 1.05 * math.cos(a),
        c.dy + r * 1.05 * math.sin(a),
      );
      cv.drawPath(_polyPath(pos, r * 0.18, 5, rot: a + math.pi / 2), p);
    }
    for (int i = 0; i < 10; i++) {
      final a = i * math.pi / 5 - math.pi / 2;
      cv.drawLine(
        Offset(c.dx + r * 0.35 * math.cos(a), c.dy + r * 0.35 * math.sin(a)),
        Offset(c.dx + r * 0.618 * math.cos(a), c.dy + r * 0.618 * math.sin(a)),
        p,
      );
    }
  }
}

// P06 · 8-pt Star Cluster — stars with satellite diamonds
class IslamicP06Painter extends IslamicBasePainter {
  IslamicP06Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 86.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _motif(cv, Offset(x, y), s * 0.43, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_starPath(c, r, r * 0.414, 8, rot: 0), p);
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      final pos = Offset(
        c.dx + r * 1.1 * math.cos(a),
        c.dy + r * 1.1 * math.sin(a),
      );
      cv.drawPath(_starPath(pos, r * 0.22, r * 0.1, 4, rot: math.pi / 4), p);
    }
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      cv.drawLine(
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        Offset(c.dx + r * 1.3 * math.cos(a), c.dy + r * 1.3 * math.sin(a)),
        p,
      );
    }
  }
}

// P07 · Floral Rosette — 6-petal flowers on hexagonal grid
class IslamicP07Painter extends IslamicBasePainter {
  IslamicP07Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 80.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    final hS = s * 1.732;
    final vS = s * 1.5;
    for (double x = -hS; x < size.width + hS; x += hS) {
      for (double y = -vS; y < size.height + vS; y += vS) {
        _motif(cv, Offset(x, y), s * 0.46, p);
        _motif(cv, Offset(x + hS / 2, y + vS / 2), s * 0.46, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final tip = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      final left = a - math.pi / 6;
      final right = a + math.pi / 6;
      final lx = c.dx + r * 0.6 * math.cos(left);
      final ly = c.dy + r * 0.6 * math.sin(left);
      final rx = c.dx + r * 0.6 * math.cos(right);
      final ry = c.dy + r * 0.6 * math.sin(right);
      cv.drawPath(
        Path()
          ..moveTo(lx, ly)
          ..quadraticBezierTo(tip.dx, tip.dy, rx, ry)
          ..quadraticBezierTo(
            c.dx + r * 0.3 * math.cos(a),
            c.dy + r * 0.3 * math.sin(a),
            lx,
            ly,
          ),
        p,
      );
    }
    cv.drawPath(_polyPath(c, r * 0.3, 6, rot: 0), p);
    final savedStyle = p.style;
    cv.drawCircle(c, r * 0.07, p..style = PaintingStyle.fill);
    p.style = savedStyle;
  }
}

// P08 · Diamond Interlace Weave — offset rhombus grid
class IslamicP08Painter extends IslamicBasePainter {
  IslamicP08Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.7,
    super.spacing = 54.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        final off = ((x / s).round().isOdd) ? s / 2 : 0.0;
        _motif(cv, Offset(x, y + off), s * 0.44, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    final outer = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * 0.68, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * 0.68, c.dy)
      ..close();
    cv.drawPath(outer, p);
    final inner = Path()
      ..moveTo(c.dx, c.dy - r * 0.5)
      ..lineTo(c.dx + r * 0.34, c.dy)
      ..lineTo(c.dx, c.dy + r * 0.5)
      ..lineTo(c.dx - r * 0.34, c.dy)
      ..close();
    cv.drawPath(inner, p);
    cv.drawLine(Offset(c.dx, c.dy - r * 0.5), Offset(c.dx, c.dy + r * 0.5), p);
    cv.drawLine(
      Offset(c.dx - r * 0.34, c.dy),
      Offset(c.dx + r * 0.34, c.dy),
      p,
    );
  }
}

// P09 · Chain-mail Lattice — octagon + square tessellation
class IslamicP09Painter extends IslamicBasePainter {
  IslamicP09Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.6,
    super.spacing = 42.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _motif(cv, Offset(x, y), s * 0.46, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_polyPath(c, r, 8, rot: math.pi / 8), p);
    cv.drawPath(_polyPath(c, r * 0.5, 4, rot: math.pi / 4), p);
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      cv.drawLine(
        Offset(c.dx + r * 0.5 * math.cos(a), c.dy + r * 0.5 * math.sin(a)),
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        p,
      );
    }
  }
}

// P10 · Organic Lattice — 6-pt star with curved bulging arcs
class IslamicP10Painter extends IslamicBasePainter {
  IslamicP10Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.7,
    super.spacing = 88.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        final off = ((x / s).round().isOdd) ? s / 2 : 0.0;
        _motif(cv, Offset(x, y + off), s * 0.44, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_starPath(c, r, r * 0.577, 6, rot: 0), p);
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final nxt = (i + 1) * math.pi / 3;
      final p1 = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      final p2 = Offset(c.dx + r * math.cos(nxt), c.dy + r * math.sin(nxt));
      final mid = (a + nxt) / 2;
      final ctrl = Offset(
        c.dx + r * 1.3 * math.cos(mid),
        c.dy + r * 1.3 * math.sin(mid),
      );
      cv.drawPath(
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, p2.dx, p2.dy),
        p,
      );
    }
    cv.drawCircle(c, r * 0.2, p);
  }
}

// P11 · Arrow-Kite Star — angular kite motifs around an 8-pt centre
class IslamicP11Painter extends IslamicBasePainter {
  IslamicP11Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 84.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _motif(cv, Offset(x, y), s * 0.44, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final tip = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      final left = Offset(
        c.dx + r * 0.45 * math.cos(a - math.pi / 8),
        c.dy + r * 0.45 * math.sin(a - math.pi / 8),
      );
      final right = Offset(
        c.dx + r * 0.45 * math.cos(a + math.pi / 8),
        c.dy + r * 0.45 * math.sin(a + math.pi / 8),
      );
      final base = Offset(
        c.dx + r * 0.18 * math.cos(a + math.pi),
        c.dy + r * 0.18 * math.sin(a + math.pi),
      );
      cv.drawPath(
        Path()
          ..moveTo(left.dx, left.dy)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(right.dx, right.dy)
          ..lineTo(base.dx, base.dy)
          ..close(),
        p,
      );
    }
    cv.drawPath(_polyPath(c, r * 0.22, 8, rot: 0), p);
  }
}

// P12 · Micro Dense Stars — small 8-pt grid with square fillers
class IslamicP12Painter extends IslamicBasePainter {
  IslamicP12Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.55,
    super.spacing = 44.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _star(cv, Offset(x, y), s * 0.44, p);
        _sq(cv, Offset(x + s / 2, y + s / 2), s * 0.15, p);
      }
    }
  }

  void _star(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_starPath(c, r, r * 0.414, 8, rot: math.pi / 8), p);
    cv.drawPath(_polyPath(c, r * 0.26, 8, rot: math.pi / 8), p);
  }

  void _sq(Canvas cv, Offset c, double r, Paint p) =>
      cv.drawPath(_polyPath(c, r, 4, rot: math.pi / 4), p);
}

// P13 · Elongated Star — stretched 8-pt with rectangular bands
class IslamicP13Painter extends IslamicBasePainter {
  IslamicP13Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 90.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _motif(cv, Offset(x, y), s * 0.44, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      double dist;
      if (i.isEven) {
        dist = (i % 4 == 0) ? r : r * 0.82;
      } else {
        dist = r * 0.38;
      }
      final x = c.dx + dist * math.cos(a);
      final y = c.dy + dist * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    cv.drawPath(path, p);
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      cv.save();
      cv.translate(
        c.dx + r * 1.15 * math.cos(a),
        c.dy + r * 1.15 * math.sin(a),
      );
      cv.rotate(a);
      cv.drawRect(
        Rect.fromCenter(center: Offset.zero, width: r * 0.66, height: r * 0.28),
        p,
      );
      cv.restore();
    }
    cv.drawPath(_polyPath(c, r * 0.28, 4, rot: math.pi / 4), p);
  }
}

// P14 · Crystal Facets — cut-gem rhombus pattern
class IslamicP14Painter extends IslamicBasePainter {
  IslamicP14Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.6,
    super.spacing = 52.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        final off = ((x / s).round().isOdd) ? s / 2 : 0.0;
        _motif(cv, Offset(x, y + off), s * 0.46, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    final outer = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * 0.6, c.dy - r * 0.2)
      ..lineTo(c.dx + r * 0.6, c.dy + r * 0.2)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * 0.6, c.dy + r * 0.2)
      ..lineTo(c.dx - r * 0.6, c.dy - r * 0.2)
      ..close();
    cv.drawPath(outer, p);
    // Facet lines from vertices to centre
    for (final pt in [
      Offset(c.dx, c.dy - r),
      Offset(c.dx + r * 0.6, c.dy - r * 0.2),
      Offset(c.dx + r * 0.6, c.dy + r * 0.2),
      Offset(c.dx, c.dy + r),
      Offset(c.dx - r * 0.6, c.dy + r * 0.2),
      Offset(c.dx - r * 0.6, c.dy - r * 0.2),
    ]) {
      cv.drawLine(pt, c, p);
    }
  }
}

// P15 · Kaleidoscope Star — nested 12-pt rings, complex radial
class IslamicP15Painter extends IslamicBasePainter {
  IslamicP15Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.6,
    super.spacing = 112.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        final off = ((x / s).round().isOdd) ? s / 2 : 0.0;
        _motif(cv, Offset(x, y + off), s * 0.46, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_starPath(c, r, r * 0.5, 12, rot: -math.pi / 12), p);
    cv.drawPath(_starPath(c, r * 0.72, r * 0.55, 12, rot: -math.pi / 12), p);
    cv.drawPath(_starPath(c, r * 0.5, r * 0.36, 6, rot: 0), p);
    cv.drawCircle(c, r * 0.18, p);
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      cv.drawLine(
        Offset(c.dx + r * 0.18 * math.cos(a), c.dy + r * 0.18 * math.sin(a)),
        Offset(c.dx + r * 0.5 * math.cos(a), c.dy + r * 0.5 * math.sin(a)),
        p,
      );
    }
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      cv.drawLine(
        Offset(c.dx + r * 0.72 * math.cos(a), c.dy + r * 0.72 * math.sin(a)),
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        p,
      );
    }
  }
}

// P16 · Kite-Leaf Star — curved kite petals, Arabesque style
class IslamicP16Painter extends IslamicBasePainter {
  IslamicP16Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 88.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _motif(cv, Offset(x, y), s * 0.44, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final tip = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      final lAng = a - math.pi / 3;
      final rAng = a + math.pi / 3;
      final left = Offset(
        c.dx + r * 0.5 * math.cos(lAng),
        c.dy + r * 0.5 * math.sin(lAng),
      );
      final right = Offset(
        c.dx + r * 0.5 * math.cos(rAng),
        c.dy + r * 0.5 * math.sin(rAng),
      );
      final ctrl1 = Offset(
        c.dx + r * 0.75 * math.cos(a - math.pi / 6),
        c.dy + r * 0.75 * math.sin(a - math.pi / 6),
      );
      final ctrl2 = Offset(
        c.dx + r * 0.75 * math.cos(a + math.pi / 6),
        c.dy + r * 0.75 * math.sin(a + math.pi / 6),
      );
      cv.drawPath(
        Path()
          ..moveTo(left.dx, left.dy)
          ..quadraticBezierTo(ctrl1.dx, ctrl1.dy, tip.dx, tip.dy)
          ..quadraticBezierTo(ctrl2.dx, ctrl2.dy, right.dx, right.dy)
          ..lineTo(c.dx, c.dy)
          ..close(),
        p,
      );
    }
    cv.drawCircle(c, r * 0.1, p);
  }
}

// P17 · Multi-Ring Weave — segmented concentric rings with radial spokes
class IslamicP17Painter extends IslamicBasePainter {
  IslamicP17Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.65,
    super.spacing = 96.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    for (double x = -s; x < size.width + s; x += s) {
      for (double y = -s; y < size.height + s; y += s) {
        _motif(cv, Offset(x, y), s * 0.46, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    for (int ring = 1; ring <= 3; ring++) {
      final rr = r * ring / 3.0;
      final gapFraction = ring.isOdd ? 0.0 : math.pi / 8;
      for (int i = 0; i < 8; i++) {
        final startA = i * math.pi / 4 + gapFraction;
        const sweep = math.pi / 4 * 0.72;
        cv.drawPath(
          Path()..addArc(Rect.fromCircle(center: c, radius: rr), startA, sweep),
          p,
        );
      }
    }
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      cv.drawLine(
        Offset(c.dx + r * 0.12 * math.cos(a), c.dy + r * 0.12 * math.sin(a)),
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        p,
      );
    }
    cv.drawCircle(c, r * 0.12, p);
  }
}

// P18 · Polygon Mosaic — hexagons with triangle satellites
class IslamicP18Painter extends IslamicBasePainter {
  IslamicP18Painter({
    required super.color,
    super.opacity,
    super.strokeWidth = 0.6,
    super.spacing = 60.0,
  });

  @override
  void drawPattern(Canvas cv, Size size, Paint p) {
    final s = spacing;
    final hS = s * 1.732;
    final vS = s * 1.5;
    for (double x = -hS; x < size.width + hS; x += hS) {
      for (double y = -vS; y < size.height + vS; y += vS) {
        _motif(cv, Offset(x, y), s * 0.46, p);
        _motif(cv, Offset(x + hS / 2, y + vS / 2), s * 0.46, p);
      }
    }
  }

  void _motif(Canvas cv, Offset c, double r, Paint p) {
    cv.drawPath(_polyPath(c, r * 0.9, 6, rot: 0), p);
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final pos = Offset(
        c.dx + r * 0.76 * math.cos(a),
        c.dy + r * 0.76 * math.sin(a),
      );
      cv.drawPath(_polyPath(pos, r * 0.22, 3, rot: a + math.pi / 2), p);
    }
    cv.drawPath(_polyPath(c, r * 0.38, 6, rot: math.pi / 6), p);
    cv.drawPath(_polyPath(c, r * 0.16, 3, rot: 0), p);
  }
}

// ── Legacy Painters (Refactored to use Base) ──

class GeometricPainter extends IslamicBasePainter {
  GeometricPainter({
    required super.color,
    super.opacity,
    super.strokeWidth,
    super.spacing,
  });

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawComplexRubElHizb(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawComplexRubElHizb(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    final r = size / 2;
    for (int i = 0; i < 2; i++) {
      final rot = i * math.pi / 4;
      final path = Path();
      for (int j = 0; j < 4; j++) {
        final a = j * math.pi / 2 + rot;
        final px = center.dx + r * math.cos(a);
        final py = center.dy + r * math.sin(a);
        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }
}

class DuasBgPainter extends IslamicBasePainter {
  DuasBgPainter({required Color goldColor})
    : super(color: goldColor, opacity: 0.045, strokeWidth: 0.65, spacing: 80.0);

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    final hStep = step * 1.5;
    final vStep = step * 0.866;
    for (double x = -step; x < size.width + step; x += hStep) {
      for (double y = -step; y < size.height + step; y += vStep) {
        final isOdd = (x / hStep).round().isOdd;
        final py = isOdd ? y + vStep / 2 : y;
        _drawKhatamStar(canvas, Offset(x, py), step * 0.45, paint);
      }
    }
  }

  void _drawKhatamStar(Canvas canvas, Offset center, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final d = i.isEven ? r : r * 0.577;
      final px = center.dx + d * math.cos(a);
      final py = center.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);
  }
}

class QiblaBgPainter extends CustomPainter {
  final Color goldColor;
  QiblaBgPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = goldColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;
    final center = Offset(size.width / 2, size.height * 0.45);
    for (int i = 1; i <= 7; i++) {
      final r = i * 48.0;
      canvas.drawCircle(center, r, p);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

class AdhkarBgPainter extends IslamicBasePainter {
  AdhkarBgPainter({required Color goldColor, required Color nightColor})
    : super(color: goldColor, opacity: 0.06, strokeWidth: 0.75, spacing: 92.0);

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawInterlacedZellij(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawInterlacedZellij(Canvas canvas, Offset c, double r, Paint p) {
    final Path star1 = Path();
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final d1 = i.isEven ? r : r * 0.65;
      final px1 = c.dx + d1 * math.cos(a);
      final py1 = c.dy + d1 * math.sin(a);
      if (i == 0) {
        star1.moveTo(px1, py1);
      } else {
        star1.lineTo(px1, py1);
      }
    }
    star1.close();
    canvas.drawPath(star1, p);
  }
}

class AsmaBgPainter extends IslamicBasePainter {
  AsmaBgPainter({required Color goldColor})
    : super(color: goldColor, opacity: 0.05, strokeWidth: 0.7, spacing: 110.0);

  @override
  void drawPattern(Canvas canvas, Size size, Paint paint) {
    final step = spacing;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final isOdd = (x / step).round().isOdd;
        final py = isOdd ? y + step / 2 : y;
        _drawTwelveFoldStar(canvas, Offset(x, py), step * 0.48, paint);
      }
    }
  }

  void _drawTwelveFoldStar(Canvas canvas, Offset c, double r, Paint p) {
    final star = Path();
    for (int i = 0; i < 24; i++) {
      final a = i * math.pi / 12;
      final d = i.isEven ? r : r * 0.75;
      final px = c.dx + d * math.cos(a);
      final py = c.dy + d * math.sin(a);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);
  }
}

// RamadanBgPainter moved to ramadan_theme.dart
