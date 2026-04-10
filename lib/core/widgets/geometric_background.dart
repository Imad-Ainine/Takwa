import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GeometricBackground extends StatelessWidget {
  final Color? color;
  final double? opacity;
  final double? strokeWidth;
  final double? spacing;

  const GeometricBackground({
    super.key,
    this.color,
    this.opacity,
    this.strokeWidth,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: GeometricPainter(
          color: color ?? AppColors.gold,
          opacity: opacity ?? 0.08,
          strokeWidth: strokeWidth ?? 0.7,
          spacing: spacing ?? 48.0,
        ),
      ),
    );
  }
}

class GeometricPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double strokeWidth;
  final double spacing;

  GeometricPainter({
    required this.color,
    required this.opacity,
    required this.strokeWidth,
    required this.spacing,
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

    // Optional subtle radial gradients can be added here if needed, 
    // but the pure geometric lines are the core pattern.
  }

  @override
  bool shouldRepaint(covariant GeometricPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.strokeWidth != strokeWidth ||
      old.spacing != spacing;
}
