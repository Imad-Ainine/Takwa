import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _bgController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Controller for the logo drop-in and fade-in
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Continuous controller for the background shapes/orbs
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
      ),
    );

    _mainController.forward();

    // Navigate to home after 3 seconds
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03122F),
      body: Stack(
        children: [
          // Elegant animated custom background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) => CustomPaint(
                painter: _AwesomeSplashPainter(time: _bgController.value),
              ),
            ),
          ),

          // Main Content
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Container with soft dynamic glow
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Soft Glow behind logo
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFC8A96E,
                                    ).withOpacity(0.3),
                                    blurRadius: 50,
                                    spreadRadius: 15,
                                  ),
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3AAFA9,
                                    ).withOpacity(0.2),
                                    blurRadius: 80,
                                    spreadRadius: 30,
                                  ),
                                ],
                              ),
                            ),

                            // The transparent animated logo
                            Image.asset(
                              'assets/images/hasib_nafsak_transparent_bg.png',
                              width: 170,
                              height: 170,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Elegant typography
                        Text(
                          'محاسبة النفس',
                          style: TextStyle(
                            fontFamily: 'Amiri', // Using Amiri as per pubspec
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFC8A96E), // Gold text
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFC8A96E).withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'رحلتك نحو الطمأنينة',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  AWESOME BACKGROUND PAINTER
// ─────────────────────────────────────────
class _AwesomeSplashPainter extends CustomPainter {
  final double time;

  _AwesomeSplashPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // We already have the dark blue #03122F as scaffold background.
    // Creating some soft floating glowing orbs and shapes

    // 1. Top left Teal Glow
    final paint1 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF3AAFA9).withOpacity(0.15),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * 0.1 + math.sin(time * 2 * math.pi) * 30,
                size.height * 0.1 + math.cos(time * 2 * math.pi) * 30,
              ),
              radius: 200,
            ),
          );
    canvas.drawCircle(
      Offset(
        size.width * 0.1 + math.sin(time * 2 * math.pi) * 30,
        size.height * 0.1 + math.cos(time * 2 * math.pi) * 30,
      ),
      200,
      paint1,
    );

    // 2. Bottom right Gold Glow
    final paint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFC8A96E).withOpacity(0.12),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * 0.9 + math.cos(time * 2 * math.pi) * 40,
                size.height * 0.85 + math.sin(time * 2 * math.pi) * 40,
              ),
              radius: 250,
            ),
          );
    canvas.drawCircle(
      Offset(
        size.width * 0.9 + math.cos(time * 2 * math.pi) * 40,
        size.height * 0.85 + math.sin(time * 2 * math.pi) * 40,
      ),
      250,
      paint2,
    );

    // 3. Draw a subtle geometric Islamic pattern grid / stars
    final paintGrid = Paint()
      ..color = const Color(0xFFC8A96E).withOpacity(0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final spacing = size.width / 6;
    for (double i = -size.height; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paintGrid,
      );
      canvas.drawLine(
        Offset(i + size.height, 0),
        Offset(i, size.height),
        paintGrid,
      );
    }

    // Draw some floating particles
    final particlePaint = Paint()
      ..color = const Color(0xFF3AAFA9).withOpacity(0.4);
    for (int i = 0; i < 15; i++) {
      // Pseudo-random deterministic movement
      double particleX =
          (size.width * (i * 0.1 + 0.1) +
              math.sin(time * 2 * math.pi + i) * 20) %
          size.width;
      double particleY =
          (size.height - (time * size.height * 0.4 + i * 50)) % size.height;

      canvas.drawCircle(
        Offset(particleX, particleY),
        1.5 + (i % 3),
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AwesomeSplashPainter old) => old.time != time;
}
