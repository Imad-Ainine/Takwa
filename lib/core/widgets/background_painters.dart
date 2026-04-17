import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ── Geometric Pattern ──
class GeometricPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double strokeWidth;
  final double spacing;

  GeometricPainter({
    required this.color,
    this.opacity = 0.08,
    this.strokeWidth = 0.6, // Slightly thinner for professionalism
    this.spacing = 64.0,
  });
  static Picture? _cached;
  static Size? _cachedSize;
  static Color? _cachedColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (_cached == null || _cachedSize != size || _cachedColor != color) {
      _cachedSize = size;
      _cachedColor = color;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);

      final p = Paint()
        ..color = color.withOpacity(opacity)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      const step = 80.0;
      for (double x = 0; x < size.width + step; x += step) {
        for (double y = 0; y < size.height + step; y += step) {
          _drawComplexRubElHizb(c, Offset(x, y), step * 0.45, p);
        }
      }
      _cached = recorder.endRecording();
    }
    canvas.drawPicture(_cached!);
  }

  void _drawComplexRubElHizb(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    final Path path = Path();
    final double r = size / 2;

    // Main Star
    for (int i = 0; i < 8; i++) {
      final double angle = i * math.pi / 4;
      final double px = center.dx + r * math.cos(angle);
      final double py = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    // Secondary rotated square for Rub el Hizb
    final double diag = r * math.sqrt(2);
    final Path rotated = Path();
    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2 + math.pi / 4;
      final double px = center.dx + diag * math.cos(angle);
      final double py = center.dy + diag * math.sin(angle);
      if (i == 0) {
        rotated.moveTo(px, py);
      } else {
        rotated.lineTo(px, py);
      }
    }
    rotated.close();

    // Interlocking lines connecting vertices
    for (int i = 0; i < 8; i++) {
      final double angle = i * math.pi / 4;
      final double px = center.dx + r * math.cos(angle);
      final double py = center.dy + r * math.sin(angle);
      canvas.drawLine(center, Offset(px, py), paint);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(rotated, paint);

    // Diamond connectors
    final double ds = size * 0.15;
    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2;
      final Offset dPos = Offset(
        center.dx + r * 1.25 * math.cos(angle),
        center.dy + r * 1.25 * math.sin(angle),
      );
      _drawDiamond(canvas, dPos, ds, paint);
    }
  }

  void _drawDiamond(Canvas canvas, Offset c, double s, Paint p) {
    final Path path = Path();
    path.moveTo(c.dx, c.dy - s);
    path.lineTo(c.dx + s, c.dy);
    path.lineTo(c.dx, c.dy + s);
    path.lineTo(c.dx - s, c.dy);
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant GeometricPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.strokeWidth != strokeWidth ||
      old.spacing != spacing;
}

// ── Statistics Pattern ──
class StatsBgPainter extends CustomPainter {
  final Color nightColor;
  final Color dotColor;
  static Picture? _cached;
  static Size? _cachedSize;
  static Color? _cachedNight;
  static Color? _cachedDot;

  StatsBgPainter({required this.nightColor, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (_cached == null ||
        _cachedSize != size ||
        _cachedNight != nightColor ||
        _cachedDot != dotColor) {
      _cachedSize = size;
      _cachedNight = nightColor;
      _cachedDot = dotColor;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);

      c.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = nightColor,
      );
      final p = Paint()..color = dotColor;
      for (double x = 16; x < size.width; x += 28) {
        for (double y = 16; y < size.height; y += 28) {
          c.drawCircle(Offset(x, y), 1, p);
        }
      }
      _cached = recorder.endRecording();
    }
    canvas.drawPicture(_cached!);
  }

  @override
  bool shouldRepaint(covariant StatsBgPainter o) =>
      o.nightColor != nightColor || o.dotColor != dotColor;
}

// ── Duas Pattern ──
class DuasBgPainter extends CustomPainter {
  final Color goldColor;
  static Picture? _cached;
  static Size? _cachedSize;
  static Color? _cachedColor;

  DuasBgPainter({required this.goldColor});

  @override
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (_cached == null || _cachedSize != size || _cachedColor != goldColor) {
      _cachedSize = size;
      _cachedColor = goldColor;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);

      final p = Paint()
        ..color = goldColor.withOpacity(0.045)
        ..strokeWidth = 0.65
        ..style = PaintingStyle.stroke;

      const step = 80.0;
      const hStep = step * 1.5;
      const vStep = step * 0.866;

      for (double x = -step; x < size.width + step; x += hStep) {
        for (double y = -step; y < size.height + step; y += vStep) {
          final isOdd = (x / hStep).round().isOdd;
          final py = isOdd ? y + vStep / 2 : y;
          _drawKhatamStar(c, Offset(x, py), step * 0.45, p);
        }
      }
      _cached = recorder.endRecording();
    }
    canvas.drawPicture(_cached!);
  }

  void _drawKhatamStar(Canvas canvas, Offset center, double r, Paint p) {
    // 6-pointed star base
    final Path star = Path();
    for (int i = 0; i < 12; i++) {
      final double angle = i * math.pi / 6;
      final double dist = i.isEven ? r : r * 0.577;
      final double px = center.dx + dist * math.cos(angle);
      final double py = center.dy + dist * math.sin(angle);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    // Connecting spokes forming a hexagonal lattice
    for (int i = 0; i < 6; i++) {
        final double angle = i * math.pi / 3;
        final double px1 = center.dx + r * math.cos(angle);
        final double py1 = center.dy + r * math.sin(angle);
        final double px2 = center.dx + r * 1.5 * math.cos(angle);
        final double py2 = center.dy + r * 1.5 * math.sin(angle);
        canvas.drawLine(Offset(px1, py1), Offset(px2, py2), p);
    }

    // Outer hexagon
    final Path hex = Path();
    for (int i = 0; i < 6; i++) {
        final double angle = i * math.pi / 3 + math.pi / 6;
        final double px = center.dx + r * 0.866 * math.cos(angle);
        final double py = center.dy + r * 0.866 * math.sin(angle);
        if (i == 0) {
          hex.moveTo(px, py);
        } else {
          hex.lineTo(px, py);
        }
    }
    hex.close();
    canvas.drawPath(hex, p);
  }

  @override
  bool shouldRepaint(covariant DuasBgPainter o) => o.goldColor != goldColor;
}

// ── Qibla Pattern ──
class QiblaBgPainter extends CustomPainter {
  final Color goldColor;
  static Picture? _cached;
  static Size? _cachedSize;
  static Color? _cachedColor;

  QiblaBgPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (_cached == null || _cachedSize != size || _cachedColor != goldColor) {
      _cachedSize = size;
      _cachedColor = goldColor;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);

      final center = Offset(size.width / 2, size.height * 0.45);
      final p = Paint()
        ..color = goldColor.withOpacity(0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85;

      for (int i = 1; i <= 7; i++) {
        final r = i * 48.0;
        c.drawCircle(center, r, p);

        // Add intricate ornamental markers
        final int markerCount = i.isEven ? 8 : 12;
        for (int j = 0; j < markerCount; j++) {
            final angle = j * (2 * math.pi / markerCount);
            final pos = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
            _drawOrnamentalStar(c, pos, 4.5, p);
        }
      }
      _cached = recorder.endRecording();
    }
    canvas.drawPicture(_cached!);
  }

  void _drawOrnamentalStar(Canvas canvas, Offset pos, double r, Paint p) {
      final Path path = Path();
      // 8-point ornamental star
      for (int i = 0; i < 16; i++) {
          final a = i * math.pi / 8;
          final dist = i.isEven ? r : r * 0.45;
          final px = pos.dx + dist * math.cos(a);
          final py = pos.dy + dist * math.sin(a);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
      }
      path.close();
      canvas.drawPath(path, p);

      final oldStyle = p.style;
      // Small dot in center
      canvas.drawCircle(pos, 0.8, p..style = PaintingStyle.fill);
      p.style = oldStyle; // Reset
  }

  @override
  bool shouldRepaint(covariant QiblaBgPainter o) => o.goldColor != goldColor;
}

// ── Checklist Subtle Pattern ──
class SubtleBgPainter extends CustomPainter {
  final Color nightColor;
  final Color goldColor;
  static Picture? _cached;
  static Size? _cachedSize;
  static Color? _cachedNight;
  static Color? _cachedGold;

  SubtleBgPainter({required this.nightColor, required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (_cached == null ||
        _cachedSize != size ||
        _cachedNight != nightColor ||
        _cachedGold != goldColor) {
      _cachedSize = size;
      _cachedNight = nightColor;
      _cachedGold = goldColor;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);

      c.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = nightColor,
      );
      final p = Paint()
        ..color = goldColor.withOpacity(0.04)
        ..strokeWidth = 0.6
        ..style = PaintingStyle.stroke;
      for (double x = 0; x < size.width; x += 32) {
        c.drawLine(Offset(x, 0), Offset(x, size.height), p);
      }
      for (double y = 0; y < size.height; y += 32) {
        c.drawLine(Offset(0, y), Offset(size.width, y), p);
      }
      _cached = recorder.endRecording();
    }
    canvas.drawPicture(_cached!);
  }

  @override
  bool shouldRepaint(covariant SubtleBgPainter old) =>
      old.nightColor != nightColor || old.goldColor != goldColor;
}

// ── Adhkar Pattern ──
class AdhkarBgPainter extends CustomPainter {
  final Color nightColor;
  final Color goldColor;
  static Picture? _cached;
  static Size? _cachedSize;
  static Color? _cachedNight;
  static Color? _cachedGold;

  AdhkarBgPainter({required this.nightColor, required this.goldColor});

  @override
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (_cached == null ||
        _cachedSize != size ||
        _cachedNight != nightColor ||
        _cachedGold != goldColor) {
      _cachedSize = size;
      _cachedNight = nightColor;
      _cachedGold = goldColor;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);

      c.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = nightColor,
      );

      final p = Paint()
        ..color = goldColor.withOpacity(0.06)
        ..strokeWidth = 0.75
        ..style = PaintingStyle.stroke;

      const step = 92.0;
      for (double x = 0; x < size.width + step; x += step) {
        for (double y = 0; y < size.height + step; y += step) {
          _drawInterlacedZellij(c, Offset(x, y), step * 0.45, p);
        }
      }

      // Enhanced radial glow for premium depth
      c.drawCircle(
        Offset(size.width / 2, -60),
        size.height * 0.5,
        Paint()
          ..shader = RadialGradient(
            colors: [goldColor.withOpacity(0.12), Colors.transparent],
          ).createShader(
            Rect.fromCircle(center: Offset(size.width / 2, -60), radius: size.height * 0.5),
          ),
      );
      _cached = recorder.endRecording();
    }
    canvas.drawPicture(_cached!);
  }

  void _drawInterlacedZellij(Canvas canvas, Offset c, double r, Paint p) {
    // 8-point star with multiple layers
    final Path star1 = Path();
    final Path star2 = Path();

    for (int i = 0; i < 16; i++) {
      final double angle = i * math.pi / 8;
      final double dist1 = i.isEven ? r : r * 0.65;
      final double dist2 = i.isEven ? r * 0.8 : r * 0.5;

      final double px1 = c.dx + dist1 * math.cos(angle);
      final double py1 = c.dy + dist1 * math.sin(angle);
      final double px2 = c.dx + dist2 * math.cos(angle);
      final double py2 = c.dy + dist2 * math.sin(angle);

      if (i == 0) {
        star1.moveTo(px1, py1);
        star2.moveTo(px2, py2);
      } else {
        star1.lineTo(px1, py1);
        star2.lineTo(px2, py2);
      }
    }
    star1.close();
    star2.close();
    canvas.drawPath(star1, p);
    canvas.drawPath(star2, p);

    // Interlacing lines connecting outer tips to neighbors
    const int points = 8;
    for (int i = 0; i < points; i++) {
        final double angle = i * math.pi / 4;
        final double px = c.dx + r * math.cos(angle);
        final double py = c.dy + r * math.sin(angle);

        // Lines going outwards towards neighbors
        canvas.drawLine(Offset(px, py), Offset(c.dx + r * 1.3 * math.cos(angle), c.dy + r * 1.3 * math.sin(angle)), p);
    }

    // Octagonal frame
    final Path oct = Path();
    for (int i = 0; i < 8; i++) {
        final double angle = i * math.pi / 4 + math.pi / 8;
        final double px = c.dx + r * 1.1 * math.cos(angle);
        final double py = c.dy + r * 1.1 * math.sin(angle);
        if (i == 0) {
          oct.moveTo(px, py);
        } else {
          oct.lineTo(px, py);
        }
    }
    oct.close();
    canvas.drawPath(oct, p);
  }

  @override
  bool shouldRepaint(covariant AdhkarBgPainter o) =>
      o.nightColor != nightColor || o.goldColor != goldColor;
}

// ── Asma Pattern (Geometric Octagons) ──
class AsmaBgPainter extends CustomPainter {
  final Color goldColor;
  static Picture? _cached;
  static Size? _cachedSize;
  static Color? _cachedColor;

  AsmaBgPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (_cached == null || _cachedSize != size || _cachedColor != goldColor) {
      _cachedSize = size;
      _cachedColor = goldColor;
      final recorder = PictureRecorder();
      final c = Canvas(recorder);

      final p = Paint()
        ..color = goldColor.withOpacity(0.05)
        ..strokeWidth = 0.7
        ..style = PaintingStyle.stroke;

      const step = 110.0;
      for (double x = 0; x < size.width + step; x += step) {
        for (double y = 0; y < size.height + step; y += step) {
          final isOdd = (x / step).round().isOdd;
          final py = isOdd ? y + step / 2 : y;
          _drawTwelveFoldStar(c, Offset(x, py), step * 0.48, p);
        }
      }
      _cached = recorder.endRecording();
    }
    canvas.drawPicture(_cached!);
  }

  void _drawTwelveFoldStar(Canvas canvas, Offset c, double r, Paint p) {
    // 12-point star with interlaced look
    final Path star = Path();
    for (int i = 0; i < 24; i++) {
      final double angle = i * math.pi / 12;
      final double dist = i.isEven ? r : r * 0.75;
      final double px = c.dx + dist * math.cos(angle);
      final double py = c.dy + dist * math.sin(angle);
      if (i == 0) {
        star.moveTo(px, py);
      } else {
        star.lineTo(px, py);
      }
    }
    star.close();
    canvas.drawPath(star, p);

    // Core detail
    canvas.drawCircle(c, r * 0.35, p);

    // Outer secondary stars (6-pointed) at key angles
    for (int i = 0; i < 6; i++) {
        final double angle = i * math.pi / 3;
        final Offset sPos = Offset(c.dx + r * 1.1 * math.cos(angle), c.dy + r * 1.1 * math.sin(angle));
        _drawSmallSixPtStar(canvas, sPos, r * 0.25, p);
    }

    // Connecting lines for interlocking effect
    for (int i = 0; i < 12; i++) {
        final double angle = i * math.pi / 6;
        final double px1 = c.dx + r * 0.75 * math.cos(angle);
        final double py1 = c.dy + r * 0.75 * math.sin(angle);
        final double px2 = c.dx + r * 1.25 * math.cos(angle);
        final double py2 = c.dy + r * 1.25 * math.sin(angle);
        canvas.drawLine(Offset(px1, py1), Offset(px2, py2), p);
    }
  }

  void _drawSmallSixPtStar(Canvas canvas, Offset center, double r, Paint p) {
      final Path star = Path();
      for (int i = 0; i < 12; i++) {
        final double angle = i * math.pi / 6;
        final double dist = i.isEven ? r : r * 0.577;
        final double px = center.dx + dist * math.cos(angle);
        final double py = center.dy + dist * math.sin(angle);
        if (i == 0) {
          star.moveTo(px, py);
        } else {
          star.lineTo(px, py);
        }
      }
      star.close();
      canvas.drawPath(star, p);
  }

  @override
  bool shouldRepaint(covariant AsmaBgPainter o) => o.goldColor != goldColor;
}
