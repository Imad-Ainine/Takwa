// ═══════════════════════════════════════════════════════════════
//  lib/features/auth/presentation/screens/auth_screen.dart
//  تقوى — شاشة المصادقة — Professional Islamic UI
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';

import '../../../../core/theme/ramadan_theme.dart';
import '../../../../core/supabase/supabase_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/auth_field.dart';

// ══════════════════════════════════════════════════════
//  AUTH SCREEN
// ══════════════════════════════════════════════════════
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  late final AnimationController _entryCtrl;
  late final AnimationController _bgCtrl; // rotating star field
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  double _passStrength = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _passCtrl.addListener(_updatePassStrength);
  }

  void _updatePassStrength() {
    final p = _passCtrl.text;
    double s = 0;
    if (p.length >= 6) s += 0.25;
    if (p.length >= 10) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9!@#\$%^&*]'))) s += 0.25;
    setState(() => _passStrength = s);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _entryCtrl.dispose();
    _bgCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _userCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────
  Future<void> _signIn() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'أدخل البريد وكلمة المرور');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SupabaseService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _authError(e.message));
    } catch (_) {
      if (mounted) setState(() => _error = 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    if (_userCtrl.text.trim().isEmpty) {
      setState(() => _error = 'أدخل اسم المستخدم');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'أدخل البريد وكلمة المرور');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SupabaseService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        username: _userCtrl.text.trim(),
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _authError(e.message));
    } catch (_) {
      if (mounted) setState(() => _error = 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await SupabaseService.signInWithGoogle();
      if (res != null && mounted) Navigator.pushReplacementNamed(context, '/');
    } catch (_) {
      if (mounted) setState(() => _error = 'حدث خطأ أثناء تسجيل الدخول بجوجل');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'أدخل بريدك الإلكتروني أولاً');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إرسال رابط إعادة تعيين كلمة المرور ✓'),
            backgroundColor: const Color(0xFF2DD4BF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر إرسال الرابط');
    }
  }

  String _authError(String msg) {
    if (msg.contains('Invalid login')) return 'البريد أو كلمة المرور خاطئة';
    if (msg.contains('already registered')) return 'البريد مسجّل مسبقاً';
    if (msg.contains('unique constraint')) return 'اسم المستخدم مأخوذ';
    if (msg.contains('Password should')) return 'كلمة المرور ٦ أحرف على الأقل';
    return 'خطأ في الاتصال، حاول لاحقاً';
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final s = AdaptiveStyle(context, isRamadan);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
            ),
            // ② Scroll content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _AuthHeader(style: s, entryCtrl: _entryCtrl),
                    collapseMode: CollapseMode.pin,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      children: [
                        _anim(0, _buildGlassCard(s)),
                        const SizedBox(height: 20),
                        _anim(1, _buildSeparator(s)),
                        const SizedBox(height: 16),
                        _anim(2, _buildGoogleBtn(s)),
                        const SizedBox(height: 28),
                        _anim(
                          3,
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushReplacementNamed(context, '/'),
                            child: Text(
                              'متابعة كضيف — استكشف التطبيق ➜',
                              style: s.naskh(
                                13,
                                color: s.textSec,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ③ Loading overlay
            if (_loading)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black38,
                  child: Center(
                    child: _GlowPulse(
                      child: CircularProgressIndicator(
                        color: s.gold,
                        strokeWidth: 3,
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

  Widget _anim(int i, Widget child) {
    final delay = i * 0.12;
    final end = (delay + 0.5).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(delay, end, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _entryCtrl,
                curve: Interval(delay, end, curve: Curves.easeOutCubic),
              ),
            ),
        child: child,
      ),
    );
  }

  // ── Glassmorphism Form Card ────────────────────────────
  Widget _buildGlassCard(AdaptiveStyle s) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: s.bg.withOpacity(0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: s.gold.withOpacity(0.22), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: s.gold.withOpacity(0.07),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Tab bar ──
              Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: s.border.withOpacity(0.5)),
                ),
                child: TabBar(
                  // 1. Removes the ink ripple on click
                  splashFactory: NoSplash.splashFactory,
                  // 2. Removes the grey circle highlight on long press
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  // 3. Optional: Remove indicator padding if it causes overflow
                  indicatorPadding: EdgeInsets.zero,
                  controller: _tabs,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(colors: [s.goldDark, s.gold]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: s.gold.withOpacity(0.3), blurRadius: 8),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: s.textSec,
                  dividerColor: Colors.transparent,
                  labelStyle: s.naskh(13, weight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'تسجيل الدخول'),
                    Tab(text: 'حساب جديد'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Username field (sign-up only) ──
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _tabs.index == 1
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    AuthField(
                      ctrl: _userCtrl,
                      hint: 'اسم المستخدم',
                      icon: Icons.person_outline_rounded,
                      style: s,
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),

              // ── Email ──
              AuthField(
                ctrl: _emailCtrl,
                hint: 'البريد الإلكتروني',
                icon: Icons.alternate_email_rounded,
                style: s,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // ── Password ──
              AuthField(
                ctrl: _passCtrl,
                hint: 'كلمة المرور',
                icon: Icons.lock_outline_rounded,
                style: s,
                isPassword: true,
              ),

              // ── Password strength (sign-up only) ──
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _tabs.index == 1 && _passCtrl.text.isNotEmpty
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: PasswordStrengthBar(strength: _passStrength, style: s),
                ),
              ),

              // ── Forgot password ──
              if (_tabs.index == 0)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: s.naskh(12, color: s.gold),
                    ),
                  ),
                ),

              if (_error != null) _buildError(s),
              const SizedBox(height: 20),

              // ── Submit ──
              PrimaryButton(
                onTap: _loading
                    ? null
                    : () async {
                        if (_tabs.index == 0) {
                          await _signIn();
                        } else {
                          await _signUp();
                        }
                      },
                label: _tabs.index == 0 ? 'دخول آمن' : 'إنشاء حساب',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(AdaptiveStyle s) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_error!, style: s.naskh(12, color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator(AdaptiveStyle s) {
    return Row(
      children: [
        Expanded(child: Divider(color: s.border.withOpacity(0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('أو', style: s.naskh(12, color: s.textDim)),
        ),
        Expanded(child: Divider(color: s.border.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildGoogleBtn(AdaptiveStyle s) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: _loading ? null : _signInGoogle,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: s.bg.withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: s.border.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'الدخول عبر Google',
                  style: s.naskh(14, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  ANIMATED STAR-FIELD BACKGROUND
// ══════════════════════════════════════════════════════
class _StarFieldBg extends StatelessWidget {
  final AnimationController controller;
  final AdaptiveStyle style;
  const _StarFieldBg({required this.controller, required this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => CustomPaint(
        painter: _StarsPainter(progress: controller.value, gold: style.gold),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF050B2A), style.bg],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double progress;
  final Color gold;
  _StarsPainter({required this.progress, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint();
    const count = 60;

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height * 0.6;
      final twinkle = math.sin((progress * math.pi * 2) + i * 0.7);
      final opacity = (0.2 + 0.5 * ((twinkle + 1) / 2)).clamp(0.0, 0.8);
      final radius = 1.0 + rng.nextDouble() * 1.4;

      paint.color = (i % 7 == 0 ? gold : Colors.white).withOpacity(opacity);
      canvas.drawCircle(Offset(x, baseY), radius, paint);
    }

    // Mosque silhouette hint at bottom of header
    final mPaint = Paint()
      ..color = gold.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height * 0.45;
    // simple dome shape
    path.moveTo(0, h);
    path.lineTo(w * 0.3, h);
    path.lineTo(w * 0.3, h * 0.7);
    path.quadraticBezierTo(w * 0.5, h * 0.3, w * 0.7, h * 0.7);
    path.lineTo(w * 0.7, h);
    path.lineTo(w, h);
    canvas.drawPath(path, mPaint);
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════
//  AUTH HEADER
// ══════════════════════════════════════════════════════
class _AuthHeader extends StatelessWidget {
  final AdaptiveStyle style;
  final AnimationController entryCtrl;
  const _AuthHeader({required this.style, required this.entryCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, style.bg.withOpacity(0.95)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Glowing logo
              Hero(
                tag: 'app_logo',
                child: AnimatedBuilder(
                  animation: entryCtrl,
                  builder: (_, child) => Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [style.card, style.bg],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: style.gold.withOpacity(0.4 * entryCtrl.value),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                      border: Border.all(
                        color: style.gold.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: child,
                  ),
                  child: const Center(
                    child: Text('🌙', style: TextStyle(fontSize: 42)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [style.gold, style.gold],
                ).createShader(bounds),
                child: Text(
                  'تقوى',
                  style: style
                      .amiri(48, weight: FontWeight.w800)
                      .copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'رفيقك في محاسبة النفس والطاعات',
                style: context.typography.bodyLarge.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  GLOW PULSE WRAPPER

// ══════════════════════════════════════════════════════
class _GlowPulse extends StatefulWidget {
  final Widget child;
  const _GlowPulse({required this.child});
  @override
  State<_GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<_GlowPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
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
      builder: (_, child) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.3 * _ctrl.value),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
