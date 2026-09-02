import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/widgets/auth_field.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/primary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _loading = false;
  bool _codeSent = false;
  String? _error;
  String? _successMessage;

  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    ).hasMatch(email);
  }

  Future<void> _sendResetCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'يرجى إدخال البريد الإلكتروني');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _error = 'صيغة البريد الإلكتروني غير صحيحة');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'takwa://auth-callback',
      );
      if (mounted) {
        setState(() {
          _codeSent = true;
          _successMessage =
              'تم إرسال رمز التحقق ورابط إعادة التعيين إلى بريدك الإلكتروني.';
        });
        _startCountdown();
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _mapAuthError(e.message));
    } catch (e) {
      if (mounted) setState(() => _error = 'تعذر إرسال الرمز، تأكد من اتصال الإنترنت.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailCtrl.text.trim();
    final token = _otpCtrl.text.trim();

    if (token.isEmpty) {
      setState(() => _error = 'يرجى إدخال رمز التحقق المكون من 6 أرقام');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      if (res.session != null && mounted) {
        Navigator.pushReplacementNamed(context, Routes.updatePassword);
      } else {
        if (mounted) {
          setState(() => _error = 'رمز التحقق غير صحيح أو منتهي الصلاحية');
        }
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _mapAuthError(e.message));
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر التحقق من الرمز، حاول مجدداً');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'تجاوزت الحد المسموح من المحاولات، يرجى الانتظار قليلاً';
    }
    if (msg.contains('token') || msg.contains('otp') || msg.contains('invalid')) {
      return 'رمز التحقق غير صحيح أو انتهت صلاحيته';
    }
    if (msg.contains('user not found')) {
      return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
    }
    return 'حدث خطأ أثناء المعالجة، يرجى المحاولة لاحقاً';
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
            child: Column(
              children: [
                // App bar with back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: s.gold),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                                _codeSent
                                    ? Icons.mark_email_read_outlined
                                    : Icons.lock_reset_rounded,
                                color: s.gold,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            _codeSent
                                ? 'إدخال رمز التحقق'
                                : 'استعادة كلمة المرور',
                            style: s.amiri(32, weight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            _codeSent
                                ? 'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك أو اضغط على الرابط في الرسالة'
                                : 'أدخل بريدك الإلكتروني المسجل لنرسل لك رمز تأكيد إعادة تعيين كلمة المرور',
                            style: s.naskh(13, color: s.textSec),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Email field
                          AuthField(
                            ctrl: _emailCtrl,
                            hint: 'البريد الإلكتروني',
                            icon: Icons.alternate_email_rounded,
                            style: s,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) {
                              if (_error != null) setState(() => _error = null);
                            },
                          ),

                          // OTP field (shown when code is sent)
                          if (_codeSent) ...[
                            const SizedBox(height: 16),
                            AuthField(
                              ctrl: _otpCtrl,
                              hint: 'رمز التحقق (6 أرقام)',
                              icon: Icons.pin_outlined,
                              style: s,
                              keyboardType: TextInputType.number,
                              onChanged: (_) {
                                if (_error != null) setState(() => _error = null);
                              },
                            ),
                          ],

                          // Success Message Banner
                          if (_successMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.greenAccent.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.greenAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _successMessage!,
                                      style: s.naskh(
                                        12,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Error Banner
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
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
                                      style: s.naskh(
                                        12,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // Main Action Button
                          PrimaryButton(
                            onTap: _loading
                                ? null
                                : () async {
                                    if (_codeSent) {
                                      await _verifyOtp();
                                    } else {
                                      await _sendResetCode();
                                    }
                                  },
                            label: _loading
                                ? 'جاري المعالجة...'
                                : (_codeSent ? 'تحقق ومتابعة' : 'إرسال الرمز'),
                          ),

                          // Resend Code or Change Email
                          if (_codeSent) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_resendCountdown > 0)
                                  Text(
                                    'إعادة الإرسال بعد $_resendCountdown ثانية',
                                    style: s.naskh(12, color: s.textDim),
                                  )
                                else
                                  TextButton(
                                    onPressed: _loading ? null : _sendResetCode,
                                    child: Text(
                                      'إعادة إرسال الرمز',
                                      style: s.naskh(
                                        12,
                                        color: s.gold,
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
