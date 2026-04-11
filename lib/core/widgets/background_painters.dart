import 'dart:math' as math;
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
    this.strokeWidth = 0.7,
    this.spacing = 48.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), p);
    }
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

  StatsBgPainter({required this.nightColor, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = nightColor,
    );
    final p = Paint()..color = dotColor;
    for (double x = 16; x < size.width; x += 28) {
      for (double y = 16; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StatsBgPainter o) =>
      o.nightColor != nightColor || o.dotColor != dotColor;
}

// ── Duas Pattern ──
class DuasBgPainter extends CustomPainter {
  final Color goldColor;
  DuasBgPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = goldColor.withOpacity(0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (double x = 0; x < size.width + 52; x += 52) {
      for (double y = 0; y < size.height + 52; y += 52) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          final pt = Offset(x + 16 * math.cos(a), y + 16 * math.sin(a));
          i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
        }
        path.close();
        canvas.drawPath(path, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DuasBgPainter o) => o.goldColor != goldColor;
}

// ── Qibla Pattern ──
class QiblaBgPainter extends CustomPainter {
  final Color goldColor;
  QiblaBgPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.45);
    for (int i = 1; i <= 6; i++) {
      canvas.drawCircle(
        c,
        i * 52.0,
        Paint()
          ..color = goldColor.withOpacity(0.03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant QiblaBgPainter o) => o.goldColor != goldColor;
}

// ── Checklist Subtle Pattern ──
class SubtleBgPainter extends CustomPainter {
  final Color nightColor;
  final Color goldColor;

  SubtleBgPainter({required this.nightColor, required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = nightColor,
    );
    final p = Paint()
      ..color = goldColor.withOpacity(0.04)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant SubtleBgPainter old) =>
      old.nightColor != nightColor || old.goldColor != goldColor;
}

// ── Adhkar Pattern ──
class AdhkarBgPainter extends CustomPainter {
  final Color nightColor;
  final Color goldColor;

  AdhkarBgPainter({required this.nightColor, required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = nightColor,
    );

    final p = Paint()
      ..color = goldColor.withOpacity(0.04)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    const s = 60.0;
    for (double x = 0; x < size.width + s; x += s) {
      for (double y = 0; y < size.height + s; y += s) {
        _drawStar(canvas, Offset(x, y), s * 0.35, p);
      }
    }

    canvas.drawCircle(
      Offset(size.width / 2, -40),
      200,
      Paint()
        ..shader = RadialGradient(
          colors: [goldColor.withOpacity(0.07), Colors.transparent],
        ).createShader(
          Rect.fromCircle(center: Offset(size.width / 2, -40), radius: 200),
        ),
    );
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final rr = i.isEven ? r : r * 0.5;
      final x = c.dx + rr * math.cos(angle - math.pi / 2);
      final y = c.dy + rr * math.sin(angle - math.pi / 2);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant AdhkarBgPainter o) =>
      o.nightColor != nightColor || o.goldColor != goldColor;
}
