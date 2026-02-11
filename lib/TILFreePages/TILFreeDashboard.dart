import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../TILPages/TILIDashboard.dart';
import '../TILPages/TILIntroPage.dart';
import '../TILPages/TILMockExamsPage.dart';
import '../TILPages/TILSubjectTestsPage.dart';
import '../TILPages/TILLearnPage.dart';
import '../TILPages/TILCardsPage.dart';
import '../TILPages/TILPastResultsPage.dart';

class TILFreeDashboard extends StatefulWidget {
  final VoidCallback toggleTheme;
  const TILFreeDashboard({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<TILFreeDashboard> createState() => _TILFreeDashboardState();
}

class _TILFreeDashboardState extends State<TILFreeDashboard> {
  bool _isSidebarHovered = false;
  
  bool get isDesktop => MediaQuery.of(context).size.width >= 1100;
  bool get isMobile => MediaQuery.of(context).size.width < 768;
  int? _hoveredIndex;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.timer_outlined, 'label': 'Practice Exams'},
    {'icon': Icons.description_outlined, 'label': 'Subject Tests'},
    {'icon': Icons.play_lesson_outlined, 'label': 'Learn'},
    {'icon': Icons.style_outlined, 'label': 'Cards'},
    {'icon': Icons.history_rounded, 'label': 'Past Results'},
  ];

  void _handleNavigation(int index) {
    if (index >= _navItems.length) return;
    
    final label = _navItems[index]['label'];
    Widget? page;

    switch (label) {
      case 'Practice Exams':
        page = TILMockExamsPage(toggleTheme: widget.toggleTheme);
        break;
      case 'Subject Tests':
        page = TILSubjectTestsPage(toggleTheme: widget.toggleTheme);
        break;
      case 'Learn':
        page = TILLearnPage(toggleTheme: widget.toggleTheme);
        break;
      case 'Cards':
        page = TILCardsPage(toggleTheme: widget.toggleTheme);
        break;
      case 'Past Results':
        page = TILPastResultsPage(toggleTheme: widget.toggleTheme);
        break;
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page!));
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B6B).withOpacity(0.2),
                      const Color(0xFFFF8E53).withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFFFF8E53),
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Upgrade Required',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'To access this feature and unlock full potential, please upgrade your membership.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Upgrade Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TILIIntroPage(
                        toggleTheme: widget.toggleTheme,
                        token: '',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'UPGRADE NOW',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final surfaceColor = isDark ? BentoColors.darkSurface : BentoColors.lightSurface;
    final textPrimary = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    final textSecondary = isDark ? BentoColors.darkTextSecondary : BentoColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient Background
          Positioned(
            top: -150, right: -100,
            child: _buildBlurCircle(Colors.deepPurple.withOpacity(isDark ? 0.15 : 0.05), 500),
          ),
          Positioned(
            bottom: -100, left: -50,
            child: _buildBlurCircle(Colors.tealAccent.withOpacity(isDark ? 0.1 : 0.05), 600),
          ),
          Positioned(
            top: 200, left: -150,
            child: _buildBlurCircle(Colors.blueAccent.withOpacity(isDark ? 0.08 : 0.04), 400),
          ),

          Row(
            children: [
              // Sidebar (desktop only)
              if (isDesktop)
                MouseRegion(
                  onEnter: (_) => setState(() => _isSidebarHovered = true),
                  onExit: (_) => setState(() => _isSidebarHovered = false),
                  child: _buildSidebar(isDark, surfaceColor, textPrimary, textSecondary),
                ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 16),
                  child: Column(
                    children: [
                      _buildHeader(isMobile, isDark, textPrimary, textSecondary),
                      const SizedBox(height: 32),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: _buildMainContent(isDesktop, isMobile, isDark, surfaceColor, textPrimary, textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildSidebar(bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isSidebarHovered ? 200 : 80,
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(isDark ? 0.9 : 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.05 : 0.02),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Brand
            SizedBox(
              width: 56, height: 56,
              child: Image.asset('assets/soleLogo.png', fit: BoxFit.contain),
            ),
            if (_isSidebarHovered) ...[
              const SizedBox(height: 12),
              Text(
                "PractiCo",
                style: GoogleFonts.jost(
                  color: textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
            const Spacer(),
            // Nav Items (all locked)
            ...List.generate(_navItems.length, (index) => _buildSidebarItem(index)),
            const Spacer(),
            // Back Button
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisAlignment: _isSidebarHovered
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        color: textSecondary, size: 20),
                    if (_isSidebarHovered) ...[
                      const SizedBox(width: 12),
                      Text("Go Back",
                          style: TextStyle(color: textSecondary)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    // Define a list of vibrant colors for navigation items
    final List<Color> itemColors = [
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
    ];
    final color = index < itemColors.length ? itemColors[index] : Colors.white;

    return InkWell(
      onTap: () => _handleNavigation(index),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: _isSidebarHovered ? 12 : 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment:
              _isSidebarHovered ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(_navItems[index]['icon'], color: color.withOpacity(0.9), size: 24),
            if (_isSidebarHovered) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _navItems[index]['label'],
                  style: GoogleFonts.inter(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withOpacity(0.9) 
                        : Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, bool isDark, Color textPrimary, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (MediaQuery.of(context).size.width <= 1000)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.maybePop(context),
                    color: textPrimary,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TIL-I Free Trial",
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Explore the platform — Full access with Upgrade.",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Theme Switch
        IconButton(
          onPressed: widget.toggleTheme,
          icon: Icon(
            isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: textSecondary,
          ),
          tooltip: 'Toggle Theme',
        ),
        const SizedBox(width: 8),
        // Upgrade Badge
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TILIIntroPage(
                  toggleTheme: widget.toggleTheme,
                  token: '',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'UPGRADE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isDesktop, bool isMobile, bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary) {
    return Column(
      children: [
        // Action Grid (locked)
        if (isDesktop)
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: _buildActionBento("Practice Exams", Icons.timer_outlined, Colors.green, 0, surfaceColor, textPrimary)),
                const SizedBox(width: 24),
                Expanded(child: _buildActionBento("Subject Tests", Icons.description_outlined, Colors.orange, 1, surfaceColor, textPrimary)),
                const SizedBox(width: 24),
                Expanded(child: _buildActionBento("Learn", Icons.play_lesson_outlined, Colors.blue, 2, surfaceColor, textPrimary)),
                const SizedBox(width: 24),
                Expanded(child: _buildActionBento("Cards", Icons.style_outlined, Colors.purple, 3, surfaceColor, textPrimary)),

              ],
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: MediaQuery.of(context).size.width < 380 ? 1.1 : 1.3,
            children: [
              _buildActionBento("Practice Exams", Icons.timer_outlined, Colors.green, 0, surfaceColor, textPrimary),
              _buildActionBento("Subject Tests", Icons.description_outlined, Colors.orange, 1, surfaceColor, textPrimary),
              _buildActionBento("Learn", Icons.play_lesson_outlined, Colors.blue, 2, surfaceColor, textPrimary),
              _buildActionBento("Cards", Icons.style_outlined, Colors.purple, 3, surfaceColor, textPrimary),
            ],
          ),

        const SizedBox(height: 32),

        // Weekly Activity Card (locked)
        _buildSection(
          title: "Weekly Activity",
          subtitle: "Track your weekly learning progress",
          icon: Icons.show_chart_rounded,
          height: 200,
          onTap: () {}, // No page for this yet
          surfaceColor: surfaceColor,
          textPrimary: textPrimary,
        ),

        const SizedBox(height: 32),

        // Past Results
        _buildSection(
          title: "Past Results",
          subtitle: "Review your previous exam scores",
          icon: Icons.history_rounded,
          height: 120,
          onTap: () => _handleNavigation(4),
          surfaceColor: surfaceColor,
          textPrimary: textPrimary,
        ),

      ],
    );
  }

  Widget _buildActionBento(String title, IconData icon, Color color, int index, Color surfaceColor, Color textPrimary) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GestureDetector(
      onTap: () => _handleNavigation(index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: isMobile ? 24 : 28),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required double height,
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.6)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
