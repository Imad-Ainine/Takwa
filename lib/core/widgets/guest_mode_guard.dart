import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/auth_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/routes/app_routes.dart';

class GuestModeGuard extends ConsumerWidget {
  final Widget child;

  const GuestModeGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);

    if (authStatus == AuthStatus.authenticated) {
      return child;
    }

    return Stack(
      children: [
        // The actual screen content blur/darkened
        Opacity(
          opacity: 0.3,
          child: AbsorbPointer(child: child),
        ),

        // Restricted access overlay
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.gold.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.gold.withOpacity(0.1),
                    ),
                    child: Icon(Icons.lock_person_rounded, color: context.colors.gold, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'يتطلب تسجيل الدخول',
                    style: context.typography.headingLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هذه الميزة (المحاسبة والإحصائيات) تتطلب إنشاء حساب لحفظ بياناتك ومزامنتها سحابياً.',
                    textAlign: TextAlign.center,
                    style: context.typography.bodyMedium.copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Reset guest mode if they want to sign in
                        ref.read(guestModeProvider.notifier).state = false;
                        Navigator.pushNamed(context, Routes.auth);
                      },
                      child: const Text('تسجيل دخول / إنشاء حساب'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Maybe navigate back or do nothing
                    },
                    child: Text(
                      'استكمال كضيف (محدود)',
                      style: TextStyle(color: context.colors.textDim),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
