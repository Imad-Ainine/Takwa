import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_leading_button.dart';
import '../../../../core/widgets/custom_pattern_background.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/takwa_loading_indicator.dart';
import '../../../../core/supabase/supabase_providers.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // Initialize controller with current user data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(userProfileProvider);
      profileAsync.whenData((profile) {
        if (profile != null) {
          _nameController.text = profile['username'] ?? '';
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Simulate save delay
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تم حفظ التغييرات بنجاح',
              textAlign: TextAlign.center,
            ),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ أثناء حفظ التغييرات',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: const CustomLeadingButton(),
                title: Text(
                  'إعدادات الحساب',
                  style: context.typography.headingMedium.copyWith(
                    color: context.colors.gold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: profileAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: TakwaLoadingIndicator()),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'خطأ في تحميل البيانات',
                      style: context.typography.bodyMedium.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  data: (profile) {
                    final email = profile?['email'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعلومات الشخصية',
                              style: context.typography.labelLarge.copyWith(
                                color: context.colors.textDim,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              decoration: context.decorations.card.copyWith(
                                color: context.colors.card.withOpacity(0.8),
                              ),
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'الاسم'),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextFormField(
                                    controller: _nameController,
                                    style: context.typography.bodyMedium,
                                    decoration: _getInputDecoration(
                                      context,
                                      'أدخل اسمك',
                                    ),
                                    validator: (val) =>
                                        (val == null || val.trim().isEmpty)
                                        ? 'الرجاء إدخال الاسم'
                                        : null,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  _buildLabel(context, 'البريد الإلكتروني'),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextFormField(
                                    initialValue: email,
                                    enabled: false,
                                    style: context.typography.bodyMedium
                                        .copyWith(
                                          color: context.colors.textDim,
                                        ),
                                    decoration: _getInputDecoration(context, '')
                                        .copyWith(
                                          fillColor: context.colors.card
                                              .withOpacity(0.3),
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'لا يمكن تغيير البريد الإلكتروني حالياً',
                                    style: context.typography.caption.copyWith(
                                      color: context.colors.textDim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                            PrimaryButton(
                              onTap: _saveChanges,
                              label: 'حفظ التغييرات',
                              icon: Icons.save_rounded,
                              isLoading: _isSaving,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            // Update Password Section
                            Text(
                              'الأمان',
                              style: context.typography.labelLarge.copyWith(
                                color: context.colors.textDim,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              decoration: context.decorations.card.copyWith(
                                color: context.colors.card.withOpacity(0.8),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.lock_outline_rounded,
                                  color: context.colors.gold,
                                ),
                                title: Text(
                                  'تغيير كلمة المرور',
                                  style: context.typography.labelLarge,
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: context.colors.textDim,
                                ),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/update-password',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: context.typography.labelMedium.copyWith(
        color: context.colors.gold,
      ),
    );
  }

  InputDecoration _getInputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: context.typography.bodyMedium.copyWith(
        color: context.colors.textDim,
      ),
      filled: true,
      fillColor: context.colors.card.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.colors.border.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.colors.gold, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
    );
  }
}
