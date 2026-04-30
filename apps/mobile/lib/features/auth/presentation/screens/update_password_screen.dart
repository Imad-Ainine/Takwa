
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
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

  Future<void> _updatePassword() async {
    if (_passCtrl.text.isEmpty) {
      setState(() => _error = 'أدخل كلمة المرور الجديدة');
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'كلمات المرور غير متطابقة');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passCtrl.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح ✓')),
        );
        Navigator.pushReplacementNamed(context, Routes.auth);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final s = AdaptiveStyle(context, isRamadan);
    // Assuming AdaptiveStyle is available in the project as seen in auth_screen.dart
    // For now using basic context.colors
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'تحديث كلمة المرور',
                      style: context.typography.headingLarge.copyWith(
                        color: context.colors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'قم بإدخال كلمة المرور الجديدة لحسابك',
                      style: context.typography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AuthField(
                      ctrl: _passCtrl,
                      hint: 'كلمة المرور الجديدة',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      style: s,
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      ctrl: _confirmPassCtrl,
                      hint: 'تأكيد كلمة المرور',
                      icon: Icons.lock_reset_rounded,
                      isPassword: true,
                      style: s,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    PrimaryButton(
                      onTap: _loading ? null : _updatePassword,
                      label: _loading ? 'جاري التحديث...' : 'تحديث كلمة المرور',
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
