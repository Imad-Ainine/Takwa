import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'custom_pattern_background.dart';

/// A premium, animated primary button unified across the application.
class PrimaryButton extends StatefulWidget {
  final String label;
  final FutureOr<void> Function()? onTap;
  final IconData? icon;
  final Color? baseColor;
  final Widget? customContent;
  final bool isOutline;
  final bool isLoading;
  final bool isBg;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.baseColor,
    this.customContent,
    this.isOutline = false,
    this.isLoading = false,
    this.isBg = true,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || widget.isLoading || _loading;
    final primaryColor = widget.baseColor ?? AppColors.gold;
    // We add a slightly darker shade for the gradient. Color(0xFFB8920E) was used for gold.
    // If a custom color is provided, we can slightly darken it for the gradient end color.
    final endColor = widget.baseColor != null
        ? HSLColor.fromColor(widget.baseColor!)
              .withLightness(
                (HSLColor.fromColor(widget.baseColor!).lightness - 0.1).clamp(
                  0.0,
                  1.0,
                ),
              )
              .toColor()
        : const Color(0xFFB8920E);

    return GestureDetector(
      onTapDown: disabled
          ? null
          : (_) {
              _ctrl.forward();
              HapticFeedback.mediumImpact();
            },
      onTapUp: disabled
          ? null
          : (_) async {
              _ctrl.reverse();
              setState(() => _loading = true);
              await widget.onTap!();
              if (mounted) setState(() => _loading = false);
            },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1,
          end: 0.96,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: (disabled || widget.isOutline)
                ? null
                : LinearGradient(colors: [primaryColor, endColor]),
            color: disabled
                ? AppColors.border
                : widget.isOutline
                ? Colors.transparent
                : null,
            borderRadius: BorderRadius.circular(24),
            border: widget.isOutline
                ? Border.all(color: primaryColor.withOpacity(0.5), width: 1.5)
                : null,
            boxShadow: (disabled || widget.isOutline)
                ? null
                : [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!disabled && !widget.isOutline)
                if (widget.isBg)
                  const Positioned.fill(
                    child: CustomPatternBackground(
                      pattern: BackgroundPattern.eightWithCrosses,
                    ),
                  ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _loading
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.night,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : widget.customContent ??
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  size: 18,
                                  color: widget.isOutline
                                      ? primaryColor
                                      : AppColors.night,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.label,
                                style: GoogleFonts.notoNaskhArabic(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: disabled
                                      ? AppColors.textDim
                                      : widget.isOutline
                                      ? primaryColor
                                      : AppColors.night,
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
