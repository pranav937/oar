import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../theme/otr_theme.dart';

class PdfViewerPage extends StatelessWidget {
  final String filePath;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          debugPrint('PDF Error: $error');
        },
        onPageError: (page, error) {
          debugPrint('PDF Page Error: $page: $error');
        },
      ),
    );
  }
}
