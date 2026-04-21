// ═══════════════════════════════════════════════════════════════
//  lib/core/supabase/supabase_service.dart
//  تقوى — Supabase Unified Service
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'supabase_config.dart';

class SupabaseService {
  static SupabaseClient get _db => SupabaseConfig.client;

  /// Helper لإجراء الطلبات مع إعادة المحاولة في حال فشل الشبكة
  static Future<T> _safeRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (true) {
      attempts++;
      try {
        return await request();
      } on SocketException catch (e) {
        if (attempts >= maxAttempts) rethrow;
        print('Supabase Request failed (SocketException), retrying $attempts/$maxAttempts: $e');
        await Future.delayed(const Duration(seconds: 1));
      } on http.ClientException catch (e) {
        if (attempts >= maxAttempts) rethrow;
        print('Supabase Request failed (ClientException), retrying $attempts/$maxAttempts: $e');
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // الأخطاء الأخرى نمررها مباشرة (مثل أخطاء الـ SQL أو الصلاحيات)
        rethrow;
      }
    }
  }

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
    return await _db.auth.signInWithPassword(email: email, password: password);
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
        final username =
            googleUser.displayName ?? 'user_${res.user!.id.substring(0, 5)}';
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

    await _safeRequest(() => _db.from('daily_records').upsert({
          ...record,
          'user_id': uid,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,date'));
  }

  static Future<List<Map<String, dynamic>>> getRecordsRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];

    final data = await _db
        .from('daily_records')
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

    return await _safeRequest(() => _db
        .from('user_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle());
  }

  static Future<void> updateSettings(Map<String, dynamic> settings) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    // Ensure we only send valid columns and map them if necessary
    final payload = <String, dynamic>{
      'user_id': uid,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final mapping = {
      'madhab': 'madhab',
      'ramadanMode': 'ramadan_mode',
      'calcMethod': 'calc_method',
      'prayerReminder': 'prayer_reminder',
      'eveningMuhasabaReminder': 'muhasaba_reminder',
      'eveningReminderTime': 'evening_reminder_time',
      'language': 'language',
      'wakeUpBeforeFajr': 'wake_up_before_fajr',
      'morningAdhkarReminder': 'morning_adhkar_reminder',
      'eveningAdhkarReminder': 'evening_adhkar_reminder',
    };

    for (var entry in mapping.entries) {
      if (settings.containsKey(entry.key)) {
        payload[entry.value] = settings[entry.key];
      } else if (settings.containsKey(entry.value)) {
        payload[entry.value] = settings[entry.value];
      }
    }

    await _safeRequest(
      () => _db.from('user_settings').upsert(payload, onConflict: 'user_id'),
    );
  }

  static Future<void> updateUserStats({
    required int totalPoints,
    required int currentStreak,
    required int longestStreak,
    required int quranPages,
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    await _db
        .from('profiles')
        .update({
          'total_points': totalPoints,
          'current_streak': currentStreak,
          'highest_streak': longestStreak,
          'quran_pages': quranPages,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', uid);
  }

  // ─────────────── PROHIBITIONS ───────────────
  static Future<void> upsertProhibitionLog(Map<String, dynamic> log) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    await _safeRequest(() => _db.from('prohibitions_log').upsert({
          ...log,
          'user_id': uid,
        }, onConflict: 'record_id,category'));
  }

  static Future<List<Map<String, dynamic>>> getProhibitionLogs({
    required DateTime from,
    required DateTime to,
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];

    final data = await _db
        .from('prohibitions_log')
        .select()
        .eq('user_id', uid)
        .gte('date', _dateStr(from))
        .lte('date', _dateStr(to));
    return List<Map<String, dynamic>>.from(data);
  }

  // ─────────────── CUSTOM IBADAH ───────────────
  static Future<void> upsertCustomIbadah(Map<String, dynamic> ibadah) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    await _safeRequest(
      () => _db.from('custom_ibadah').upsert({...ibadah, 'user_id': uid}),
    );
  }

  static Future<List<Map<String, dynamic>>> getCustomIbadah() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];

    final data = await _db.from('custom_ibadah').select().eq('user_id', uid);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> upsertCustomIbadahLog(Map<String, dynamic> log) async {
    final uid = SupabaseConfig.userId; 
    if (uid == null) return;

    await _safeRequest(
      () => _db.from('custom_ibadah_log').upsert({...log, 'user_id': uid}),
    );
  }

  static Future<void> deleteCustomIbadah(int id) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    await _safeRequest(
      () => _db.from('custom_ibadah').delete().eq('id', id).eq('user_id', uid),
    );
  }

  static Future<List<Map<String, dynamic>>> getCustomIbadahLogs({
    required DateTime from,
    required DateTime to,
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];

    final data = await _db
        .from('custom_ibadah_log')
        .select()
        .eq('user_id', uid)
        .gte('date', _dateStr(from))
        .lte('date', _dateStr(to));
    return List<Map<String, dynamic>>.from(data);
  }

  // ─────────────── ACHIEVEMENTS ───────────────
  static Future<void> upsertAchievement(
    Map<String, dynamic> achievement,
  ) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    await _db.from('achievements').upsert({
      ...achievement,
      'user_id': uid,
      'earned_at': achievement['earned_at'] ?? DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,type');
  }

  static Future<List<Map<String, dynamic>>> getEarnedAchievements() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];

    final data = await _db.from('achievements').select().eq('user_id', uid);
    return List<Map<String, dynamic>>.from(data);
  }

  static String _dateStr(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // ─────────────── USER PERSONAL ADHKAR ───────────────
  static Future<List<Map<String, dynamic>>> getUserAdhkar() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];
    final data = await _db
        .from('user_adhkar')
        .select()
        .eq('user_id', uid)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addUserAdhkar({
    required String textAr,
    int count = 1,
    String categoryHint = 'general',
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    await _db.from('user_adhkar').insert({
      'user_id': uid,
      'text_ar': textAr,
      'count': count,
      'category_hint': categoryHint,
    });
  }

  static Future<void> deleteUserAdhkar(String id) async {
    await _db.from('user_adhkar').delete().eq('id', id);
  }

  // ─────────────── USER PERSONAL DUAS ───────────────
  static Future<List<Map<String, dynamic>>> getUserDuas() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];
    final data = await _db
        .from('user_duas')
        .select()
        .eq('user_id', uid)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addUserDua({
    required String titleAr,
    required String textAr,
    String occasion = '',
    String source = '',
    String emoji = '🤲',
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    await _db.from('user_duas').insert({
      'user_id': uid,
      'title_ar': titleAr,
      'text_ar': textAr,
      'occasion': occasion,
      'source': source,
      'emoji': emoji,
    });
  }

  static Future<void> deleteUserDua(String id) async {
    await _db.from('user_duas').delete().eq('id', id);
  }

  // ─────────────── COMMUNITY ADHKAR ───────────────
  static Future<List<Map<String, dynamic>>> getCommunityAdhkar() async {
    final data = await _db
        .from('community_adhkar')
        .select()
        .eq('approved', true)
        .order('likes', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> likeAdhkar(String id) async {
    // Use an RPC or a direct update. We do a read-then-write for simplicity;
    // on production you'd use a Postgres function to avoid race conditions.
    final row = await _db
        .from('community_adhkar')
        .select('likes')
        .eq('id', id)
        .single();
    final currentLikes = (row['likes'] as int?) ?? 0;
    await _db
        .from('community_adhkar')
        .update({'likes': currentLikes + 1})
        .eq('id', id);
  }

  static Future<void> shareAdhkarToCommunity({
    required String textAr,
    int count = 1,
    String categoryHint = 'general',
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    await _db.from('community_adhkar').insert({
      'shared_by': uid,
      'text_ar': textAr,
      'count': count,
      'category_hint': categoryHint,
    });
  }

  // ─────────────── COMMUNITY DUAS ───────────────
  static Future<List<Map<String, dynamic>>> getCommunityDuas() async {
    final data = await _db
        .from('community_duas')
        .select()
        .eq('approved', true)
        .order('likes', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> likeDua(String id) async {
    final row = await _db
        .from('community_duas')
        .select('likes')
        .eq('id', id)
        .single();
    final currentLikes = (row['likes'] as int?) ?? 0;
    await _db
        .from('community_duas')
        .update({'likes': currentLikes + 1})
        .eq('id', id);
  }

  static Future<void> shareDuaToCommunity({
    required String titleAr,
    required String textAr,
    String occasion = '',
    String source = '',
    String emoji = '🤲',
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    await _db.from('community_duas').insert({
      'shared_by': uid,
      'title_ar': titleAr,
      'text_ar': textAr,
      'occasion': occasion,
      'source': source,
      'emoji': emoji,
    });
  }
}
