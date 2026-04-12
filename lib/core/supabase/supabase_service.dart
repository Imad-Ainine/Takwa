// ═══════════════════════════════════════════════════════════════
//  lib/core/supabase/supabase_service.dart
//  محاسبة النفس — Supabase Unified Service
// ═══════════════════════════════════════════════════════════════

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'supabase_config.dart';

class SupabaseService {
  static SupabaseClient get _db => SupabaseConfig.client;

  // ─────────────── AUTH ───────────────
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final res = await _db.auth.signUp(
      email: email, 
      password: password, 
      data: {'username': username, 'avatar_emoji': '🌙'},
    );
    if (res.user != null) {
      await _createProfile(res.user!, username);
    }
    return res;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _db.auth.signInWithPassword(
        email: email, password: password);
  }

  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      // 1. Web client ID from Google Cloud Console
      // Note: In a real app, this should be in .env
      const webClientId = 'YOUR_WEB_CLIENT_ID_FROM_GOOGLE_CONSOLE';
      const iosClientId = 'YOUR_IOS_CLIENT_ID_FROM_GOOGLE_CONSOLE';

      final googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final res = await _db.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // If it's a new user, internal profiles are handled by DB triggers
      // but we can ensure username is set if available
      if (res.user != null) {
        final username = googleUser.displayName ?? 'user_${res.user!.id.substring(0, 5)}';
        await _db.from('profiles').upsert({
          'id': res.user!.id,
          'username': username,
          'email': res.user!.email,
          'avatar_emoji': '🌙',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return res;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _db.auth.signOut();
  }

  static Future<void> _createProfile(User user, String username) async {
    await _db.from('profiles').upsert({
      'id': user.id,
      'username': username,
      'email': user.email,
      'avatar_emoji': '🌙',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Default settings
    await _db.from('user_settings').upsert({
      'user_id': user.id,
      'madhab': 'shafi',
      'calc_method': 'MWL',
      'prayer_reminder': true,
      'muhasaba_reminder': true,
      'evening_reminder_time': '21:00',
      'ramadan_mode': false,
    });
  }

  // ─────────────── DATA ───────────────
  static Future<void> upsertDailyRecord(Map<String, dynamic> record) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    await _db.from('daily_records').upsert({
      ...record,
      'user_id': uid,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,date');
  }

  static Future<List<Map<String, dynamic>>> getRecordsRange({
    required DateTime from, required DateTime to}) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];

    final data = await _db.from('daily_records')
        .select()
        .eq('user_id', uid)
        .gte('date', _dateStr(from))
        .lte('date', _dateStr(to))
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<Map<String, dynamic>?> getSettings() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return null;

    return await _db.from('user_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
  }

  static Future<void> updateSettings(Map<String, dynamic> settings) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    await _db.from('user_settings').upsert({
      ...settings,
      'user_id': uid,
    }, onConflict: 'user_id');
  }

  static Future<void> updateUserStats({
    required int totalPoints,
    required int currentStreak,
    required int longestStreak,
    required int quranPages,
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    await _db.from('user_stats').upsert({
      'user_id': uid,
      'total_points': totalPoints,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'quran_pages': quranPages,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  static String _dateStr(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
}
