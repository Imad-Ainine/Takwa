import 'package:flutter/material.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/curved_edges.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  final bool isCurved;
  final bool showBackground;
  final Widget? child;
  final Color? firstShade;
  final Color? secondShade;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.height = 160,
    this.isCurved = true,
    this.showBackground = true,
    this.child,
    this.firstShade,
    this.secondShade,
  });

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _AppBarWidgetState extends State<AppBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _floatingAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Whether a caller-supplied gradient is active.
    final hasCustomGradient =
        widget.firstShade != null && widget.secondShade != null;

    // Use caller gradient, or pick a theme-appropriate default.
    final gradient = hasCustomGradient
        ? LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [widget.firstShade!, widget.secondShade!],
          )
        : (isDark
              ? LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    colors.gold.withOpacity(0.75),
                    colors.background.withOpacity(0.85),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    colors.background.withOpacity(0.65),
                    colors.gold.withOpacity(0.80),
                  ],
                ));

    // Title is always white when shown on a gradient for maximum contrast.
    // When there is no background, fall back to the theme's text primary.
    final titleColor = widget.showBackground
        ? Colors.white
        : colors.textPrimary;

    // Decorative circle opacities adapt to brightness so they stay subtle in
    // light mode and properly atmospheric in dark mode.
    final circleAlphaA = isDark ? 0.05 : 0.15;
    final circleAlphaB = isDark ? 0.20 : 0.22;
    final circleAlphaC = isDark ? 0.10 : 0.18;

    final circleColorA = Colors.white.withOpacity(circleAlphaA);
    final circleColorB = (widget.secondShade ?? colors.gold).withOpacity(
      circleAlphaB,
    );
    final circleColorC = Colors.white.withOpacity(circleAlphaC);

    return TCurvedEdgeWidget(
      isCurved: widget.isCurved,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            if (widget.showBackground)
              Container(
                decoration: BoxDecoration(gradient: gradient),
                child: CustomPatternBackground(
                  pattern: BackgroundPattern.adhkar,
                  // Slightly lower opacity in light mode so the pattern stays subtle.
                  opacity: isDark ? 0.08 : 0.05,
                ),
              ),

            // ── Animated Decorative Circles ──────────────────────────
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      bottom: -20 + _floatingAnimation.value,
                      left: -40,
                      child: Transform.scale(
                        scale: _breathingAnimation.value,
                        child: TCirculerContainer(
                          width: 150,
                          height: 150,
                          backgroundColor: circleColorA,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40 - _floatingAnimation.value,
                      right: -30,
                      child: Transform.scale(
                        scale: 2.0 - _breathingAnimation.value,
                        child: TCirculerContainer(
                          width: 100,
                          height: 100,
                          backgroundColor: circleColorB,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -80 + _floatingAnimation.value * 0.5,
                      right: 110,
                      child: Transform.scale(
                        scale: _breathingAnimation.value,
                        child: TCirculerContainer(
                          width: 140,
                          height: 140,
                          backgroundColor: circleColorC,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // ── AppBar Content ───────────────────────────────────────
            SafeArea(
              child:
                  widget.child ??
                  Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: Text(
                          widget.title,
                          style: typography.headingMedium.copyWith(
                            color: titleColor,
                            fontSize: 22,
                            letterSpacing: 0.5,
                            shadows: widget.showBackground
                                ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.40 : 0.20,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        centerTitle: true,
                        leading: widget.leading,
                        actions: widget.actions,
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
