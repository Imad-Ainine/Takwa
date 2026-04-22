import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/features/qiyam/domain/models/qiyam_session.dart';
import 'package:takwa/features/qiyam/providers/qiyam_providers.dart';
import 'package:takwa/app/main_shell.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_pattern_background.dart';
import '../../../../core/widgets/custom_leading_button.dart';
import '../widgets/qiyam_onboarding_overlay.dart';

class QiyamDashboardScreen extends ConsumerStatefulWidget {
  const QiyamDashboardScreen({super.key});

  @override
  ConsumerState<QiyamDashboardScreen> createState() =>
      _QiyamDashboardScreenState();
}

class _QiyamDashboardScreenState extends ConsumerState<QiyamDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  late final AudioPlayer _audioPlayer;

  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _audioPlayer = AudioPlayer();
    
    // Trigger banner when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _showBanner = true);
      }
    });
  }

  Future<void> _playWelcomeSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/ayah.mp3');
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing welcome sound: $e');
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to tab changes
    ref.listen(currentTabProvider, (prev, next) {
      if (next == 1) {
        // Trigger banner when switching to this tab
        if (mounted) {
          setState(() => _showBanner = true);
        }
      }
    });

    final session = ref.watch(qiyamSessionProvider);
    final onboardingDone =
        ref.watch(qiyamOnboardingDoneProvider).valueOrNull ?? true;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // Background System
          const Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, session),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPlanSelector(context, session),
                        const SizedBox(height: 20),
                        _buildTimerRing(context, session),
                        const SizedBox(height: 40),
                        _buildStageInfo(context, session),
                        const SizedBox(height: 20),
                        _buildStoriesButton(context),
                        const SizedBox(height: 20),
                        _buildControls(context, session),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Banner Notification Overlay
          if (_showBanner && onboardingDone)
            _IntroBannerNotification(
              onDismiss: () => setState(() => _showBanner = false),
            ),

          // Onboarding Overlay
          if (!onboardingDone)
            const Positioned.fill(child: QiyamOnboardingOverlay()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QiyamSessionState session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomLeadingButton(),
          Column(
            children: [
              Text(
                'قيام الليل',
                style: context.typography.displayMedium.copyWith(
                  fontSize: 22,
                  color: context.colors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'المرحلة ${session.currentStageIndex + 1} من ${session.stages.length}',
                style: context.typography.caption.copyWith(
                  color: context.colors.textDim,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.qiyamCalculator),
            icon: Icon(Icons.calculate_outlined, color: context.colors.gold),
          ),
        ],
      ),
    );
  }


  Widget _buildPlanSelector(BuildContext context, QiyamSessionState session) {
    final durations = [5, 10, 15, 20, 30];
    final currentDuration = session.stages.first.defaultDuration.inMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'اختر مدة المرحلة',
            style: context.typography.caption.copyWith(
              color: context.colors.textDim,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: durations.map((mins) {
              final isSelected = currentDuration == mins;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(qiyamSessionProvider.notifier)
                        .updatePlanDuration(Duration(minutes: mins));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.gold.withOpacity(0.1)
                          : context.colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.gold
                            : context.colors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$mins د',
                          style: context.typography.bodyLarge.copyWith(
                            color: isSelected
                                ? context.colors.gold
                                : context.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'مرحلة',
                          style: context.typography.caption.copyWith(
                            color: isSelected
                                ? context.colors.gold.withOpacity(0.7)
                                : context.colors.textDim,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerRing(BuildContext context, QiyamSessionState session) {
    final stage = session.currentStage;
    final progress =
        session.elapsed.inSeconds / stage.defaultDuration.inSeconds;

    return ScaleTransition(
      scale: _pulse,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: stage.color.withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Circular Progress
          SizedBox(
            width: 240,
            height: 240,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: context.colors.border.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(stage.color),
            ),
          ),
          // Main Circle Content
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.colors.card, context.colors.night],
              ),
              border: Border.all(color: stage.color.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stage.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(
                    (stage.defaultDuration - session.elapsed).isNegative
                        ? Duration.zero
                        : stage.defaultDuration - session.elapsed,
                  ),
                  style: context.typography.displayLarge.copyWith(
                    fontSize: 36,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'الوقت المتبقي',
                  style: context.typography.caption.copyWith(
                    color: context.colors.textDim,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageInfo(BuildContext context, QiyamSessionState session) {
    final stage = session.currentStage;
    return Column(
      children: [
        Text(
          stage.title,
          style: context.typography.displayMedium.copyWith(
            fontSize: 28,
            color: context.colors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stage.subtitle,
          style: context.typography.bodyLarge.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, QiyamSessionState session) {
    final isRunning = session.status == QiyamStageStatus.running;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Next
          _buildCircleButton(
            icon: Icons.skip_next,
            onPressed: () =>
                ref.read(qiyamSessionProvider.notifier).nextStage(),
          ),

          // Play/Pause
          GestureDetector(
            onTap: () {
              final notifier = ref.read(qiyamSessionProvider.notifier);
              if (isRunning) {
                notifier.pauseSession();
              } else {
                notifier.startSession();
              }
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [context.colors.gold, context.colors.teal],
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.gold.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                isRunning ? Icons.pause : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          // Previous
          _buildCircleButton(
            icon: Icons.skip_previous,
            onPressed: () =>
                ref.read(qiyamSessionProvider.notifier).previousStage(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.border),
        ),
        child: Icon(icon, color: context.colors.textPrimary),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildStoriesButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.pushNamed(context, Routes.qiyamStories),
      icon: Icon(Icons.auto_stories, color: context.colors.gold, size: 20),
      label: Text(
        'عجائب وقصص القيام',
        style: context.typography.bodyMedium.copyWith(
          color: context.colors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: context.colors.gold.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: context.colors.gold.withOpacity(0.3)),
        ),
      ),
    );
  }
}

class _IntroBannerNotification extends StatefulWidget {
  final VoidCallback onDismiss;
  const _IntroBannerNotification({required this.onDismiss});

  @override
  State<_IntroBannerNotification> createState() =>
      _IntroBannerNotificationState();
}

class _IntroBannerNotificationState extends State<_IntroBannerNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _ctrl.forward();

    // Auto dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        _handleDismiss();
      }
    });
  }

  void _handleDismiss() {
    _ctrl.reverse().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    context.colors.gold,
                    context.colors.goldDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.gold.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🌙', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'قيام الليل',
                          style: context.typography.headingMedium.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'برنامج متكامل لصلاة الليل... خطوة للقرب من الله.',
                          style: context.typography.caption.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _handleDismiss,
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
