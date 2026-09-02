import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/database_providers.dart';

/// The languages the app UI can be displayed in. Content that hasn't been
/// translated yet (Quran/duas/asma data) still renders in Arabic regardless
/// of this setting.
const supportedAppLocales = [Locale('ar'), Locale('en')];

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref ref;
  static const _key = 'appLocale';

  LocaleNotifier(this.ref) : super(const Locale('ar')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final s = ref.read(settingsDaoProvider);
    final code = await s.get(_key) ?? 'ar';
    state = supportedAppLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => const Locale('ar'),
    );
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final s = ref.read(settingsDaoProvider);
    await s.set(_key, locale.languageCode);
  }
}
