import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/primary_button.dart';

class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(
              pattern: BackgroundPattern.adhkar,
              opacity: 0.1,
            ),
          ),
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
                      PrimaryButton(
                        label: 'تسجيل الدخول',
                        icon: Icons.login_rounded,
                        onTap: () async =>
                            Navigator.pushNamed(context, Routes.auth),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'المتابعة كضيف',
                        icon: Icons.person_outline_rounded,
                        isOutline: true,
                        onTap: () async {
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
