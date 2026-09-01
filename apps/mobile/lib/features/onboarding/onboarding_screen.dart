
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/providers/database_providers.dart';
import '../../core/notifications/notifications_service.dart';
import '../../core/notifications/overlay_background_service.dart';
import '../../core/supabase/supabase_config.dart';

// ── Enum for current step ──
enum OnboardStep {
  intro1,
  intro2,
  intro3,
  location,
  notifications,
  overlay,
  background,
  gender,
  // plan,
}

// ── State handling ──
class OnboardState {
  final OnboardStep step;
  final String? gender;
  final bool loading;

  OnboardState({required this.step, this.gender, this.loading = false});

  OnboardState copyWith({OnboardStep? step, String? gender, bool? loading}) {
    return OnboardState(
      step: step ?? this.step,
      gender: gender ?? this.gender,
      loading: loading ?? this.loading,
    );
  }
}

class OnboardNotifier extends StateNotifier<OnboardState> {
  OnboardNotifier() : super(OnboardState(step: OnboardStep.intro1));

  void next() {
    final nextStep = _getNextStep(state.step);
    if (nextStep != null) {
      state = state.copyWith(step: nextStep);
    }
  }

  void skip() {
    // Some steps might have special skip logic, for now just go next
    next();
  }

  void selectGender(String g) => state = state.copyWith(gender: g);

  OnboardStep? _getNextStep(OnboardStep current) {
    const steps = OnboardStep.values;
    final idx = steps.indexOf(current);
    if (idx < steps.length - 1) return steps[idx + 1];
    return null;
  }
}

final onboardProvider = StateNotifierProvider<OnboardNotifier, OnboardState>((
  ref,
) {
  return OnboardNotifier();
});

// ── Main Screen ──
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardProvider);
    final notifier = ref.read(onboardProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // Dynamic Background
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),

          // Content
          _buildStep(context, state, notifier, ref),

          // Header / Progress (Hidden for intro pages)
          if (!_isIntro(state.step))
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: _StepIndicator(current: state.step),
            ),
        ],
      ),
    );
  }

  bool _isIntro(OnboardStep step) =>
      step == OnboardStep.intro1 ||
      step == OnboardStep.intro2 ||
      step == OnboardStep.intro3;

  Widget _buildStep(
    BuildContext context,
    OnboardState state,
    OnboardNotifier notifier,
    WidgetRef ref,
  ) {
    switch (state.step) {
      case OnboardStep.intro1:
        return _IntroStep(data: _onboardPages[0], onNext: notifier.next);
      case OnboardStep.intro2:
        return _IntroStep(data: _onboardPages[1], onNext: notifier.next);
      case OnboardStep.intro3:
        return _IntroStep(data: _onboardPages[2], onNext: notifier.next);
      case OnboardStep.location:
        return _LocationStep(
          onAllow: () async {
            try {
              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                // If service is disabled, prompt user to enable it
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'GPS غير مفعّل، يرجى تفعيله للمتابعة.',
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 13,
                      ),
                    ),
                    action: SnackBarAction(
                      label: 'إعدادات',
                      textColor: Colors.white,
                      onPressed: () {
                        Geolocator.openLocationSettings();
                      },
                    ),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
                return; // Wait for them to enable it, we don't proceed yet
              }

              final p = await Geolocator.requestPermission().timeout(
                const Duration(seconds: 15),
              );

              if (p == LocationPermission.deniedForever) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'يرجى تفعيل إذن الموقع من الإعدادات.',
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 13,
                      ),
                    ),
                    action: SnackBarAction(
                      label: 'إعدادات',
                      textColor: Colors.white,
                      onPressed: () {
                        Geolocator.openAppSettings();
                      },
                    ),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
                return;
              }
              // We move forward even if denied or restricted (not forever), as long as it's not a permanent block that requires UI changes
              notifier.next();
            } catch (e) {
              notifier.next();
            }
          },
          onSkip: notifier.skip,
        );
      case OnboardStep.notifications:
        return _NotificationsStep(
          onAllow: () async {
            try {
              await NotificationsService.requestPermissions().timeout(
                const Duration(seconds: 20),
              );
              notifier.next();
            } catch (e) {
              notifier.next();
            }
          },
          onSkip: notifier.skip,
        );
      case OnboardStep.overlay:
        return _OverlayStep(
          onAllow: () async {
            // No longer wait for the full timeout. Trigger request and move on.
            // This prevents the "hanging" feeling if the system call is slow.
            try {
              OverlayBackgroundService.requestPermissions();
              // Give a tiny moment for the platform intent to fire, then go next.
              await Future.delayed(const Duration(milliseconds: 500));
              notifier.next();
            } catch (e) {
              notifier.next();
            }
          },
          onSkip: notifier.skip,
        );
      case OnboardStep.background:
        return _BackgroundStep(
          onAllow: () async {
            try {
              await NotificationsService.requestBackgroundPermission().timeout(
                const Duration(seconds: 15),
              );
              notifier.next();
            } catch (e) {
              notifier.next();
            }
          },
          onSkip: notifier.skip,
        );
      case OnboardStep.gender:
        return _GenderStep(
          selected: state.gender,
          onSelect: notifier.selectGender,
          onNext: () async {
            if (state.gender != null) {
              await ref.read(settingsDaoProvider).set('gender', state.gender!);
              try {
                await ref.read(supabaseServiceProvider).updateProfile({'gender': state.gender});
              } catch (e) {
                // Ignore error if offline
                print('Error updating gender: $e');
              }
            }
            await ref.read(settingsDaoProvider).set('onboardingDone', 'true');
            ref.invalidate(onboardingDoneProvider);
          },
          onSkip: () async {
            await ref.read(settingsDaoProvider).set('onboardingDone', 'true');
            ref.invalidate(onboardingDoneProvider);
          },
        );
      // case OnboardStep.plan:
      //   return _PlanStep(
      //     onStart: () async {
      //       await ref.read(settingsDaoProvider).set('onboardingDone', 'true');
      //       ref.invalidate(onboardingDoneProvider);
      //     },
      //   );
    }
  }
}

// ── Step Indicator ──
class _StepIndicator extends StatelessWidget {
  final OnboardStep current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    const setupSteps = [
      OnboardStep.location,
      OnboardStep.notifications,
      OnboardStep.overlay,
      OnboardStep.background,
      OnboardStep.gender,
      // OnboardStep.plan,
    ];
    final idx = setupSteps.indexOf(current);
    if (idx == -1) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: List.generate(setupSteps.length, (i) {
          final active = i <= idx;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.gold : AppColors.border,
                borderRadius: BorderRadius.circular(2),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── STEP 0: Intro Pages ──
class _IntroStep extends StatelessWidget {
  final _OnboardingPage data;
  final VoidCallback onNext;

  const _IntroStep({required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Expanded(
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 100)),
            ),
          ),
          _InfoCard(
            title: data.title,
            titleColor: AppColors.gold,
            subtitle: data.subtitle,
            hint: 'يمكنك التعديل لاحقًا',
            primaryLabel: 'استمرار',
            onPrimary: () async => onNext(),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title, subtitle, emoji;
  const _OnboardingPage(this.title, this.subtitle, this.emoji);
}

final _onboardPages = [
  const _OnboardingPage(
    'أهلاً بك في تقوى',
    'رفيقك في رحلة التزكية والقرب من الله عز وجل، من خلال أدوات ذكية ومميزة.',
    '🌙',
  ),
  const _OnboardingPage(
    'نظام المحاسبة الدقيق',
    'سجل صلواتك، أذكارك، وطاعاتك يومياً لترى تطورك وتثبّت عزيمتك.',
    '✅',
  ),
  const _OnboardingPage(
    'إحصائيات وتقدم',
    'تابِع نتائج محاسبتك عبر رسوم بيانية وتقارير مفصلة تعينك على الثبات.',
    '📊',
  ),
];

// ── STEP 1: Location ──
class _LocationStep extends StatelessWidget {
  final Future<void> Function() onAllow;
  final VoidCallback onSkip;

  const _LocationStep({required this.onAllow, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 70),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(painter: _LocationIllustration()),
              ),
            ),
          ),
          _InfoCard(
            title: 'تحديد الموقع',
            titleColor: AppColors.gold,
            subtitle:
                'نحتاج لموقعك لنحدد لك أوقات الصلاة واتجاه القبلة بدقة متناهية',
            hint: 'بيانات موقعك تبقى في جهازك ولا نطلع عليها أبداً',
            primaryLabel: 'تفعيل الموقع 📍',
            onPrimary: onAllow,
            skipLabel: 'تخطى',
            onSkip: onSkip,
          ),
        ],
      ),
    );
  }
}

// ── STEP 2: Notifications ──
class _NotificationsStep extends StatefulWidget {
  final Future<void> Function() onAllow;
  final VoidCallback onSkip;
  const _NotificationsStep({required this.onAllow, required this.onSkip});

  @override
  State<_NotificationsStep> createState() => _NotificationsStepState();
}

class _NotificationsStepState extends State<_NotificationsStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellCtrl;

  @override
  void initState() {
    super.initState();
    _bellCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(min: 0, max: 1, period: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _bellCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 70),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _bellCtrl,
                builder: (_, _) => Transform.rotate(
                  angle: math.sin(_bellCtrl.value * math.pi * 2) * 0.15,
                  child: SizedBox(
                    width: 220,
                    height: 200,
                    child: CustomPaint(painter: _BellIllustration()),
                  ),
                ),
              ),
            ),
          ),
          _InfoCard(
            title: 'السماح بإرسال التنبيهات',
            titleColor: AppColors.gold,
            subtitle:
                'يمكننا من تذكيرك بالصلاة والأذكار والمحاسبة المسائية والمزيد',
            hint: 'يمكنك تغيير هذا لاحقًا من الإعدادات',
            primaryLabel: 'السماح بالتنبيهات 🔔',
            primaryIcon: Icons.notifications_active_rounded,
            onPrimary: widget.onAllow,
            skipLabel: 'تخطى',
            onSkip: widget.onSkip,
          ),
        ],
      ),
    );
  }
}

// ── STEP 3: Gender ──
class _GenderStep extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _GenderStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 70),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'حدد الجنس',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 26,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GenderCard(
                      label: 'مسلم',
                      value: 'male',
                      emoji: '👳',
                      selected: selected == 'male',
                      onTap: () => onSelect('male'),
                    ),
                    const SizedBox(width: 20),
                    _GenderCard(
                      label: 'مسلمة',
                      value: 'female',
                      emoji: '🧕',
                      selected: selected == 'female',
                      onTap: () => onSelect('female'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text('ℹ️', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تجربة استخدام مناسبة، وختمات عامة للرجال وأخرى للنساء',
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _BottomActions(
            primaryLabel: 'التالي',
            onPrimary: selected != null ? onNext : null,
            skipLabel: 'تخطى',
            onSkip: onSkip,
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatefulWidget {
  final String label, value, emoji;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_GenderCard> createState() => _GenderCardState();
}

class _GenderCardState extends State<_GenderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(_GenderCard old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: widget.selected ? _scale : const AlwaysStoppedAnimation(1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 140,
          height: 180,
          decoration: BoxDecoration(
            gradient: widget.selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x30C8A96E), Color(0x183AAFA9)],
                  )
                : null,
            color: widget.selected ? null : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected
                  ? AppColors.gold.withOpacity(0.6)
                  : AppColors.border,
              width: widget.selected ? 2.5 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.selected
                      ? RadialGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.25),
                            AppColors.gold.withOpacity(0.05),
                          ],
                        )
                      : null,
                  color: widget.selected ? null : AppColors.card2,
                  border: Border.all(
                    color: widget.selected
                        ? AppColors.gold.withOpacity(0.5)
                        : AppColors.border,
                    width: widget.selected ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: widget.selected
                      ? AppColors.gold
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedOpacity(
                opacity: widget.selected ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.teal],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.night,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── STEP 4: Auth ──
class _AuthStep extends StatefulWidget {
  final void Function(String) onAuth;
  final VoidCallback onSkip;
  const _AuthStep({required this.onAuth, required this.onSkip});

  @override
  State<_AuthStep> createState() => _AuthStepState();
}

class _AuthStepState extends State<_AuthStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _anims = List.generate(5, (i) {
      final s = i * 0.1, e = (s + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _anim(int i, Widget w) => FadeTransition(
    opacity: _anims[i.clamp(0, 4)],
    child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _ctrl,
              curve: Interval(
                i * 0.1,
                (i * 0.1 + 0.4).clamp(0, 1),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
      child: w,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 80),
            _anim(
              0,
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0x30C8A96E), Color(0x10C8A96E)],
                    ),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌙', style: TextStyle(fontSize: 38)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _anim(
              1,
              const Column(
                children: [
                  Text(
                    'تقوى',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'سجّل دخولك لحفظ بياناتك ومزامنتها',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _anim(
              2,
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    _BenefitRow('💾', 'حفظ بياناتك وتقدمك'),
                    SizedBox(height: 8),
                    _BenefitRow('🏆', 'التنافس مع المسلمين حول العالم'),
                    SizedBox(height: 8),
                    _BenefitRow('📊', 'إحصائيات مفصلة ومتقدمة'),
                    SizedBox(height: 8),
                    _BenefitRow('🌙', 'مزامنة تلقائية بين أجهزتك'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            _anim(
              4,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  onTap: widget.onSkip,
                  child: const Text(
                    'متابعة بدون حساب',
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String icon, label;
  const _BenefitRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
      ),
      const Spacer(),
      const Icon(
        Icons.check_circle_rounded,
        size: 16,
        color: AppColors.success,
      ),
    ],
  );
}

// ── STEP 5: Plan ──
class _PlanStep extends StatefulWidget {
  final Future<void> Function() onStart;
  const _PlanStep({required this.onStart});

  @override
  State<_PlanStep> createState() => _PlanStepState();
}

class _PlanStepState extends State<_PlanStep>
    with SingleTickerProviderStateMixin {
  String _selected = 'free';
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 72),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0, 0.5),
              ),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 160,
                  child: CustomPaint(painter: _PlanIllustration()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.2, 0.7),
              ),
              child: const Column(
                children: [
                  Text(
                    'اختر خطتك',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 26,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'انضم إلى عائلة تقوى',
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _ctrl,
                  curve: const Interval(0.3, 0.9),
                ),
                child: Column(
                  children: [
                    _PlanCard(
                      id: 'premium',
                      title: 'تقوى ⭐ Premium',
                      desc:
                          'بلا إعلانات + إحصائيات متقدمة + مزامنة سحابية + دعم أولوي',
                      badge: 'الأفضل',
                      badgeColor: AppColors.gold,
                      price: '99 دج / شهر',
                      features: const [
                        'بلا إعلانات نهائياً',
                        'إحصائيات متقدمة ورسوم بيانية',
                        'مزامنة سحابية تلقائية',
                        'تذكيرات مخصصة لا نهاية لها',
                        'أولوية في الدعم الفني',
                      ],
                      selected: _selected == 'premium',
                      onTap: () => setState(() => _selected = 'premium'),
                    ),
                    const SizedBox(height: 10),
                    _PlanCard(
                      id: 'free',
                      title: 'تقوى 🌙 مجاني',
                      desc:
                          'جميع الميزات الأساسية مع إعلانات بسيطة للإبقاء على الخدمة',
                      features: const [
                        'جميع ميزات المحاسبة',
                        'أوقات الصلاة والقبلة',
                        'الأذكار والأدعية',
                        'إعلانات بسيطة',
                      ],
                      selected: _selected == 'free',
                      onTap: () => setState(() => _selected = 'free'),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.6, 1.0),
              ),
              child: PrimaryButton(
                label: _selected == 'premium'
                    ? 'ابدأ Premium 🌟'
                    : 'ابدأ مجاناً 🤲',
                onTap: widget.onStart,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String id, title, desc;
  final List<String> features;
  final bool selected;
  final String? badge;
  final Color? badgeColor;
  final String? price;
  final VoidCallback onTap;

  const _PlanCard({
    required this.id,
    required this.title,
    required this.desc,
    required this.features,
    required this.selected,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.gold.withOpacity(0.12),
                    AppColors.teal.withOpacity(0.06),
                  ],
                )
              : null,
          color: selected ? null : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.gold.withOpacity(0.5)
                : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.15),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.gold : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.gold : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: AppColors.night,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppColors.gold).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (badgeColor ?? AppColors.gold).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 10,
                        color: badgeColor ?? AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (price != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    price!,
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 11,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SHARED COMPONENTS ──
class _InfoCard extends StatelessWidget {
  final String title, subtitle, hint, primaryLabel;
  final Color titleColor;
  final Future<void> Function() onPrimary;
  final String? skipLabel;
  final VoidCallback? onSkip;
  final IconData? primaryIcon;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.primaryLabel,
    required this.onPrimary,
    required this.titleColor,
    this.skipLabel,
    this.onSkip,
    this.primaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 11,
              color: AppColors.textDim,
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: primaryLabel,
            icon: primaryIcon,
            onTap: onPrimary,
          ),
          if (skipLabel != null && onSkip != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onSkip,
              child: Text(
                skipLabel!,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 13,
                  color: AppColors.textDim,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? skipLabel;
  final VoidCallback? onSkip;

  const _BottomActions({
    required this.primaryLabel,
    required this.onPrimary,
    this.skipLabel,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButton(
          label: primaryLabel,
          onTap: onPrimary != null ? () async => onPrimary!() : null,
        ),
        if (skipLabel != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSkip,
            child: Text(
              skipLabel!,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: AppColors.textDim,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

// ── CUSTOM PAINTERS ──
class _OnboardBgPainter extends CustomPainter {
  final double t;
  _OnboardBgPainter({required this.t});

  static final _rng = math.Random(42);
  static List<Offset>? _stars;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.night,
    );

    _stars ??= List.generate(
      80,
      (_) => Offset(
        _rng.nextDouble() * size.width,
        _rng.nextDouble() * size.height,
      ),
    );

    for (int i = 0; i < _stars!.length; i++) {
      final op = 0.05 + 0.2 * ((math.sin(t * 2 * math.pi + i * 0.4) + 1) / 2);
      canvas.drawCircle(
        _stars![i],
        0.8 + _rng.nextDouble(),
        Paint()..color = AppColors.gold.withOpacity(op),
      );
    }

    final cx = size.width * 0.84, cy = size.height * 0.08;
    canvas.drawCircle(
      Offset(cx, cy),
      18,
      Paint()..color = const Color(0xFFFFF3CC),
    );
    canvas.drawCircle(
      Offset(cx + 10, cy - 4),
      15,
      Paint()..color = AppColors.night,
    );

    canvas.drawCircle(
      Offset(size.width / 2, -60),
      200,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppColors.gold.withOpacity(0.06), Colors.transparent],
            ).createShader(
              Rect.fromCircle(center: Offset(size.width / 2, -60), radius: 200),
            ),
    );
  }

  @override
  bool shouldRepaint(_OnboardBgPainter o) => o.t != t;
}

class _LocationIllustration extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final phone = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 20, cy), width: 120, height: 160),
      const Radius.circular(18),
    );
    canvas.drawRRect(phone, Paint()..color = const Color(0xFF1A2332));
    canvas.drawRRect(
      phone,
      Paint()
        ..color = AppColors.gold.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(cx - 80 + i * 20, cy - 60),
        Offset(cx - 80 + i * 20, cy + 60),
        Paint()
          ..color = AppColors.border
          ..strokeWidth = 0.8,
      );
    }

    _drawPin(canvas, Offset(cx - 20, cy - 20), 16, AppColors.gold);
    _drawPin(canvas, Offset(cx + 10, cy + 20), 10, AppColors.teal);

    canvas.drawCircle(
      Offset(cx + 60, cy + 20),
      30,
      Paint()..color = AppColors.teal.withOpacity(0.15),
    );
    canvas.drawCircle(
      Offset(cx + 60, cy + 20),
      30,
      Paint()
        ..color = AppColors.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      Offset(cx + 60, cy + 20),
      Offset(cx + 60, cy + 6),
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx + 60, cy + 20),
      Offset(cx + 70, cy + 20),
      Paint()
        ..color = AppColors.textSecondary
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    final path = Path()
      ..moveTo(cx + 10, cy + 20)
      ..quadraticBezierTo(cx, cy, cx - 20, cy - 20);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.gold.withOpacity(0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawPin(Canvas canvas, Offset pos, double r, Color color) {
    canvas.drawCircle(pos, r, Paint()..color = color.withOpacity(0.2));
    canvas.drawCircle(pos, r - 4, Paint()..color = color);
    canvas.drawCircle(pos, r - 8, Paint()..color = AppColors.night);
  }

  @override
  bool shouldRepaint(covariant _LocationIllustration o) => false;
}

class _BellIllustration extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;

    for (int i = 3; i >= 0; i--) {
      canvas.drawCircle(
        Offset(cx, cy),
        40.0 + i * 12,
        Paint()..color = AppColors.gold.withOpacity(0.03 + i * 0.02),
      );
    }

    final bell = Path();
    bell.moveTo(cx, cy - 55);
    bell.quadraticBezierTo(cx + 55, cy - 40, cx + 55, cy + 20);
    bell.quadraticBezierTo(cx + 55, cy + 35, cx + 70, cy + 35);
    bell.lineTo(cx - 70, cy + 35);
    bell.quadraticBezierTo(cx - 55, cy + 35, cx - 55, cy + 20);
    bell.quadraticBezierTo(cx - 55, cy - 40, cx, cy - 55);
    bell.close();

    canvas.drawPath(bell, Paint()..color = AppColors.gold.withOpacity(0.85));
    canvas.drawPath(
      bell,
      Paint()
        ..color = AppColors.goldLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(Offset(cx, cy + 44), 10, Paint()..color = AppColors.gold);
    canvas.drawLine(
      Offset(cx, cy + 35),
      Offset(cx, cy + 34),
      Paint()
        ..color = AppColors.goldLight
        ..strokeWidth = 3,
    );

    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - 58), width: 16, height: 12),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      Offset(cx + 44, cy - 44),
      20,
      Paint()..color = AppColors.teal,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '1',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx + 44 - tp.width / 2, cy - 44 - tp.height / 2));

    for (int i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx - 70, cy - 10),
          width: 20.0 + i * 12,
          height: 20.0 + i * 12,
        ),
        -math.pi / 4,
        -math.pi / 2,
        false,
        Paint()
          ..color = AppColors.teal.withOpacity(0.4 - i * 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BellIllustration o) => false;
}

class _PlanIllustration extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 20), width: 80, height: 80),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF1A2332),
    );
    for (int i = 0; i < 5; i++) {
      final angle = i * math.pi * 0.4 - math.pi;
      canvas.drawCircle(
        Offset(cx + 70 * math.cos(angle), cy + 30 * math.sin(angle)),
        12,
        Paint()..color = AppColors.gold.withOpacity(0.8),
      );
      canvas.drawCircle(
        Offset(cx + 70 * math.cos(angle), cy + 30 * math.sin(angle)),
        8,
        Paint()..color = AppColors.goldLight.withOpacity(0.5),
      );
    }
    _drawStar(canvas, Offset(cx, cy - 50), 20, AppColors.gold);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final a = i * math.pi / 5 - math.pi / 2;
      final rr = i.isEven ? r : r * 0.5;
      final pt = Offset(c.dx + rr * math.cos(a), c.dy + rr * math.sin(a));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PlanIllustration o) => false;
}

// ── STEP: Overlay ──
class _OverlayStep extends StatefulWidget {
  final Future<void> Function() onAllow;
  final VoidCallback onSkip;
  const _OverlayStep({required this.onAllow, required this.onSkip});

  @override
  State<_OverlayStep> createState() => _OverlayStepState();
}

class _OverlayStepState extends State<_OverlayStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 70),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, _) => SizedBox(
                  width: 220,
                  height: 200,
                  child: CustomPaint(
                    painter: _OverlayIllustration(progress: _floatCtrl.value),
                  ),
                ),
              ),
            ),
          ),
          _InfoCard(
            title: 'نافذة الأذكار 🪟',
            titleColor: AppColors.teal,
            subtitle:
                'تسمح بعرض الأذكار والتنبيهات فوق التطبيقات الأخرى لتذكيرك الدائم',
            hint: 'يتطلب إذن "الظهور فوق التطبيقات" على أندرويد',
            primaryLabel: 'تفعيل النافذة',
            primaryIcon: Icons.layers_outlined,
            onPrimary: widget.onAllow,
            skipLabel: 'تخطى',
            onSkip: widget.onSkip,
          ),
        ],
      ),
    );
  }
}

class _OverlayIllustration extends CustomPainter {
  final double progress;
  _OverlayIllustration({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;

    // Background App
    final appRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: 140, height: 100),
      const Radius.circular(12),
    );
    canvas.drawRRect(appRect, Paint()..color = const Color(0xFF1A2332));
    canvas.drawRRect(
      appRect,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Some dummy lines in the background app
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(cx - 50, cy - 10 + i * 15),
        Offset(cx + 50, cy - 10 + i * 15),
        Paint()..color = AppColors.border.withOpacity(0.3),
      );
    }

    // Floating Overlay Window
    final floatY = cy - 20 - (progress * 15);
    final overlayRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, floatY), width: 100, height: 60),
      const Radius.circular(10),
    );

    // Glow for overlay
    canvas.drawRRect(
      overlayRect.inflate(8),
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.gold.withOpacity(0.15), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(cx, floatY), radius: 60)),
    );

    canvas.drawRRect(overlayRect, Paint()..color = AppColors.card);
    canvas.drawRRect(
      overlayRect,
      Paint()
        ..color = AppColors.gold.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Text in overlay
    final tp = TextPainter(
      text: const TextSpan(
        text: 'سبحان الله',
        style: TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, floatY - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _OverlayIllustration o) =>
      o.progress != progress;
}

// ── STEP: Background ──
class _BackgroundStep extends StatefulWidget {
  final Future<void> Function() onAllow;
  final VoidCallback onSkip;
  const _BackgroundStep({required this.onAllow, required this.onSkip});

  @override
  State<_BackgroundStep> createState() => _BackgroundStepState();
}

class _BackgroundStepState extends State<_BackgroundStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 70),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, _) => SizedBox(
                  width: 220,
                  height: 200,
                  child: CustomPaint(
                    painter: _BackgroundIllustration(
                      progress: _pulseCtrl.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _InfoCard(
            title: 'التشغيل في الخلفية',
            titleColor: AppColors.gold,
            subtitle:
                'لضمان وصول تنبيهات الأذان والأذكار في وقتها بدقة دون توقف التطبيق',
            hint: 'يطلب النظام استثناء التطبيق من تحسين البطارية',
            primaryLabel: 'السماح بالتشغيل 🔋',
            primaryIcon: Icons.battery_saver_rounded,
            onPrimary: widget.onAllow,
            skipLabel: 'تخطى',
            onSkip: widget.onSkip,
          ),
        ],
      ),
    );
  }
}

class _BackgroundIllustration extends CustomPainter {
  final double progress;
  _BackgroundIllustration({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;

    // Pulse rings
    for (int i = 0; i < 3; i++) {
      final r = 60.0 + (i * 30.0) + (progress * 20.0);
      final opacity = (0.05 - (i * 0.015)).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = AppColors.teal.withOpacity(opacity),
      );
    }

    // Phone shape
    const phoneWidth = 80.0, phoneHeight = 140.0;
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: phoneWidth,
        height: phoneHeight,
      ),
      const Radius.circular(16),
    );

    // Background glow
    canvas.drawRRect(
      phoneRect.inflate(10),
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.teal.withOpacity(0.2), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 100)),
    );

    canvas.drawRRect(phoneRect, Paint()..color = const Color(0xFF1A2332));
    canvas.drawRRect(
      phoneRect,
      Paint()
        ..color = AppColors.teal.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Battery icon inside
    final batteryRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: 30,
      height: 50,
    );
    final batteryPaint = Paint()..color = AppColors.teal.withOpacity(0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(batteryRect, const Radius.circular(4)),
      batteryPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Battery tip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5, cy - 25 - 4, 10, 4),
        const Radius.circular(2),
      ),
      batteryPaint..style = PaintingStyle.fill,
    );

    // Filling battery based on pulse
    final fillHeight = 10.0 + (progress * 30.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          batteryRect.left + 4,
          batteryRect.bottom - 4 - fillHeight,
          batteryRect.right - 4,
          batteryRect.bottom - 4,
        ),
        const Radius.circular(2),
      ),
      batteryPaint..color = AppColors.teal.withOpacity(0.5 + (0.5 * progress)),
    );

    // Gear icons around signifying background services
    _drawSmallGear(canvas, Offset(cx - 60, cy - 40), 12, progress * math.pi);
    _drawSmallGear(canvas, Offset(cx + 60, cy + 30), 10, -progress * math.pi);
  }

  void _drawSmallGear(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
  ) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawCircle(Offset.zero, radius * 0.6, paint);
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(
          math.cos(angle) * (radius * 0.7),
          math.sin(angle) * (radius * 0.7),
        ),
        Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BackgroundIllustration o) =>
      o.progress != progress;
}
