import 'package:flutter/material.dart';
import 'dart:ui';
import 'TILIDashboard.dart';
import '../widgets/theme_toggle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TILArchivePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const TILArchivePage({super.key, required this.toggleTheme});

  @override
  State<TILArchivePage> createState() => _TILArchivePageState();
}

class _TILArchivePageState extends State<TILArchivePage> {
  String _selectedFilter = 'All Files';
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> allPdfs = [
    // Math
    {'title': 'Algebra Fundamentals', 'subject': 'Mathematics', 'size': '2.4 MB', 'views': '2.4k', 'color': Colors.blue, 'url': 'https://example.com/1.pdf'},
    {'title': 'Geometry Guide', 'subject': 'Mathematics', 'size': '3.1 MB', 'views': '1.8k', 'color': Colors.blue, 'url': 'https://example.com/2.pdf'},
    {'title': 'Calculus Essentials', 'subject': 'Mathematics', 'size': '4.2 MB', 'views': '3.2k', 'color': Colors.blue, 'url': 'https://example.com/3.pdf'},
    // Physics
    {'title': 'Mechanics Fundamentals', 'subject': 'Physics', 'size': '2.8 MB', 'views': '1.5k', 'color': Colors.purple, 'url': 'https://example.com/4.pdf'},
    {'title': 'Quantum Field Theory', 'subject': 'Physics', 'size': '5.1 MB', 'views': '4.7k', 'color': Colors.purple, 'url': 'https://example.com/5.pdf'},
    {'title': 'Wave Function Sheet', 'subject': 'Physics', 'size': '1.8 MB', 'views': '2.1k', 'color': Colors.purple, 'url': 'https://example.com/6.pdf'},
    // Technical
    {'title': 'Circuit Analysis', 'subject': 'Technical', 'size': '2.8 MB', 'views': '890', 'color': Colors.orange, 'url': 'https://example.com/7.pdf'},
    {'title': 'Digital Logic Design', 'subject': 'Technical', 'size': '2.4 MB', 'views': '1.5k', 'color': Colors.orange, 'url': 'https://example.com/8.pdf'},
    {'title': 'Materials Science', 'subject': 'Technical', 'size': '4.1 MB', 'views': '2.3k', 'color': Colors.orange, 'url': 'https://example.com/9.pdf'},
    // Reading
    {'title': 'Logical Reasoning Guide', 'subject': 'Reading', 'size': '1.2 MB', 'views': '3.8k', 'color': Colors.teal, 'url': 'https://example.com/10.pdf'},
  ];

  final List<String> filters = ['All Files', 'Mathematics', 'Physics', 'Technical', 'Reading'];

  List<Map<String, dynamic>> get filteredPdfs {
    if (_selectedFilter == 'All Files') return allPdfs;
    return allPdfs.where((pdf) => pdf['subject'] == _selectedFilter).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned(bottom: -120, right: -80, child: _buildGlowOrb(Colors.teal.withOpacity(0.15), 400)),
          Positioned(top: -80, left: -60, child: _buildGlowOrb(Colors.purple.withOpacity(0.12), 320)),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : (isTablet ? 32 : 20),
                vertical: isDesktop ? 32 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDark, text),
                  const SizedBox(height: 28),
                  _buildSearchBar(isDark, text),
                  const SizedBox(height: 24),
                  _buildTitleSection(text, isDesktop),
                  const SizedBox(height: 20),
                  _buildFilterTabs(isDark, text),
                  const SizedBox(height: 24),
                  _buildPdfGrid(isDark, text, isDesktop, isTablet),
                  const SizedBox(height: 24),
                  _buildFooter(text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color text) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: text.withOpacity(0.1)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        // Vault Logo
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.teal.withOpacity(0.2), Colors.cyan.withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: const Icon(Icons.folder_special_rounded, color: Colors.teal, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vault.OS", style: GoogleFonts.jost(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
            Text("TECHNICAL RESOURCE LIBRARY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: text.withOpacity(0.4), letterSpacing: 1)),
          ],
        ),
        const Spacer(),
        SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: text.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: text.withOpacity(0.4), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: text, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search blueprints, formulas, and technical guides...",
                hintStyle: TextStyle(color: text.withOpacity(0.4), fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("CMD+K", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: text.withOpacity(0.5))),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(Color text, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Master Archive",
          style: GoogleFonts.jost(fontSize: isDesktop ? 36 : 28, fontWeight: FontWeight.bold, color: text),
        ),
        const SizedBox(height: 6),
        Text(
          "Access verified mathematical proofs and engineering schematics.",
          style: TextStyle(fontSize: 14, color: text.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(bool isDark, Color text) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isActive = _selectedFilter == filter;
          Color filterColor = Colors.teal;
          if (filter == 'Mathematics') filterColor = Colors.blue;
          if (filter == 'Physics') filterColor = Colors.purple;
          if (filter == 'Technical') filterColor = Colors.orange;
          if (filter == 'Reading') filterColor = Colors.teal;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? filterColor : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isActive ? filterColor : text.withOpacity(0.08)),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? Colors.white : text.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPdfGrid(bool isDark, Color text, bool isDesktop, bool isTablet) {
    int crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredPdfs.length,
      itemBuilder: (context, index) => _buildArchiveCard(isDark, text, filteredPdfs[index]),
    );
  }

  Widget _buildArchiveCard(bool isDark, Color text, Map<String, dynamic> pdf) {
    final color = pdf['color'] as Color;
    return GestureDetector(
      onTap: () => _showPdfOptions(context, pdf, isDark, text),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.description_rounded, color: color.withOpacity(0.4), size: 48),
                    ),
                    // Subject Badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pdf['subject'].toString().toUpperCase(),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdf['title'],
                      style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.bold, color: text),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.insert_drive_file_rounded, size: 12, color: text.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text("PDF • ${pdf['size']}", style: TextStyle(fontSize: 10, color: text.withOpacity(0.5))),
                        const Spacer(),
                        Icon(Icons.visibility_rounded, size: 12, color: color),
                        const SizedBox(width: 4),
                        Text(pdf['views'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfOptions(BuildContext context, Map<String, dynamic> pdf, bool isDark, Color text) {
    final color = pdf['color'] as Color;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? BentoColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: text.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.picture_as_pdf_rounded, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(pdf['title'], style: GoogleFonts.jost(fontSize: 18, fontWeight: FontWeight.bold, color: text), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text("${pdf['subject']} • ${pdf['size']}", style: TextStyle(fontSize: 13, color: text.withOpacity(0.5))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _openUrl(pdf['url']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          Icon(Icons.visibility_rounded, color: color, size: 26),
                          const SizedBox(height: 8),
                          Text("View PDF", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _openUrl(pdf['url']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.download_rounded, color: Colors.white, size: 26),
                          SizedBox(height: 8),
                          Text("Download", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(Color text) {
    return Row(
      children: [
        Icon(Icons.cloud_done_rounded, size: 16, color: Colors.teal),
        const SizedBox(width: 8),
        Text("${filteredPdfs.length} Resources Online", style: TextStyle(fontSize: 12, color: text.withOpacity(0.5))),
        const Spacer(),
        Text("VAULT_AUTH_v2.04.1", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.teal.withOpacity(0.6), letterSpacing: 0.5)),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
