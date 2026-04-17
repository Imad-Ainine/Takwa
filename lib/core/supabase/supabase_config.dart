// ═══════════════════════════════════════════════════════════════
//  lib/core/supabase/supabase_config.dart
//  تقوى — Supabase Configuration
// ═══════════════════════════════════════════════════════════════

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String url = dotenv.env['SUPABASE_URL']!;
  static String anonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static User? get currentUser => client.auth.currentUser;
  static String? get userId => currentUser?.id;
}

final supabaseProvider = Provider<SupabaseClient>(
  (ref) => SupabaseConfig.client,
);
