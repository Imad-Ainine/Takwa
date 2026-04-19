// ═══════════════════════════════════════════════════════════════
//  lib/core/providers/user_content_providers.dart
//  تقوى — Providers for user personal & community Adhkar/Duas
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/supabase/supabase_service.dart';

// ── Models ──────────────────────────────────────────────────────

class UserAdhkarItem {
  final String id;
  final String textAr;
  final int count;
  final String categoryHint;
  UserAdhkarItem({
    required this.id,
    required this.textAr,
    required this.count,
    required this.categoryHint,
  });
  factory UserAdhkarItem.fromMap(Map<String, dynamic> m) => UserAdhkarItem(
        id: m['id'] as String,
        textAr: m['text_ar'] as String,
        count: (m['count'] as int?) ?? 1,
        categoryHint: (m['category_hint'] as String?) ?? 'general',
      );
}

class UserDuaItem {
  final String id;
  final String titleAr;
  final String textAr;
  final String occasion;
  final String source;
  final String emoji;
  UserDuaItem({
    required this.id,
    required this.titleAr,
    required this.textAr,
    required this.occasion,
    required this.source,
    required this.emoji,
  });
  factory UserDuaItem.fromMap(Map<String, dynamic> m) => UserDuaItem(
        id: m['id'] as String,
        titleAr: m['title_ar'] as String,
        textAr: m['text_ar'] as String,
        occasion: (m['occasion'] as String?) ?? '',
        source: (m['source'] as String?) ?? '',
        emoji: (m['emoji'] as String?) ?? '🤲',
      );
}

class CommunityAdhkarItem {
  final String id;
  final String textAr;
  final int count;
  final int likes;
  final bool likedByMe;
  CommunityAdhkarItem({
    required this.id,
    required this.textAr,
    required this.count,
    required this.likes,
    this.likedByMe = false,
  });
  factory CommunityAdhkarItem.fromMap(Map<String, dynamic> m) =>
      CommunityAdhkarItem(
        id: m['id'] as String,
        textAr: m['text_ar'] as String,
        count: (m['count'] as int?) ?? 1,
        likes: (m['likes'] as int?) ?? 0,
      );

  CommunityAdhkarItem copyWith({int? likes, bool? likedByMe}) =>
      CommunityAdhkarItem(
        id: id,
        textAr: textAr,
        count: count,
        likes: likes ?? this.likes,
        likedByMe: likedByMe ?? this.likedByMe,
      );
}

class CommunityDuaItem {
  final String id;
  final String titleAr;
  final String textAr;
  final String occasion;
  final String source;
  final String emoji;
  final int likes;
  final bool likedByMe;
  CommunityDuaItem({
    required this.id,
    required this.titleAr,
    required this.textAr,
    required this.occasion,
    required this.source,
    required this.emoji,
    required this.likes,
    this.likedByMe = false,
  });
  factory CommunityDuaItem.fromMap(Map<String, dynamic> m) => CommunityDuaItem(
        id: m['id'] as String,
        titleAr: m['title_ar'] as String,
        textAr: m['text_ar'] as String,
        occasion: (m['occasion'] as String?) ?? '',
        source: (m['source'] as String?) ?? '',
        emoji: (m['emoji'] as String?) ?? '🤲',
        likes: (m['likes'] as int?) ?? 0,
      );

  CommunityDuaItem copyWith({int? likes, bool? likedByMe}) => CommunityDuaItem(
        id: id,
        titleAr: titleAr,
        textAr: textAr,
        occasion: occasion,
        source: source,
        emoji: emoji,
        likes: likes ?? this.likes,
        likedByMe: likedByMe ?? this.likedByMe,
      );
}


// ── User Adhkar Notifier ─────────────────────────────────────────

class UserAdhkarNotifier extends AsyncNotifier<List<UserAdhkarItem>> {
  @override
  Future<List<UserAdhkarItem>> build() async {
    final raw = await SupabaseService.getUserAdhkar();
    return raw.map(UserAdhkarItem.fromMap).toList();
  }

  Future<void> add({
    required String textAr,
    int count = 1,
    String categoryHint = 'general',
  }) async {
    await SupabaseService.addUserAdhkar(
      textAr: textAr,
      count: count,
      categoryHint: categoryHint,
    );
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await SupabaseService.deleteUserAdhkar(id);
    state = AsyncData(
      (state.value ?? []).where((e) => e.id != id).toList(),
    );
  }

  Future<void> shareAdhkar(UserAdhkarItem item) async {
    await SupabaseService.shareAdhkarToCommunity(
      textAr: item.textAr,
      count: item.count,
      categoryHint: item.categoryHint,
    );
    // refresh community feed
    ref.invalidate(communityAdhkarProvider);
  }
}

final userAdhkarProvider =
    AsyncNotifierProvider<UserAdhkarNotifier, List<UserAdhkarItem>>(
  UserAdhkarNotifier.new,
);

// ── User Duas Notifier ────────────────────────────────────────────

class UserDuasNotifier extends AsyncNotifier<List<UserDuaItem>> {
  @override
  Future<List<UserDuaItem>> build() async {
    final raw = await SupabaseService.getUserDuas();
    return raw.map(UserDuaItem.fromMap).toList();
  }

  Future<void> add({
    required String titleAr,
    required String textAr,
    String occasion = '',
    String source = '',
    String emoji = '🤲',
  }) async {
    await SupabaseService.addUserDua(
      titleAr: titleAr,
      textAr: textAr,
      occasion: occasion,
      source: source,
      emoji: emoji,
    );
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await SupabaseService.deleteUserDua(id);
    state = AsyncData(
      (state.value ?? []).where((e) => e.id != id).toList(),
    );
  }

  Future<void> shareDua(UserDuaItem item) async {
    await SupabaseService.shareDuaToCommunity(
      textAr: item.textAr,
      titleAr: item.titleAr,
      occasion: item.occasion,
      source: item.source,
      emoji: item.emoji,
    );
    ref.invalidate(communityDuasProvider);
  }
}

final userDuasProvider =
    AsyncNotifierProvider<UserDuasNotifier, List<UserDuaItem>>(
  UserDuasNotifier.new,
);

// ── Community Adhkar Notifier ─────────────────────────────────────

class CommunityAdhkarNotifier
    extends AsyncNotifier<List<CommunityAdhkarItem>> {
  @override
  Future<List<CommunityAdhkarItem>> build() async {
    final raw = await SupabaseService.getCommunityAdhkar();
    return raw.map(CommunityAdhkarItem.fromMap).toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> likeAdhkar(String id) async {
    // Optimistic update
    final current = state.value ?? [];
    state = AsyncData(
      current
          .map(
            (e) => e.id == id
                ? e.copyWith(likes: e.likes + 1, likedByMe: true)
                : e,
          )
          .toList(),
    );
    try {
      await SupabaseService.likeAdhkar(id);
    } catch (_) {
      // rollback on failure
      state = AsyncData(
        (state.value ?? [])
            .map(
              (e) => e.id == id
                  ? e.copyWith(
                      likes: e.likes - 1,
                      likedByMe: false,
                    )
                  : e,
            )
            .toList(),
      );
    }
  }
}

final communityAdhkarProvider = AsyncNotifierProvider<
    CommunityAdhkarNotifier, List<CommunityAdhkarItem>>(
  CommunityAdhkarNotifier.new,
);

// ── Community Duas Notifier ─────────────────────────────────────

class CommunityDuasNotifier extends AsyncNotifier<List<CommunityDuaItem>> {
  @override
  Future<List<CommunityDuaItem>> build() async {
    final raw = await SupabaseService.getCommunityDuas();
    return raw.map(CommunityDuaItem.fromMap).toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> likeDua(String id) async {
    // Optimistic update
    final current = state.value ?? [];
    state = AsyncData(
      current
          .map(
            (e) => e.id == id
                ? e.copyWith(likes: e.likes + 1, likedByMe: true)
                : e,
          )
          .toList(),
    );
    try {
      await SupabaseService.likeDua(id);
    } catch (_) {
      // Rollback
      state = AsyncData(
        (state.value ?? [])
            .map(
              (e) => e.id == id
                  ? e.copyWith(likes: e.likes - 1, likedByMe: false)
                  : e,
            )
            .toList(),
      );
    }
  }
}

final communityDuasProvider =
    AsyncNotifierProvider<CommunityDuasNotifier, List<CommunityDuaItem>>(
  CommunityDuasNotifier.new,
);
