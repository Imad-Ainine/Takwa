import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/auth_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/widgets/primary_button.dart';

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
        Opacity(opacity: 0.3, child: AbsorbPointer(child: child)),

        // Restricted access overlay
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: context.colors.card.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.colors.gold.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with pulse effect decoration
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.gold.withOpacity(0.1),
                      border: Border.all(
                        color: context.colors.gold.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.cloud_off_rounded,
                      color: context.colors.gold,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ميزة سحابية',
                    style: context.typography.headingLarge.copyWith(
                      color: context.colors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هذه الميزة (المحاسبة والإحصائيات) تتطلب مزامنة سحابية لحفظ تقدمك. يرجى تسجيل الدخول لتفعيلها.',
                    textAlign: TextAlign.center,
                    style: context.typography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'تسجيل دخول / إنشاء حساب',
                    icon: Icons.login_rounded,
                    onTap: () async {
                      ref.read(guestModeProvider.notifier).state = false;
                      Navigator.pushNamed(context, Routes.auth);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'العودة',
                      style: context.typography.labelLarge.copyWith(
                        color: context.colors.textDim,
                        decoration: TextDecoration.underline,
                      ),
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
