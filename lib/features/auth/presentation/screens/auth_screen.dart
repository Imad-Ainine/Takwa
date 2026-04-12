// ═══════════════════════════════════════════════════════════════
//  lib/features/auth/presentation/screens/auth_screen.dart
//  تقوى — تسجيل الدخول وإنشاء الحساب
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';

import '../../../../core/theme/ramadan_theme.dart';
import '../../../../core/supabase/supabase_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/app_theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  late final AnimationController _entryCtrl;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _entryCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _userCtrl.dispose();
    super.dispose();
  }

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
    } catch (e) {
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
    } catch (e) {
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
      if (res != null && mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'حدث خطأ أثناء تسجيل الدخول بجوجل');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _authError(String msg) {
    if (msg.contains('Invalid login')) return 'البريد أو كلمة المرور خاطئة';
    if (msg.contains('already registered')) return 'البريد مسجّل مسبقاً';
    if (msg.contains('unique constraint')) return 'اسم المستخدم مأخوذ بالفعل';
    if (msg.contains('Password should')) {
      return 'كلمة المرور يجب أن تكون ٦ أحرف على الأقل';
    }
    return 'خطأ في الاتصال، حاول لاحقاً';
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final s = AdaptiveStyle(context, isRamadan);

    return Scaffold(
      backgroundColor: s.bg,
      body: Stack(
        children: [
          const CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar / Header ──
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: _AuthHeader(style: s),
                  collapseMode: CollapseMode.pin,
                ),
              ),

              // ── Content ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  child: Column(
                    children: [
                      // ① Form Card
                      _anim(0, _buildFormCard(s)),
                      const SizedBox(height: 24),

                      // ② Social Separator
                      _anim(1, _buildSeparator(s)),
                      const SizedBox(height: 20),

                      // ③ Social Button
                      _anim(
                        2,
                        _SocialBtn(
                          onTap: _loading ? null : _signInGoogle,
                          icon: 'assets/images/google_logo.png',
                          label: 'Google الدخول عبر',
                          style: s,
                          isGoogle: true,
                        ),
                      ),

                      const SizedBox(height: 32),
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
          if (_loading)
            Container(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator(color: s.gold)),
            ),
        ],
      ),
    );
  }

  Widget _anim(int i, Widget child) {
    final delay = i * 0.1, duration = (delay + 0.5).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(delay, duration, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _entryCtrl,
                curve: Interval(delay, duration, curve: Curves.easeOutCubic),
              ),
            ),
        child: child,
      ),
    );
  }

  Widget _buildFormCard(AdaptiveStyle s) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: s.cardDeco.copyWith(
        border: Border.all(color: s.gold.withOpacity(0.2)),
        boxShadow: context.shadows.card,
      ),
      child: Column(
        children: [
          // ── Tab Bar ──
          Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: s.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: s.border),
            ),
            child: TabBar(
              controller: _tabs,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [s.gold, s.teal],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: s.gold.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: s.bg,
              unselectedLabelColor: s.textSec,
              dividerColor: Colors.transparent,
              labelStyle: s.naskh(13, weight: FontWeight.bold),
              tabs: const [
                Tab(text: 'تسجيل الدخول'),
                Tab(text: 'حساب جديد'),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Fields ──
          _AuthField(
            ctrl: _emailCtrl,
            hint: 'عنوان البريد الإلكتروني',
            icon: Icons.alternate_email_rounded,
            style: s,
          ),
          const SizedBox(height: 16),
          _AuthField(
            ctrl: _passCtrl,
            hint: 'كلمة المرور',
            icon: Icons.lock_outline_rounded,
            style: s,
            isPassword: true,
          ),
          const SizedBox(height: 16),

          // Username always visible as requested "without hide username"
          _AuthField(
            ctrl: _userCtrl,
            hint: _tabs.index == 0
                ? 'اسم المستخدم (اختياري للجدد)'
                : 'اسم المستخدم للملف الشخصي',
            icon: Icons.person_outline_rounded,
            style: s,
            labelSuffix: _tabs.index == 0 ? 'جديد؟' : '*',
          ),

          if (_error != null) _buildError(s),

          const SizedBox(height: 32),

          // ── Submit Button ──
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : (_tabs.index == 0 ? _signIn : _signUp),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: s.bg,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: s.gold.withOpacity(0.3),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [s.goldDark, s.gold]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tabs.index == 0 ? 'دخول آمن' : 'إنشاء حساب جديد',
                        style: s.naskh(15, weight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AdaptiveStyle s) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 12),
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
        Expanded(child: Divider(color: s.border.withOpacity(0.4))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('أو استعمل', style: s.naskh(11, color: s.textDim)),
        ),
        Expanded(child: Divider(color: s.border.withOpacity(0.4))),
      ],
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final AdaptiveStyle style;
  const _AuthHeader({required this.style});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [style.gold.withOpacity(0.2), style.bg],
            ),
          ),
        ),
        // Decorative Elements
        Positioned(
          top: -20,
          right: -30,
          child: Opacity(
            opacity: 0.1,
            child: Icon(Icons.mosque_rounded, size: 200, color: style.gold),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 44),
              // Logo with Glow
              Hero(
                tag: 'app_logo',
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.card,
                    boxShadow: [
                      BoxShadow(
                        color: style.gold.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: style.gold.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '🌙',
                      style: TextStyle(
                        fontSize: 40,
                        shadows: [
                          Shadow(
                            color: style.gold.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('تقوى', style: style.amiri(36, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                'رفيقك في محاسبة النفس والطاعات',
                style: style.naskh(14, color: style.textSec),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatefulWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final AdaptiveStyle style;
  final bool isPassword;
  final String? labelSuffix;

  const _AuthField({
    required this.ctrl,
    required this.hint,
    required this.icon,
    required this.style,
    this.isPassword = false,
    this.labelSuffix,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _obscure = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: s.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused ? s.gold : s.border,
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: s.gold.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: widget.ctrl,
          obscureText: widget.isPassword && _obscure,
          textDirection: TextDirection.ltr,
          style: s.naskh(14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: s.naskh(13, color: s.textDim),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused ? s.gold : s.textSec,
              size: 20,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: s.textSec,
                      size: 20,
                    ),
                  )
                : (widget.labelSuffix != null
                      ? Container(
                          margin: const EdgeInsets.only(left: 14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.labelSuffix!,
                                style: s.naskh(
                                  10,
                                  color: s.gold,
                                  weight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final String icon;
  final String label;
  final AdaptiveStyle style;
  final bool isGoogle;

  const _SocialBtn({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.style,
    this.isGoogle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: style.cardDeco.copyWith(
          color: style.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: style.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              const Icon(
                Icons.g_mobiledata_rounded,
                color: Colors.blueAccent,
                size: 32,
              )
            else
              const Icon(Icons.login_rounded, size: 20),
            const SizedBox(width: 12),
            Text(label, style: style.naskh(14, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
