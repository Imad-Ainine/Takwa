// ═══════════════════════════════════════════════════════════════
//  lib/features/auth/presentation/screens/auth_screen.dart
//  محاسبة النفس — تسجيل الدخول وإنشاء الحساب
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _userCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
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
      setState(() => _error = _authError(e.message));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    if (_userCtrl.text.trim().isEmpty) {
      setState(() => _error = 'أدخل اسم المستخدم');
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
      setState(() => _error = _authError(e.message));
    } finally {
      setState(() => _loading = false);
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
      setState(() => _error = 'حدث خطأ أثناء تسجيل الدخول بجوجل');
    } finally {
      setState(() => _loading = false);
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
    final s = AdaptiveStyle(context, isRamadan); // Fixed: added context

    return Scaffold(
      backgroundColor: s.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: isRamadan
                ? const _RamadanBg()
                : CustomPaint(painter: _AuthBgPainter()),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [s.gold.withOpacity(0.2), Colors.transparent],
                      ),
                      border: Border.all(
                        color: s.gold.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text('🌙', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('محاسبة النفس', style: s.amiri(28)),
                  Text(
                    'سجّل دخولك لمزامنة بياناتك',
                    style: s.naskh(12, color: s.textSec),
                  ),
                  const SizedBox(height: 32),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: s.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: s.border),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(colors: [s.gold, s.teal]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorPadding: const EdgeInsets.all(3),
                      labelColor: s.bg,
                      unselectedLabelColor: s.textSec,
                      labelStyle: GoogleFonts.notoNaskhArabic(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'تسجيل الدخول'),
                        Tab(text: 'حساب جديد'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fields
                  _AuthField(
                    ctrl: _emailCtrl,
                    hint: 'البريد الإلكتروني',
                    icon: Icons.email_rounded,
                    style: s,
                  ),
                  const SizedBox(height: 12),
                  _AuthField(
                    ctrl: _passCtrl,
                    hint: 'كلمة المرور',
                    icon: Icons.lock_rounded,
                    style: s,
                    isPassword: true,
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: _tabs.index == 1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _AuthField(
                              ctrl: _userCtrl,
                              hint: 'اسم المستخدم',
                              icon: Icons.person_rounded,
                              style: s,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _error!,
                            style: GoogleFonts.notoNaskhArabic(
                              fontSize: 12,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : (_tabs.index == 0 ? _signIn : _signUp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: s.gold,
                        foregroundColor: s.bg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: s.bg,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _tabs.index == 0 ? 'دخول' : 'إنشاء حساب',
                              style: s.naskh(14, weight: FontWeight.w700),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Social Auth Separator
                  Row(
                    children: [
                      Expanded(child: Divider(color: s.border, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'أو عبر',
                          style: s.naskh(12, color: s.textSec),
                        ),
                      ),
                      Expanded(child: Divider(color: s.border, thickness: 1)),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // Social Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialBtn(
                        onTap: _loading ? null : _signInGoogle,
                        icon: 'assets/images/google_logo.png', // Assuming user has this or I'll provide a placeholder
                        label: 'Google',
                        style: s,
                        isGoogle: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                    child: Text(
                      'متابعة بدون حساب',
                      style: s.naskh(12, color: s.textSec, weight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatefulWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final AdaptiveStyle style;
  final bool isPassword;
  const _AuthField({
    required this.ctrl,
    required this.hint,
    required this.icon,
    required this.style,
    this.isPassword = false,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    return Container(
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.border),
      ),
      child: TextField(
        controller: widget.ctrl,
        obscureText: widget.isPassword && _obscure,
        textDirection: TextDirection.ltr,
        style: s.naskh(13),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: s.naskh(12, color: s.textSec),
          prefixIcon: Icon(widget.icon, color: s.textSec, size: 20),
          suffixIcon: widget.isPassword
              ? GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: s.textSec,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
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
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: style.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: style.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              Icon(Icons.g_mobiledata, color: style.gold, size: 24)
            else
              const Icon(Icons.login_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: style.naskh(13, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RamadanBg extends StatelessWidget {
  const _RamadanBg();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: RamadanBgPainter());
}

class _AuthBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.night,
    );
  }

  @override
  bool shouldRepaint(covariant _AuthBgPainter o) => false;
}
