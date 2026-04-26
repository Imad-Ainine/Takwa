// ═══════════════════════════════════════════════════════════════
//  lib/features/books/presentation/screens/book_pdf_reader_screen.dart
//  تقوى — Premium Islamic Books PDF Reader (full tracker edition)
// ═══════════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/features/books/data/books_data.dart';
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
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  // ── UI visibility animation ───────────────
  bool _showUI = true;
  late AnimationController _uiAnim;
  late Animation<double> _uiFade;

  // ── Text selection overlay ────────────────
  String _selectedText = '';

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
    _uiFade = CurvedAnimation(parent: _uiAnim, curve: Curves.easeInOut);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Load persisted session (page + timer)
    _sessionNotifier = ref.read(pdfSessionProvider(_bookId).notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionNotifier.loadSession(_bookId);
    });

    if (widget.book.pdfUrl != null) {
      _downloadPdf(widget.book.pdfUrl!);
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _uiAnim.dispose();
    _pdfController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── PDF Download ──────────────────────────

  Future<void> _downloadPdf(String url) async {
    try {
      final client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final request = await client.getUrl(Uri.parse(url));
      request.headers
        ..set(
          HttpHeaders.userAgentHeader,
          'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
        )
        ..set(HttpHeaders.acceptHeader, 'application/pdf,*/*');

      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final builder = BytesBuilder();
      await for (final chunk in response) {
        builder.add(chunk);
      }
      client.close();

      if (mounted) {
        setState(() {
          _pdfBytes = builder.toBytes();
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

  // ── Text selection actions ────────────────

  void _copyText() {
    if (_selectedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _selectedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ', textDirection: TextDirection.rtl),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareText() {
    if (_selectedText.isEmpty) return;
    Share.share(_selectedText);
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
          // ── PDF Viewer ──────────────────
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            )
          else if (_error != null)
            _buildErrorView()
          else
            SfPdfViewer.memory(
              _pdfBytes!,
              key: _pdfViewerKey,
              controller: _pdfController,
              onDocumentLoaded: (details) {
                final total = details.document.pages.count;
                // Wrap in microtask to avoid updating during build
                Future.microtask(() {
                  if (!mounted) return;
                  _sessionNotifier.setTotal(total);
                  _sessionNotifier.start();
                });

                // Restore last page
                final savedPage = session.currentPage;
                if (savedPage > 1 && savedPage <= total) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _pdfController.jumpToPage(savedPage);
                  });
                }
              },
              onTap: (details) {
                // Only toggle UI when no text is selected
                if (_selectedText.isEmpty) _toggleUI();
              },
              onPageChanged: (details) {
                _sessionNotifier.setPage(details.newPageNumber);
              },
              onTextSelectionChanged: (details) {
                setState(() => _selectedText = details.selectedText ?? '');
              },
              canShowScrollHead: false,
              enableDoubleTapZooming: true,
            ),

          // ── Top App Bar ─────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_showUI,
              child: FadeTransition(
                opacity: _uiFade,
                child: _buildTopBar(session, accentColor),
              ),
            ),
          ),

          // ── Bottom Progress Panel ───────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_showUI,
              child: FadeTransition(
                opacity: _uiFade,
                child: _buildBottomPanel(session, accentColor),
              ),
            ),
          ),

          // ── Text Selection Action Bar ───
          if (_selectedText.isNotEmpty)
            Positioned(
              top:
                  MediaQuery.of(context).padding.top +
                  70, // safe positioning below TopBar
              left: 16,
              right: 16,
              child: _TextActionBar(
                onCopy: () {
                  _copyText();
                  setState(() => _selectedText = '');
                  _pdfController.clearSelection();
                },
                onShare: () {
                  _shareText();
                  setState(() => _selectedText = '');
                  _pdfController.clearSelection();
                },
                onDismiss: () {
                  setState(() => _selectedText = '');
                  _pdfController.clearSelection();
                },
              ),
            ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text(
              'تعذّر تحميل الملف',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Amiri',
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _downloadPdf(widget.book.pdfUrl!);
              },
              icon: const Icon(Icons.refresh, color: Colors.white70),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: Colors.white70),
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
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        16,
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
          _CircleBtn(
            onTap: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new_rounded,
          ),
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
          const SizedBox(width: 12),
          // Timer chip
          // _TimerChip(label: session.timerLabel, accentColor: accentColor),
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
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
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
          // Progress bar
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

          // Slider row
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

class _CircleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _CircleBtn({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _TimerChip({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: accentColor, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

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

class _TextActionBar extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onDismiss;

  const _TextActionBar({
    required this.onCopy,
    required this.onShare,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionBtn(icon: Icons.copy_rounded, label: 'نسخ', onTap: onCopy),
            const SizedBox(width: 4),
            const VerticalDivider(
              color: Colors.white12,
              width: 16,
              thickness: 1,
            ),
            const SizedBox(width: 4),
            _ActionBtn(
              icon: Icons.share_rounded,
              label: 'مشاركة',
              onTap: onShare,
            ),
            const SizedBox(width: 4),
            const VerticalDivider(
              color: Colors.white12,
              width: 16,
              thickness: 1,
            ),
            const SizedBox(width: 4),
            _ActionBtn(
              icon: Icons.close_rounded,
              label: 'إغلاق',
              onTap: onDismiss,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFC8A96E);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: c, fontSize: 10, fontFamily: 'Amiri'),
          ),
        ],
      ),
    );
  }
}
