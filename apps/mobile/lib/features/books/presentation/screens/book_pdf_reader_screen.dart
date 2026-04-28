// ═══════════════════════════════════════════════════════════════
//  lib/features/books/presentation/screens/book_pdf_reader_screen.dart
//  تقوى — Premium Islamic Books PDF Reader (manual download edition)
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/features/books/data/books_data.dart';
import 'package:takwa/features/books/data/pdf_download_service.dart';
import 'package:takwa/features/books/providers/pdf_session_provider.dart';

class BookPdfReaderScreen extends ConsumerStatefulWidget {
  final IslamicBook book;

  const BookPdfReaderScreen({super.key, required this.book});

  @override
  ConsumerState<BookPdfReaderScreen> createState() =>
      _BookPdfReaderScreenState();
}

class _BookPdfReaderScreenState extends ConsumerState<BookPdfReaderScreen>
    with SingleTickerProviderStateMixin {
  // ── PDF viewer ────────────────────────────
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();

  // ── Download state ────────────────────────
  File? _localFile;
  bool _isLoading = true;
  double _downloadProgress = 0.0;
  String? _error;
  StreamController<double>? _progressCtrl;

  // ── Text Selection / Share ────────────────
  OverlayEntry? _shareOverlayEntry;
  String _selectedText = '';
  bool _isTextSelected = false;

  // ── UI visibility animation ───────────────
  bool _showUI = true;
  late AnimationController _uiAnim;

  // ── Session Notifier ──────────────────────
  late PdfSessionNotifier _sessionNotifier;

  // ── Convenience getter ────────────────────
  String get _bookId => widget.book.id;

  // ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _uiAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Load persisted session (page + timer)
    _sessionNotifier = ref.read(pdfSessionProvider(_bookId).notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionNotifier.loadSession(_bookId);
    });

    // Kick off PDF download
    if (widget.book.pdfUrl != null) {
      _startDownload();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _hideShareMenu();
    _uiAnim.dispose();
    _pdfController.dispose();
    _progressCtrl?.close();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── PDF Download ──────────────────────────

  Future<void> _startDownload() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _downloadProgress = 0.0;
      _localFile = null;
    });

    // Close any existing stream
    await _progressCtrl?.close();
    _progressCtrl = StreamController<double>.broadcast();

    _progressCtrl!.stream.listen((progress) {
      if (mounted) setState(() => _downloadProgress = progress);
    });

    try {
      final file = await PdfDownloadService.getOrDownload(
        widget.book.pdfUrl!,
        progressController: _progressCtrl,
      );
      if (mounted) {
        setState(() {
          _localFile = file;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ── UI helpers ────────────────────────────

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
    if (_showUI) {
      _uiAnim.forward();
    } else {
      _uiAnim.reverse();
    }
  }

  void _showShareMenu() {
    _hideShareMenu();
    _shareOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return Transform.scale(
                scale: val,
                child: Opacity(opacity: val.clamp(0.0, 1.0), child: child),
              );
            },
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Share.share(_selectedText);
                    _pdfController.clearSelection();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8A96E),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'مشاركة النص',
                          style: TextStyle(
                            color: Colors.black87,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_shareOverlayEntry!);
  }

  void _hideShareMenu() {
    if (_shareOverlayEntry != null) {
      _shareOverlayEntry!.remove();
      _shareOverlayEntry = null;
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null) return const Color(0xFFC8A96E);
    try {
      if (hex.startsWith('0x')) return Color(int.parse(hex));
      if (hex.startsWith('#')) {
        return Color(int.parse('0xFF${hex.substring(1)}'));
      }
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return const Color(0xFFC8A96E);
    }
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final accentColor = _parseColor(widget.book.coverColor);
    final session = ref.watch(pdfSessionProvider(_bookId));

    // No PDF URL fallback
    if (widget.book.pdfUrl == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          leading: const CustomLeadingButton(),
          title: Text(
            widget.book.titleAr,
            style: const TextStyle(fontFamily: 'Amiri'),
          ),
          backgroundColor: colors.deep,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colors.textDim),
              const SizedBox(height: 16),
              Text(
                'عذراً، لم يتم العثور على رابط PDF لهذا الكتاب.',
                style: typography.bodyMedium,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // ── PDF Viewer / Loading / Error ──
          if (_error != null)
            _buildErrorView()
          else if (_isLoading || _localFile == null)
            _buildLoadingView(accentColor)
          else
            SfPdfViewer.file(
              _localFile!,
              key: _pdfViewerKey,
              controller: _pdfController,
              enableTextSelection: true,
              canShowTextSelectionMenu: true,
              canShowPageLoadingIndicator: true,
              canShowScrollHead: true,
              onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                if (details.selectedText == null ||
                    details.selectedText!.isEmpty) {
                  _isTextSelected = false;
                  _hideShareMenu();
                } else {
                  _isTextSelected = true;
                  _selectedText = details.selectedText!;
                  _showShareMenu();
                }
              },
              onDocumentLoaded: (details) {
                final total = details.document.pages.count;
                Future.microtask(() {
                  if (!mounted) return;
                  _sessionNotifier.setTotal(total);
                  _sessionNotifier.start();
                });

                final savedPage = session.currentPage;
                if (savedPage > 1 && savedPage <= total) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _pdfController.jumpToPage(savedPage);
                  });
                }
              },
              onTap: (details) {
                if (_isTextSelected) {
                  _pdfController.clearSelection();
                } else {
                  _toggleUI();
                }
              },
              onPageChanged: (details) {
                _hideShareMenu();
                _pdfController.clearSelection();
                _sessionNotifier.setPage(details.newPageNumber);
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _error = details.error;
                });
              },
              enableDoubleTapZooming: true,
            ),

          // ── Top App Bar ─────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: !_showUI,
                child: _buildTopBar(session, accentColor),
              ),
            ),
          ),

          // ── Bottom Progress Panel ───────
          if (!_isLoading && _localFile != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showUI ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: !_showUI,
                  child: _buildBottomPanel(session, accentColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────

  Widget _buildLoadingView(Color accentColor) {
    final pct = (_downloadProgress * 100).toInt();
    return Center(
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TakwaLoadingIndicator(color: accentColor, strokeWidth: 2.5),
            const SizedBox(height: 20),
            Text(
              _downloadProgress > 0
                  ? 'جاري التحميل... $pct%'
                  : 'جاري التحميل...',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.orangeAccent,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'تعذّر تحميل الملف',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8A96E),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(PdfSessionState session, Color accentColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 18,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          const CustomLeadingButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.book.titleAr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.book.authorAr,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontFamily: 'Amiri',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(PdfSessionState session, Color accentColor) {
    final total = session.totalPages;
    final page = session.currentPage;
    final progress = session.progressFraction;

    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.of(context).padding.bottom + 18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reading progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // Reading time
              _InfoChip(icon: Icons.timer_outlined, label: session.timerLabel),
              const SizedBox(width: 8),

              // Page slider
              Expanded(
                child: total > 1
                    ? SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          trackHeight: 3,
                          activeTrackColor: accentColor,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: accentColor,
                          overlayColor: accentColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          min: 1,
                          max: total.toDouble(),
                          value: page.clamp(1, total).toDouble(),
                          onChanged: (v) {
                            _sessionNotifier.setPage(v.round());
                          },
                          onChangeEnd: (v) {
                            _pdfController.jumpToPage(v.round());
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),

              // Page counter chip
              _InfoChip(
                icon: Icons.menu_book_rounded,
                label: total > 0 ? '$page / $total' : '—',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SMALL WIDGETS
// ─────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
