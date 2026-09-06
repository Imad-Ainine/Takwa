import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/primary_button.dart';
import 'package:takwa/core/widgets/auth_field.dart';
import 'package:takwa/core/routes/app_routes.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() =>
      _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  double _passStrength = 0;

  @override
  void initState() {
    super.initState();
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
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final password = _passCtrl.text;
    final confirmPassword = _confirmPassCtrl.text;

    if (password.isEmpty) {
      setState(() => _error = 'أدخل كلمة المرور الجديدة');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'كلمة المرور يجب أن تتكون من 6 خانات على الأقل');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _error = 'كلمات المرور غير متطابقة');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: AppSpacing.sm),
                Text('تم تعيين كلمة المرور الجديدة بنجاح ✓'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.auth,
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = _mapAuthError(e.message));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _mapAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('same password')) {
      return 'كلمة المرور الجديدة مطابقة لكلمة المرور الحالية';
    }
    if (msg.contains('password should')) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    if (msg.contains('session')) {
      return 'انتهت صلاحية الجلسة، يرجى طلب رمز استعادة جديد';
    }
    return 'تعذر تحديث كلمة المرور، حاول مجدداً';
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final s = AdaptiveStyle(context, isRamadan);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [s.card, s.bg],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: s.gold.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: s.gold.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lock_reset_rounded,
                          color: s.gold,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Title
                    Text(
                      'تعيين كلمة مرور جديدة',
                      style: s.amiri(32, weight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Subtitle
                    Text(
                      'قم بإدخال كلمة المرور الجديدة لحسابك لتسجيل الدخول بأمان',
                      style: s.naskh(13, color: s.textSec),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // Password Field
                    AuthField(
                      ctrl: _passCtrl,
                      hint: 'كلمة المرور الجديدة',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      style: s,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                    ),

                    // Strength bar
                    if (_passCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: PasswordStrengthBar(
                          strength: _passStrength,
                          style: s,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // Confirm Password Field
                    AuthField(
                      ctrl: _confirmPassCtrl,
                      hint: 'تأكيد كلمة المرور الجديدة',
                      icon: Icons.lock_clock_outlined,
                      isPassword: true,
                      style: s,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                    ),

                    // Error banner
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _error!,
                                style: s.naskh(12, color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxxl),

                    // Submit Button
                    PrimaryButton(
                      onTap: _loading ? null : _updatePassword,
                      label: _loading
                          ? 'جاري الحفظ...'
                          : 'حفظ كلمة المرور والدخول',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
