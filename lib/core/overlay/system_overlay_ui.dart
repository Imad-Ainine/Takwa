import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/primary_button.dart';

/// The root widget specifically for the `flutter_overlay_window` isolate.
class SystemOverlayUI extends StatefulWidget {
  const SystemOverlayUI({super.key});

  @override
  State<SystemOverlayUI> createState() => _SystemOverlayUIState();
}

class _SystemOverlayUIState extends State<SystemOverlayUI>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  // The payload data
  Map<String, dynamic>? _data;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeInBack,
          ),
        );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    // Listen to messages from the main app
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is String) {
        try {
          final payload = jsonDecode(event);
          if (payload is Map<String, dynamic>) {
            setState(() {
              _data = payload;
            });
            _animController.forward();
            // Auto close after duration
            Future.delayed(const Duration(seconds: 8), _closeOverlay);
          }
        } catch (e) {
          debugPrint("Failed to decode overlay payload: $e");
        }
      }
    });
  }

  void _closeOverlay() async {
    if (_isClosing) return;
    _isClosing = true;
    if (mounted) {
      await _animController.reverse();
    }
    await FlutterOverlayWindow.closeOverlay();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<TextSpan> _buildHighlightedText(String text) {
    const highlightWords = [
      'أعوذ',
      'اللهم',
      'الله',
      'لا إله إلا الله',
      'سبحان',
      'الحمد لله',
      'الله أكبر',
      'أستغفر',
      'الجنة',
      'النار',
    ];

    // We do a simple split and match for highlights
    // For a more robust approach, regex word boundaries can be used.
    // However, Arabic word boundaries are tricky.
    // We'll use a basic word-by-word builder.
    final words = text.split(RegExp(r'\s+'));
    List<TextSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      final w = words[i];
      // strip punctuation for matching
      final cleanW = w.replaceAll(RegExp(r'[،.,؛:]'), '');

      bool isHighlighted = false;
      for (final hl in highlightWords) {
        if (cleanW == hl || cleanW.startsWith(hl)) {
          isHighlighted = true;
          break;
        }
      }

      spans.add(
        TextSpan(
          text: '$w ',
          style: GoogleFonts.amiri(
            fontSize: 18,
            color: isHighlighted
                ? Colors.red.shade700
                : const Color(0xFF1F2937),
            height: 1.6,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      );
    }
    return spans;
  }

  Widget _buildAdhkarView(
    String label,
    String emoji,
    String arabic,
    String? source,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo/Icon on the right (RTL makes it visually right)
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF141A29), // Brand dark blue
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'تقوى',
                    style: TextStyle(
                      color: Color(0xFFC5A365),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoNaskhArabic',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(children: _buildHighlightedText(arabic)),
                ),
              ),
              // Close button
              Align(
                alignment: Alignment.topCenter,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  onPressed: _closeOverlay,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          if (source != null && source.toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 56), // spacer for the icon
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    source,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 10,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdhanView(
    String label,
    String emoji,
    String arabic,
    String? source,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              Text(
                'حان وقت الصلاة',
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  color: const Color(0xFFC5A365),
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF8A93A6),
                  size: 24,
                ),
                onPressed: _closeOverlay,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFC5A365).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 24),
          Text(
            label, // e.g. "أذان العشاء"
            style: GoogleFonts.amiri(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            arabic, // e.g. حَيَّ عَلَى الصَّلَاةِ ، حَيَّ عَلَى الْفَلَاحِ
            style: GoogleFonts.amiri(
              fontSize: 20,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'إغلاق',
              onTap: _closeOverlay,
              baseColor: const Color(0xFFC5A365),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const SizedBox.shrink();
    }

    final arabic = _data!['arabic'] ?? '';
    final type = _data!['type'] ?? 'adhkar'; // 'adhkar' or 'dua'
    final label = _data!['label'] ?? '';
    final emoji = _data!['emoji'] ?? '📿';
    final source = _data!['source'];
    final isAdhan = type == 'adhan';

    return Material(
      color: Colors.transparent,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          onTap: () {
            // Can open app intent here if necessary
            _closeOverlay();
          },
          onHorizontalDragUpdate: (details) {
            if (details.primaryDelta! > 10) {
              _closeOverlay();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isAdhan
                          ? const Color(0xFF141A29).withOpacity(0.95)
                          : Colors.white.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isAdhan
                            ? const Color(0xFFC5A365).withOpacity(0.4)
                            : const Color(0xFFC5A365),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC5A365).withOpacity(0.12),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Background pattern
                        if (isAdhan)
                          const Positioned.fill(
                            child: CustomPatternBackground(
                              pattern: BackgroundPattern.geometric,
                            ),
                          ),

                        // Content
                        if (type == 'adhan')
                          _buildAdhanView(label, emoji, arabic, source)
                        else
                          _buildAdhkarView(label, emoji, arabic, source),

                        // Progress Bar Tracker
                        Positioned(
                          bottom: 0,
                          left: 20,
                          right: 20,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1.0, end: 0.0),
                            duration: const Duration(seconds: 8),
                            builder: (context, value, _) {
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 3,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFC5A365).withOpacity(0.6),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
