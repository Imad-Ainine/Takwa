// Widget smoke test. Picked as the first widget test in the suite because
// it's self-contained (SharedPreferences + an in-memory DB, no Supabase/
// dotenv/native-plugin bootstrapping like the real app shell needs) and it
// doubles as a regression test for the provider-migration bug fixed
// alongside it: this screen used to read a legacy provider nothing ever
// wrote to, so it always rendered a stuck-at-zero state.
//
// See the "Testing Strategy" section of the engineering audit for context.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/providers/shared_preferences_provider.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/features/quran/data/quran_models.dart';
import 'package:takwa/features/quran/presentation/screens/khatma_progress_screen.dart';
import 'package:takwa/features/quran/providers/quran_providers.dart';
import 'package:takwa/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Not under test here, and overriding it avoids exercising a real
          // Drift watch-stream (with its own async teardown timing) for a
          // screen that doesn't otherwise touch the database.
          ramadanModeProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const KhatmaProgressScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders without throwing when there is no active khatma', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(tester.takeException(), isNull);
    // khatmaScreenTitle (AR)
    expect(find.text('تقدم الختمة'), findsOneWidget);
    // khatmaProgressPercent('0.0') (AR) → '0.0٪ مكتملة'
    expect(find.text('0.0٪ مكتملة'), findsOneWidget);
  });

  testWidgets(
    'reflects live khatmaExProvider progress, not the legacy provider',
    (tester) async {
      await pumpScreen(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(KhatmaProgressScreen)),
      );
      await container
          .read(khatmaExProvider.notifier)
          .createNew(
            label: 'ختمة الاختبار',
            type: KhatmaType.muyassara,
            startPage: 1,
          );
      await container.read(khatmaExProvider.notifier).advancePage(61);
      await tester.pumpAndSettle();

      // pagesRead = 61 - 1 = 60; 60 / 604 * 100 = 9.9 (1dp), matching the
      // widget's own `(progress * 100).toStringAsFixed(1)` formatting.
      // khatmaProgressPercent('9.9') (AR) → '9.9٪ مكتملة'
      expect(tester.takeException(), isNull);
      expect(find.text('9.9٪ مكتملة'), findsOneWidget);
    },
  );
}
