// ═══════════════════════════════════════════════════════════════
//  lib/features/books/presentation/screens/book_pdf_reader_screen.dart
//  تقوى — Premium Islamic Books PDF Reader
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/features/books/data/books_data.dart';

class BookPdfReaderScreen extends StatefulWidget {
  final IslamicBook book;

  const BookPdfReaderScreen({super.key, required this.book});

  @override
  State<BookPdfReaderScreen> createState() => _BookPdfReaderScreenState();
}

class _BookPdfReaderScreenState extends State<BookPdfReaderScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _showUI = true;
  int _currentPage = 1;
  int _totalPages = 0;
  late AnimationController _uiAnim;
  late Animation<double> _uiFade;

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
  }

  @override
  void dispose() {
    _uiAnim.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

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
      if (hex.startsWith('#')) return Color(int.parse('0xFF${hex.substring(1)}'));
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return const Color(0xFFC8A96E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final accentColor = _parseColor(widget.book.coverColor);

    if (widget.book.pdfUrl == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(widget.book.titleAr, style: const TextStyle(fontFamily: 'Amiri')),
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
      backgroundColor: const Color(0xFF1A1A1A), // Dark bg for PDF
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            // PDF Viewer
            SfPdfViewer.network(
              widget.book.pdfUrl!,
              key: _pdfViewerKey,
              onPageChanged: (details) {
                setState(() => _currentPage = details.newPageNumber);
              },
              onDocumentLoaded: (details) {
                setState(() => _totalPages = details.document.pages.count);
              },
              canShowScrollHead: false,
              enableDoubleTapZooming: true,
            ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _uiFade,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
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
                        icon: Icons.close,
                      ),
                      const SizedBox(width: 16),
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
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'نسخة PDF مطابِقة',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Progress Indicator
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _uiFade,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '$_currentPage / $_totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _CircleBtn({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
