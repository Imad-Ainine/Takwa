import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/primary_button.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  int _selectedMethod = 0; // 0: Edahabia/CIB, 1: Visa/Mastercard

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.asma),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildSupportMessage(context),
                        const SizedBox(height: 24),
                        _buildMethodCard(
                          index: 0,
                          title: 'الذهبية / CIB',
                          subtitle: '100.00 DZD',
                          icon: '💳',
                        ),
                        const SizedBox(height: 16),
                        _buildMethodCard(
                          index: 1,
                          title: 'فيزا / ماستركارد',
                          subtitle: '€10.00',
                          icon: '🌍',
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CustomLeadingButton(onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 12),
          Text(
            'طريقة الدفع',
            style: context.typography.headingMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required int index,
    required String title,
    required String subtitle,
    required String icon,
  }) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.gold.withOpacity(0.08)
              : context.colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.colors.gold : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.gold.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            _buildRadioIndicator(isSelected),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typography.labelLarge.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.typography.caption.copyWith(
                      color: isSelected
                          ? context.colors.gold
                          : context.colors.textDim,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: context.colors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.border.withOpacity(0.5),
                ),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.gold.withOpacity(0.12),
            context.colors.gold.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.gold.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.gold.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: context.colors.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'صدقة جارية',
                style: context.typography.labelLarge.copyWith(
                  color: context.colors.gold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'بمساهمتك البسيطة، تجعل "تقوى" متاحاً لملايين المسلمين كصدقة جارية عنك وعن والديك. 100دج أو 10€  شهرياً تضمن استمرار هذا العمل وتطويره الدائم.',
            style: context.typography.bodyMedium.copyWith(
              color: context.colors.textPrimary.withOpacity(0.9),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioIndicator(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? context.colors.gold : context.colors.textDim,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.gold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: PrimaryButton(
        label: 'المتابعة للدفع',
        onTap: () {
          // Implementation for actual payment would go here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('سيتم تفعيل الدفع قريباً إن شاء الله'),
            ),
          );
        },
      ),
    );
  }
}
