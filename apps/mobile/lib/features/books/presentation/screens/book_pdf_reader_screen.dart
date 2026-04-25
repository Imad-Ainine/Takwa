// ═══════════════════════════════════════════════════════════════
//  lib/features/books/presentation/screens/book_pdf_reader_screen.dart
//  تقوى — Islamic Books PDF Reader
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/features/books/data/books_data.dart';

class BookPdfReaderScreen extends StatelessWidget {
  final IslamicBook book;

  const BookPdfReaderScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (book.pdfUrl == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            book.titleAr,
            style: const TextStyle(fontFamily: 'Amiri'),
          ),
          backgroundColor: colors.deep,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            'عذراً، لم يتم العثور على رابط PDF لهذا الكتاب.',
            style: context.typography.headingMedium,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          book.titleAr,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.deep,
        foregroundColor: Colors.white,
      ),
      // Automatically streams and displays the PDF
      body: SfPdfViewer.network(
        book.pdfUrl!,
        canShowScrollHead: false,
        canShowScrollStatus: true,
      ),
    );
  }
}
