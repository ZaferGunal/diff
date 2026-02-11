import 'package:flutter/material.dart';
import 'TILIDashboard.dart';
import '../widgets/theme_toggle.dart';
import 'package:google_fonts/google_fonts.dart';

class TILMathLearningPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const TILMathLearningPage({super.key, required this.toggleTheme});

  @override
  State<TILMathLearningPage> createState() => _TILMathLearningPageState();
}

class _TILMathLearningPageState extends State<TILMathLearningPage> {
  final PageController _pdfController = PageController();
  int _currentPdfPage = 0;
  final int _totalPdfPages = 3;

  static const List<String> pdfPageContents = [
    'Page 1: Algebra & Equations',
    'Page 2: Geometry & Trigonometry',
    'Page 3: Calculus & Statistics',
  ];

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1622) : const Color(0xFFF5F7FA);
    final text = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 40 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark, text),
              const SizedBox(height: 28),
              _buildTitleWithDownload(isDark, text),
              const SizedBox(height: 24),
              _buildPdfViewer(isDark, text, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color text) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2332) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF2A3A4A) : Colors.grey.withOpacity(0.2)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.functions_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text("MATHEMATICS", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
            ],
          ),
        ),
        const Spacer(),
        SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
      ],
    );
  }

  Widget _buildTitleWithDownload(bool isDark, Color text) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Study Guide", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 4),
              Text("Complete reference and concepts", style: GoogleFonts.inter(fontSize: 14, color: text.withOpacity(0.5))),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00C9A7), Color(0xFF00D9B5)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: const Color(0xFF00C9A7).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text("Download PDF", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfViewer(bool isDark, Color text, bool isDesktop) {
    return Column(
      children: [
        SizedBox(
          height: isDesktop ? 500 : 400,
          child: PageView.builder(
            controller: _pdfController,
            onPageChanged: (index) => setState(() => _currentPdfPage = index),
            itemCount: _totalPdfPages,
            itemBuilder: (context, index) => _buildPdfPage(isDark, text, index),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _currentPdfPage > 0 ? () => _pdfController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2332) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF2A3A4A) : Colors.grey.withOpacity(0.2)),
                ),
                child: Icon(Icons.chevron_left_rounded, color: _currentPdfPage > 0 ? text : text.withOpacity(0.3), size: 22),
              ),
            ),
            const SizedBox(width: 16),
            ...List.generate(_totalPdfPages, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPdfPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPdfPage == index ? const Color(0xFF1E88E5) : (isDark ? const Color(0xFF2A3A4A) : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
            )),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _currentPdfPage < _totalPdfPages - 1 ? () => _pdfController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2332) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF2A3A4A) : Colors.grey.withOpacity(0.2)),
                ),
                child: Icon(Icons.chevron_right_rounded, color: _currentPdfPage < _totalPdfPages - 1 ? text : text.withOpacity(0.3), size: 22),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("${_currentPdfPage + 1} / $_totalPdfPages", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPdfPage(bool isDark, Color text, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.1), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3)),
                ),
                child: Text("TIL-I MATH FORMULAS", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E88E5))),
              ),
              const SizedBox(height: 20),
              Text(pdfPageContents[index], style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: text)),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2332).withOpacity(0.5) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text("PDF Content Area\n\nActual PDF pages will be\ndisplayed here", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: text.withOpacity(0.4))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
