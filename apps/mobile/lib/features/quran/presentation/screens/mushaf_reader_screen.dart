import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran_library.dart' as ql;
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/l10n/app_localizations.dart';

import '../../data/quran_data.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';

/// Roadmap item #4 ("Mushaf Mode") from the engineering audit's §8: a
/// page-image-style Quran view alongside the existing text reader
/// (quran_reader_screen.dart).
///
/// The existing reader groups ayahs by the real 604-page Mushaf boundary
/// (getPageAyahsByIndex) but renders them as reflowing Amiri text at a
/// user-adjustable font size — page numbers match a printed Mushaf, but
/// the line-by-line layout within a page doesn't. quran_library already
/// bundles the QPC v4 Uthmani Mushaf font plus its per-page glyph-position
/// data (assets/fonts/quran_fonts_qfc4, assets/jsons/qpc-v4.json.gz) and
/// exposes it as a ready-made widget — no new Mushaf page images/PDF
/// needed, which is why this was genuinely an assembly job on an
/// already-integrated dependency rather than a new subsystem.
///
/// Page position and last-read/Khatma tracking are kept in sync with the
/// text reader's own (quranStateProvider / quranLastReadProvider /
/// khatmaExProvider) so switching modes mid-session doesn't lose your
/// place or silently stop counting Khatma progress.
class MushafReaderScreen extends ConsumerStatefulWidget {
  final int initialPage;
  final bool startFromKhatma;

  const MushafReaderScreen({
    super.key,
    required this.initialPage,
    this.startFromKhatma = false,
  });

  @override
  ConsumerState<MushafReaderScreen> createState() =>
      _MushafReaderScreenState();
}

class _MushafReaderScreenState extends ConsumerState<MushafReaderScreen> {
  int _surahForPage(int page) {
    for (int i = kSurahData.length - 1; i >= 0; i--) {
      if (page >= kSurahData[i].startPage) return i + 1;
    }
    return 1;
  }

  void _onPageChanged(int pageIndex) {
    final page = pageIndex + 1;
    ref.read(quranStateProvider.notifier).setPage(page);

    if (widget.startFromKhatma) {
      ref.read(khatmaExProvider.notifier).advancePage(page);
    }

    final surahNum = _surahForPage(page);
    final surahName = ql.QuranLibrary.quranCtrl.surahs[surahNum - 1].arabicName;
    ref
        .read(quranLastReadProvider.notifier)
        .save(
          QuranBookmark(
            surahNum: surahNum,
            ayahNum: 1,
            page: page,
            surahName: surahName,
            savedAt: DateTime.now(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(quranStateProvider);
    final isDark = state.theme == ReaderTheme.night;
    final bgColor = isDark ? const Color(0xFF0D1E2D) : const Color(0xFFFBF6EC);
    final fgColor = isDark ? Colors.white70 : Colors.black87;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
                child: Row(
                  children: [
                    const CustomLeadingButton(),
                    Expanded(
                      child: Text(
                        l10n.quranReaderMushafModeTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: fgColor,
                        ),
                      ),
                    ),
                    // Balances the leading button so the title stays centered.
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ql.QuranLibraryScreen(
                parentContext: context,
                pageIndex: widget.initialPage - 1,
                isDark: isDark,
                backgroundColor: bgColor,
                textColor: fgColor,
                useDefaultAppBar: false,
                isShowTabBar: false,
                isShowDisplayModeBar: false,
                onPageChanged: _onPageChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
