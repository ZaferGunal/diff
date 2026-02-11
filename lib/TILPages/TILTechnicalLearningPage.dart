import 'package:flutter/material.dart';
import 'TILIDashboard.dart';
import '../widgets/theme_toggle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/video_player_screen.dart';
import '../BocconiPages/home_page.dart';


class TILTechnicalLearningPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const TILTechnicalLearningPage({super.key, required this.toggleTheme});

  @override
  State<TILTechnicalLearningPage> createState() => _TILTechnicalLearningPageState();
}

class _TILTechnicalLearningPageState extends State<TILTechnicalLearningPage> {
  final PageController _pdfController = PageController();
  int _currentPdfPage = 0;
  final int _totalPdfPages = 3;
  int _activeTab = 0; // 0 for Study Guide (PDF), 1 for Video Lectures

  static const List<String> pdfPageContents = [
    'Page 1: Engineering Systems & Basics',
    'Page 2: Circuitry & Electronics',
    'Page 3: Material Science & Mechanics',
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: 20,
              ),
              child: _buildHeader(context, isDark, text),
            ),
            _buildTabSelector(isDark, text, isDesktop),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (_activeTab == 0) ...[
                      _buildTitleWithDownload(isDark, text),
                      const SizedBox(height: 24),
                      _buildPdfViewer(isDark, text, isDesktop),
                    ] else ...[
                      _buildVideoSection(isDark, text),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark, Color text, bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2332) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A3A4A) : Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildTabItem(0, "Study Guide", Icons.description_rounded, isDark, text),
          _buildTabItem(1, "Video Lectures", Icons.play_lesson_rounded, isDark, text),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon, bool isDark, Color text) {
    bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive 
                ? (isDark ? const Color(0xFF7B9FFF) : const Color(0xFF7B9FFF))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                color: isActive ? Colors.white : text.withOpacity(0.5), 
                size: 18
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.white : text.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection(bool isDark, Color text) {
    // Technical Knowledge videos
    final videosList = [
      {
        'title': 'Basic Technical Knowledge',
        'url': 'https://practico.b-cdn.net/Basic%20Technical%20Knowledge.mp4',
      },
      {
        'title': 'Binary System',
        'url': 'https://practico.b-cdn.net/Binary%20System.mp4',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Video Lectures",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: text,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Engineering fundamentals and sysadmin basics",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: text.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
              ),
              child: Text(
                "${videosList.length} LESSONS",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7B9FFF).withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.5,
          ),
          itemCount: videosList.length,
          itemBuilder: (context, index) {
            final v = videosList[index];
            return _buildVideoCard(
              isDark, 
              v['title'] as String, 
              text,
              v['url'] as String,
              index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildVideoCard(bool isDark, String title, Color text, String url, int index) {
    // Mock progress and duration
    double progress = (index == 0) ? 0.35 : 0.0;
    String duration = (index == 0) ? "15:40" : "22:10";
    bool isCompleted = progress >= 1.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A26) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
          width: 2,
        ),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(videoUrl: url, title: title),
                    ),
                  ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.2)],
                    ),
                  ),
                  child: Opacity(
                    opacity: 0.3,
                    child: Icon(Icons.memory_rounded, size: 100, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(6)),
                  child: Text(duration, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              Center(
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                ),
              ),
              Positioned(
                left: 16, right: 16, bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
                      child: Row(
                        children: [
                          Expanded(flex: (progress * 100).toInt(), child: Container(decoration: BoxDecoration(color: const Color(0xFF7B9FFF), borderRadius: BorderRadius.circular(2)))),
                          Expanded(flex: ((1 - progress) * 100).toInt(), child: const SizedBox.shrink()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("BASIC LEVEL", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5))),
                        Text("${(progress * 100).toInt()}%", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch video')),
        );
      }
    }
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
            gradient: const LinearGradient(colors: [Color(0xFF7B9FFF), Color(0xFF9BB5FF)]),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.memory_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text("TECHNICAL", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
            ],
          ),
        ),
        const Spacer(),
        SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
      ],
    );
  }

  Widget _buildTitleWithDownload(bool isDark, Color text) {
    if (_activeTab == 1) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Study Guide", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 4),
              Text("Engineering fundamentals", style: GoogleFonts.inter(fontSize: 14, color: text.withOpacity(0.5))),
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
                color: _currentPdfPage == index ? const Color(0xFF7B9FFF) : (isDark ? const Color(0xFF2A3A4A) : Colors.grey.shade300),
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
                color: const Color(0xFF7B9FFF),
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
        border: Border.all(color: const Color(0xFF7B9FFF).withOpacity(0.3), width: 2),
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
                  color: const Color(0xFF7B9FFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF7B9FFF).withOpacity(0.3)),
                ),
                child: Text("TIL-I TECHNICAL GUIDE", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF7B9FFF))),
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
