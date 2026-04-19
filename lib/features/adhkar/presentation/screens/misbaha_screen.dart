import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/adhkar_providers.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
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
    HapticFeedback.lightImpact();
    ref.read(misbahaProvider.notifier).increment();
    _pulseCtrl.forward(from: 0);
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
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(style, context),
                  const Spacer(flex: 1),
                  _buildDhikrSelector(state, style, context),
                  const Spacer(flex: 1),
                  _buildCounter(state, style),
                  const Spacer(flex: 2),
                  _buildTapArea(style),
                  const Spacer(flex: 1),
                  _buildControls(state, style),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdaptiveStyle style, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: style.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: style.text,
              ),
            ),
          ),
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

  Widget _buildCounter(MisbahaState state, AdaptiveStyle style) {
    return Column(
      children: [
        Text(
          '${state.count}',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: style.text,
            height: 1.0,
          ),
        ),
        if (state.selectedDhikr != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: style.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.gold.withOpacity(0.3)),
            ),
            child: Text(
              'الهدف: ${state.selectedDhikr!.count}',
              style: style.naskh(14, color: style.gold),
            ),
          ),
      ],
    );
  }

  Widget _buildTapArea(AdaptiveStyle style) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOutBack)),
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [style.gold, style.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: style.gold.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: style.bg.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.touch_app_rounded,
                  size: 64,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(MisbahaState state, AdaptiveStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset
          _buildControlButton(
            icon: Icons.refresh_rounded,
            color: style.textSec,
            bgColor: style.card,
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(misbahaProvider.notifier).reset();
            },
          ),

          // // Voice
          // _buildControlButton(
          //   icon: state.isListening
          //       ? Icons.mic_rounded
          //       : Icons.mic_none_rounded,
          //   color: Colors.white,
          //   bgColor: state.isListening ? Colors.redAccent : style.teal,
          //   size: 64,
          //   iconSize: 32,
          //   onTap: () {
          //     HapticFeedback.mediumImpact();
          //     ref.read(misbahaProvider.notifier).listen();
          //   },
          // ),

          // // TTS (Speak)
          // _buildControlButton(
          //   icon: state.isSpeaking
          //       ? Icons.stop_rounded
          //       : Icons.volume_up_rounded,
          //   color: state.selectedDhikr == null
          //       ? style.textSec.withOpacity(0.3)
          //       : style.textSec,
          //   bgColor: style.card,
          //   onTap: state.selectedDhikr == null
          //       ? () {}
          //       : () {
          //           HapticFeedback.mediumImpact();
          //           ref.read(misbahaProvider.notifier).speakDhikr();
          //         },
          // ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    double size = 48,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: iconSize),
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

  void _showDhikrListModal(AdaptiveStyle style, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: style.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            final allItems = kAdhkarData.values.expand((list) => list).toList();
            return Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: style.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('اختر ذكراً', style: style.amiri(20, color: style.gold)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: allItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final dhikr = allItems[i];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(misbahaProvider.notifier).selectDhikr(dhikr);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: style.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: style.border),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dhikr.arabic,
                                textAlign: TextAlign.center,
                                style: style.amiri(16, color: style.text),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: style.gold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'الهدف: ${dhikr.count}',
                                  style: style.naskh(12, color: style.gold),
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
            );
          },
        );
      },
    );
  }
}
