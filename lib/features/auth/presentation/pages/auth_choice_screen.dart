import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/providers/auth_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';

class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.night,
      body: Stack(
        children: [
          const CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo & Name
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.gold.withOpacity(0.1),
                      border: Border.all(
                        color: context.colors.gold.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.gold.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Text('🌙', style: TextStyle(fontSize: 60)),
                  ),
                  const SizedBox(height: 24),
                  Text('تقوى', style: context.typography.displayLarge),
                  const SizedBox(height: 12),
                  Text(
                    'رفيقك نحو حياة مليئة بالإيمان',
                    textAlign: TextAlign.center,
                    style: context.typography.bodyLarge.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Actions
                  Column(
                    children: [
                      _ChoiceButton(
                        label: 'تسجيل الدخول',
                        icon: Icons.login_rounded,
                        isPrimary: true,
                        onTap: () => Navigator.pushNamed(context, Routes.auth),
                      ),
                      const SizedBox(height: 16),
                      _ChoiceButton(
                        label: 'المتابعة كضيف',
                        icon: Icons.person_outline_rounded,
                        isPrimary: false,
                        onTap: () {
                          ref.read(guestModeProvider.notifier).state = true;
                          // If guest mode is true, authStatusProvider will change to guest.
                          // Navigation is handled by the root redirect or shell.
                          Navigator.pushReplacementNamed(context, Routes.home);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'تسجيلك يضمن لك حفظ بياناتك عبر جميع أجهزتك',
                    textAlign: TextAlign.center,
                    style: context.typography.caption.copyWith(
                      color: context.colors.textDim,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _btnContent(context),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: context.colors.gold.withOpacity(0.5)),
              ),
              child: _btnContent(context),
            ),
    );
  }

  Widget _btnContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: isPrimary ? context.colors.background : context.colors.gold,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: context.typography.labelLarge.copyWith(
            color: isPrimary ? context.colors.background : context.colors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
