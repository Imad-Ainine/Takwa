// ═══════════════════════════════════════════════════════════════
//  lib/core/supabase/supabase_providers.dart
//  تقوى — Supabase Providers
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../core/supabase/supabase_config.dart';

// Removed authServiceProvider as it's redundant with static SupabaseService

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value?.session?.user;
});

final connectivityProvider = StreamProvider<bool>((ref) async* {
  // Logic to check internet etc. For now simple supabase ping
  while (true) {
    try {
      await SupabaseConfig.client.from('profiles').select('id').limit(1);
      yield true;
    } catch (_) {
      yield false;
    }
    await Future.delayed(const Duration(seconds: 30));
  }
});

/// Fetches the user's profile information (username, avatar, etc.)
final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  // Return a stream of the profile for the current user
  return SupabaseConfig.client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((list) => list.isNotEmpty ? list.first : null);
});

// Remote Data Streams
final remoteStatsProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(null);

  return SupabaseConfig.client
      .from('user_stats')
      .stream(primaryKey: ['user_id'])
      .map((list) {
        final filtered = list.where((m) => m['user_id'] == uid).toList();
        return filtered.isNotEmpty ? filtered.first : null;
      });
});

final remoteTodayRecordProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(null);

  final today = DateTime.now().toIso8601String().split('T')[0];
  return SupabaseConfig.client
      .from('daily_records')
      .stream(primaryKey: ['id'])
      .map((list) {
        final filtered = list
            .where((m) => m['user_id'] == uid && m['date'] == today)
            .toList();
        return filtered.isNotEmpty ? filtered.first : null;
      });
});
