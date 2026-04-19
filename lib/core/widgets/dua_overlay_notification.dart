import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_pattern_background.dart';
import '../theme/app_theme.dart';
import 'package:takwa/features/duas/presentation/screens/duas_screen.dart';

// ═══════════════════════════════════════════════════════════════
//  CUSTOM IN-APP DUA OVERLAY NOTIFICATION
// ═══════════════════════════════════════════════════════════════

class DuaOverlayNotification {
  static OverlayEntry? _overlayEntry;
  static bool get isShowing => _overlayEntry != null;

  /// Shows the custom in-app notification.
  /// Automatically dismisses after [duration].
  static void show(
    BuildContext context,
    DuaCategory category,
    DuaItem dua, {
    Duration duration = const Duration(seconds: 5),
  }) {
    dismiss();

    final overlayState = Overlay.of(context, rootOverlay: true);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _NotifCardOverlay(
          category: category,
          dua: dua,
          duration: duration,
          onDismiss: dismiss,
          onTap: () {
            dismiss();
            Navigator.of(context).pushNamed('/duas');
          },
        );
      },
    );

    overlayState.insert(_overlayEntry!);
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _NotifCardOverlay extends StatefulWidget {
  final DuaCategory category;
  final DuaItem dua;
  final Duration duration;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotifCardOverlay({
    required this.category,
    required this.dua,
    required this.duration,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotifCardOverlay> createState() => _NotifCardOverlayState();
}

class _NotifCardOverlayState extends State<_NotifCardOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInBack,
      ),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _animController.forward();

    _autoDismissTimer = Timer(widget.duration, _triggerDismiss);
  }

  void _triggerDismiss() {
    _autoDismissTimer?.cancel();
    if (mounted) {
      _animController.reverse().then((_) => widget.onDismiss());
    }
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (details.primaryDelta! > 10) {
      _triggerDismiss();
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: widget.onTap,
          onHorizontalDragUpdate: _handleSwipe,
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: context.decorations.card.copyWith(
                      color: context.colors.card.withOpacity(0.9),
                      border: Border.all(
                        color: context.colors.gold.withOpacity(0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.gold.withOpacity(0.12),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: CustomPatternBackground(
                            pattern: BackgroundPattern.geometric,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: context.colors.gold.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      widget.dua.emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'دعاء - ${widget.dua.occasion}',
                                          style: GoogleFonts.amiri(
                                            fontSize: 18,
                                            color: context.colors.gold,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                          ),
                                        ),
                                        Text(
                                          'انقر للمتابعة',
                                          style: context.typography.caption.copyWith(
                                            color: context.colors.textSecondary,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: context.colors.textDim,
                                      size: 20,
                                    ),
                                    onPressed: _triggerDismiss,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                widget.dua.arabic,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.typography.quranicVerse.copyWith(
                                  fontSize: 19,
                                  color: context.colors.textPrimary,
                                  height: 1.7,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              if (widget.dua.source.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.menu_book_rounded,
                                        color: context.colors.teal,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          widget.dua.source,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.typography.caption.copyWith(
                                            color: context.colors.teal,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    right: 20,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.lg),
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 0.0),
                        duration: widget.duration,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 3,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.gold.withOpacity(0.6),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
