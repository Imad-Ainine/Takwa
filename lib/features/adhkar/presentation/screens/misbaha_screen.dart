import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/adhkar_providers.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/features/adhkar/providers/misbaha_provider.dart';

class MisbahaScreen extends ConsumerStatefulWidget {
  const MisbahaScreen({super.key});

  @override
  ConsumerState<MisbahaScreen> createState() => _MisbahaScreenState();
}

class _MisbahaScreenState extends ConsumerState<MisbahaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    ref.read(misbahaProvider.notifier).increment();
    _pulseCtrl.forward(from: 0);
  }

  void _onLongPressStart(LongPressStartDetails _) {
    HapticFeedback.heavyImpact();
    ref.read(misbahaProvider.notifier).listen(true);
  }

  void _onLongPressEnd(LongPressEndDetails _) {
    ref.read(misbahaProvider.notifier).listen(false);
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);
    final state = ref.watch(misbahaProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: style.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(pattern: BackgroundPattern.duas),
            ),

            // Decorative Glows
            Positioned(
              top: -100,
              right: -100,
              child: _buildGlow(style.gold.withOpacity(0.15), 300),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _buildGlow(style.teal.withOpacity(0.1), 250),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(style, context),
                  const Spacer(),
                  _buildDhikrSelector(state, style, context),
                  const Spacer(),
                  _buildCounterDisplay(state, style),
                  const Spacer(),
                  _buildMainBead(state, style),
                  const Spacer(),
                  _buildBottomControls(state, style),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: size, spreadRadius: size / 2),
        ],
      ),
    );
  }

  Widget _buildHeader(AdaptiveStyle style, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomLeadingButton(),
          Column(
            children: [
              Text(
                'المسبحة الإلكترونية',
                style: style.amiri(22, color: style.gold),
              ),
              Text(
                'ألا بذكر الله تطمئن القلوب',
                style: style.naskh(11, color: style.textSec),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDhikrSelector(
    MisbahaState state,
    AdaptiveStyle style,
    BuildContext context,
  ) {
    final hasDhikr = state.selectedDhikr != null;
    return GestureDetector(
      onTap: () => _showDhikrListModal(style, context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: style.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasDhikr ? style.gold.withOpacity(0.5) : style.border,
          ),
          boxShadow: [
            BoxShadow(
              color: style.gold.withOpacity(hasDhikr ? 0.1 : 0),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, color: style.gold, size: 18),
                const SizedBox(width: 8),
                Text(
                  hasDhikr ? 'الذكر المحدد' : 'اختر ذكراً (اختياري)',
                  style: style.naskh(12, color: style.gold),
                ),
                if (hasDhikr) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(misbahaProvider.notifier).clearDhikr();
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: style.textSec,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
            if (hasDhikr) ...[
              const SizedBox(height: 12),
              Text(
                state.selectedDhikr!.arabic,
                textAlign: TextAlign.center,
                style: style.amiri(18, color: style.text),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCounterDisplay(MisbahaState state, AdaptiveStyle style) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator around the number
            if (state.selectedDhikr != null)
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: state.count / state.selectedDhikr!.count,
                  strokeWidth: 4,
                  color: style.gold.withOpacity(0.6),
                  backgroundColor: style.gold.withOpacity(0.05),
                ),
              ),
            Column(
              children: [
                Text(
                  '${state.count}',
                  style: GoogleFonts.amiri(
                    fontSize: 90,
                    fontWeight: FontWeight.bold,
                    color: style.text,
                    height: 1.0,
                  ),
                ),
                if (state.selectedDhikr != null)
                  Text(
                    '/ ${state.selectedDhikr!.count}',
                    style: style.naskh(16, color: style.gold.withOpacity(0.7)),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainBead(MisbahaState state, AdaptiveStyle style) {
    return Column(
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.92).animate(
            CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOutBack),
          ),
          child: GestureDetector(
            onTap: _onTap,
            onLongPressStart: _onLongPressStart,
            onLongPressEnd: _onLongPressEnd,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse Animation Background
                if (state.isListening) _ListeningRipple(color: style.teal),

                // The Main Bead
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: state.isListening
                          ? [style.teal, style.teal.withOpacity(0.7)]
                          : [style.gold, style.goldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (state.isListening ? style.teal : style.gold)
                            .withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.isListening
                                ? Icons.mic_rounded
                                : Icons.fingerprint_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.isListening
                                ? 'جاري الاستماع...'
                                : 'انقر أو اضغط مطولاً',
                            style: style.naskh(
                              12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(MisbahaState state, AdaptiveStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Reset Button
          _buildActionButton(
            icon: Icons.refresh_rounded,
            label: 'إعادة',
            color: style.textSec,
            onTap: () => ref.read(misbahaProvider.notifier).reset(),
          ),

          // Sound Toggle? (Optional extra)
          _buildActionButton(
            icon: state.isSpeaking
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            label: 'الصوت',
            color: state.selectedDhikr == null ? style.textDim : style.gold,
            onTap: state.selectedDhikr == null
                ? null
                : () => ref.read(misbahaProvider.notifier).speakDhikr(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoNaskhArabic(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }

  void _showDhikrListModal(AdaptiveStyle style, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: style.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (_, controller) {
              final allItems = kAdhkarData.values
                  .expand((list) => list)
                  .toList();
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: style.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('اختر ذكراً', style: style.amiri(24, color: style.gold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: allItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final dhikr = allItems[i];
                        return _buildDhikrItem(dhikr, style, ctx);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDhikrItem(
    DhikrItem dhikr,
    AdaptiveStyle style,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(misbahaProvider.notifier).selectDhikr(dhikr);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: style.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dhikr.arabic,
                style: style.amiri(18, color: style.text, height: 1.4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: style.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${dhikr.count}',
                style: style.naskh(
                  14,
                  color: style.gold,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningRipple extends StatefulWidget {
  final Color color;
  const _ListeningRipple({required this.color});

  @override
  State<_ListeningRipple> createState() => _ListeningRippleState();
}

class _ListeningRippleState extends State<_ListeningRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Transform.scale(
                scale: 1.0 + (_ctrl.value + i / 3) % 1.0 * 1.5,
                child: Opacity(
                  opacity: (1.0 - (_ctrl.value + i / 3) % 1.0).clamp(0.0, 1.0),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
