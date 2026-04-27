// ═══════════════════════════════════════════════════════════════
//  lib/features/adhkar/_user_community_adhkar_views.dart
//  تقوى — User & Community Adhkar Tab Views
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/core/widgets/takwa_refresh_indicator.dart';
import 'package:takwa/core/providers/user_content_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/supabase/supabase_service.dart';
import 'package:takwa/core/widgets/primary_button.dart';

// ═══════════════════════════════════════════════════════════════
//  USER ADHKAR TAB
// ═══════════════════════════════════════════════════════════════

class UserAdhkarTabView extends ConsumerWidget {
  final AnimationController entryCtrl;
  const UserAdhkarTabView({super.key, required this.entryCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userAdhkarProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: context.colors.gold,
        foregroundColor: context.colors.night,
        label: const Text(
          'إضافة ذكر',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.add_rounded),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddAdhkarSheet(),
        ),
      ),
      body: state.when(
        data: (adhkar) {
          if (adhkar.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      'أذكاري الخاصة',
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لا يوجد أذكار مضافة حالياً.\nاضغط على الزر لإضافة ذكرك الأول.',
                      style: context.typography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: adhkar.length,
            itemBuilder: (ctx, i) {
              final d = adhkar[i];
              return _UserAdhkarCard(item: d, index: i);
            },
          );
        },
        loading: () => const Center(child: TakwaLoadingIndicator()),
        error: (e, s) => Center(
          child: Text(
            'حدث خطأ: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  USER ADHKAR CARD
// ─────────────────────────────────────────
class _UserAdhkarCard extends ConsumerStatefulWidget {
  final UserAdhkarItem item;
  final int index;
  const _UserAdhkarCard({required this.item, required this.index});

  @override
  ConsumerState<_UserAdhkarCard> createState() => _UserAdhkarCardState();
}

class _UserAdhkarCardState extends ConsumerState<_UserAdhkarCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _onShare(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareToCommunitySheet(item: widget.item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.item;

    return ScaleTransition(
      scale: Tween<double>(
        begin: 1,
        end: 0.97,
      ).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOut)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: context.colors.gold.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Text ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('📿', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      d.textAr,
                      style: context.typography.headingMedium.copyWith(
                        fontSize: 19,
                        height: 1.9,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Footer ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.gold.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              child: Row(
                children: [
                  // Repeat badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.colors.gold.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      '${d.count}×',
                      style: context.typography.caption.copyWith(
                        color: context.colors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Copy button
                  _IconActionButton(
                    icon: Icons.copy_rounded,
                    tooltip: 'نسخ',
                    color: context.colors.textDim,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: d.textAr));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم النسخ'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),

                  // Share to community button
                  _IconActionButton(
                    icon: Icons.people_alt_rounded,
                    tooltip: 'شارك مع المجتمع',
                    color: context.colors.teal,
                    onTap: () => _onShare(context),
                  ),
                  const SizedBox(width: 4),

                  // Delete button
                  _IconActionButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'حذف',
                    color: Colors.redAccent,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: context.colors.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'حذف الذكر؟',
                            textAlign: TextAlign.right,
                          ),
                          content: const Text(
                            'هل تريد حذف هذا الذكر نهائياً؟',
                            textAlign: TextAlign.right,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(userAdhkarProvider.notifier).delete(d.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHARE TO COMMUNITY CONFIRMATION SHEET
// ═══════════════════════════════════════════════════════════════

class _ShareToCommunitySheet extends ConsumerStatefulWidget {
  final UserAdhkarItem item;
  const _ShareToCommunitySheet({required this.item});

  @override
  ConsumerState<_ShareToCommunitySheet> createState() =>
      _ShareToCommunitySheetState();
}

class _ShareToCommunitySheetState
    extends ConsumerState<_ShareToCommunitySheet> {
  bool _loading = false;
  bool _done = false;

  Future<void> _share() async {
    setState(() => _loading = true);
    try {
      await ref.read(userAdhkarProvider.notifier).shareAdhkar(widget.item);
      if (mounted) setState(() => _done = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Icon + Title
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.teal.withOpacity(0.2),
                  context.colors.gold.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'مشاركة مع المجتمع',
            style: context.typography.headingMedium.copyWith(
              fontSize: 18,
              color: context.colors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سيُضاف الذكر للمراجعة ثم يظهر في تبويب المجتمع',
            style: context.typography.caption.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Dhikr preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.gold.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.gold.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  widget.item.textAr,
                  textAlign: TextAlign.center,
                  style: context.typography.headingMedium.copyWith(
                    fontSize: 18,
                    height: 1.9,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      size: 14,
                      color: context.colors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.item.count} مرة',
                      style: context.typography.caption.copyWith(
                        color: context.colors.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          if (_done)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: context.colors.success,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'تمت المشاركة بنجاح!',
                  style: context.typography.bodyMedium.copyWith(
                    color: context.colors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'إلغاء',
                    onTap: _loading ? null : () => Navigator.pop(context),
                    isOutline: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'شارك مع المجتمع',
                    onTap: _loading ? null : _share,
                    isLoading: _loading,
                    icon: Icons.people_alt_rounded,
                    baseColor: context.colors.teal,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  COMMUNITY ADHKAR TAB
// ═══════════════════════════════════════════════════════════════

class CommunityAdhkarTabView extends ConsumerWidget {
  final AnimationController entryCtrl;
  const CommunityAdhkarTabView({super.key, required this.entryCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityAdhkarProvider);

    return state.when(
      data: (adhkar) {
        if (adhkar.isEmpty) {
          return TakwaRefreshIndicator(
            onRefresh: () =>
                ref.read(communityAdhkarProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      'مجتمع الأذكار',
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'لا توجد مشاركات من المجتمع حالياً.\nشارك أذكارك من تبويب "أذكاري".',
                        style: context.typography.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return TakwaRefreshIndicator(
          onRefresh: () => ref.read(communityAdhkarProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: adhkar.length,
            itemBuilder: (ctx, i) {
              final c = adhkar[i];
              final delay = (i * 0.05).clamp(0.0, 0.5);
              return FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: entryCtrl,
                    curve: Interval(
                      delay,
                      (delay + 0.4).clamp(0, 1),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: _CommunityAdhkarCard(item: c),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: TakwaLoadingIndicator()),
      error: (e, s) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'حدث خطأ: $e',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: PrimaryButton(
                onTap: () async =>
                    ref.read(communityAdhkarProvider.notifier).refresh(),
                label: 'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  COMMUNITY ADHKAR CARD
// ─────────────────────────────────────────
class _CommunityAdhkarCard extends ConsumerWidget {
  final CommunityAdhkarItem item;
  const _CommunityAdhkarCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.teal.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Text ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🤝', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.textAr,
                    style: context.typography.headingMedium.copyWith(
                      fontSize: 19,
                      height: 1.9,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Footer ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.teal.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            child: Row(
              children: [
                // Repeat badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.colors.teal.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    '${item.count}×',
                    style: context.typography.caption.copyWith(
                      color: context.colors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),

                // Copy
                _IconActionButton(
                  icon: Icons.copy_rounded,
                  tooltip: 'نسخ',
                  color: context.colors.textDim,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: item.textAr));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم النسخ'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Like button
                GestureDetector(
                  onTap: () {
                    if (item.likedByMe) return;
                    HapticFeedback.lightImpact();
                    ref
                        .read(communityAdhkarProvider.notifier)
                        .likeAdhkar(item.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: item.likedByMe
                          ? Colors.redAccent.withOpacity(0.1)
                          : context.colors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: item.likedByMe
                            ? Colors.redAccent.withOpacity(0.4)
                            : context.colors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.likedByMe
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: item.likedByMe
                              ? Colors.redAccent
                              : context.colors.textDim,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.likes}',
                          style: context.typography.caption.copyWith(
                            color: item.likedByMe
                                ? Colors.redAccent
                                : context.colors.textDim,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

// ═══════════════════════════════════════════════════════════════
//  ADD ADHKAR SHEET  (moved here from adhkar _screen.dart)
// ═══════════════════════════════════════════════════════════════

class AddAdhkarSheet extends ConsumerStatefulWidget {
  const AddAdhkarSheet({super.key});
  @override
  ConsumerState<AddAdhkarSheet> createState() => _AddAdhkarSheetState();
}

class _AddAdhkarSheetState extends ConsumerState<AddAdhkarSheet> {
  final _textCtrl = TextEditingController();
  int _count = 1;
  bool _shareWithCommunity = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(userAdhkarProvider.notifier)
          .add(textAr: text, count: _count);

      if (_shareWithCommunity) {
        await SupabaseService.shareAdhkarToCommunity(
          textAr: text,
          count: _count,
        );
        ref.invalidate(communityAdhkarProvider);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إضافة ذكر جديد',
                style: context.typography.bodySmall.copyWith(
                  color: context.colors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textCtrl,
            maxLines: 4,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 18),
            decoration: InputDecoration(
              hintText: 'اكتب الذكر هنا بحروف عربية واضحة...',
              hintStyle: TextStyle(
                fontFamily: 'Amiri',
                color: const Color(0xFF9E9E9E).withOpacity(0.7),
              ),
              filled: true,
              fillColor: context.colors.night.withOpacity(0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: context.colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: context.colors.gold, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Count picker
          Row(
            children: [
              Text('عدد التكرار:', style: context.typography.bodyMedium),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    setState(() => _count = _count > 1 ? _count - 1 : 1),
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: context.colors.gold,
                ),
              ),
              Text(
                '$_count',
                style: context.typography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _count++),
                icon: Icon(
                  Icons.add_circle_outline,
                  color: context.colors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Share toggle
          GestureDetector(
            onTap: () =>
                setState(() => _shareWithCommunity = !_shareWithCommunity),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _shareWithCommunity
                    ? context.colors.teal.withOpacity(0.08)
                    : context.colors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _shareWithCommunity
                      ? context.colors.teal.withOpacity(0.4)
                      : context.colors.border,
                ),
              ),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مشاركة مع المجتمع',
                          style: context.typography.bodyMedium.copyWith(
                            color: _shareWithCommunity
                                ? context.colors.teal
                                : context.colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'يُضاف الذكر للمراجعة ثم يظهر للجميع',
                          style: context.typography.caption.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _shareWithCommunity,
                    onChanged: (v) => setState(() => _shareWithCommunity = v),
                    activeColor: context.colors.teal,
                    activeTrackColor: context.colors.teal.withOpacity(0.3),
                    inactiveTrackColor: context.colors.border,
                    inactiveThumbColor: context.colors.textDim,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            onTap: _isLoading ? null : () async => _save(),
            label: _shareWithCommunity
                ? 'إضافة ومشاركة مع المجتمع'
                : 'إضافة الذكر',
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SHARED HELPER WIDGET
// ─────────────────────────────────────────
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
