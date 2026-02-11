import 'package:flutter/material.dart';
import 'dart:ui';
import 'TILIDashboard.dart'; // For BentoColors
import 'TILSubjectTestViewPage.dart';
import '../widgets/theme_toggle.dart';

class TILSubjectTestsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const TILSubjectTestsPage({super.key, required this.toggleTheme});

  @override
  State<TILSubjectTestsPage> createState() => _TILSubjectTestsPageState();
}

class _TILSubjectTestsPageState extends State<TILSubjectTestsPage> {
  int? _hoveredIndex;

  // Reordered: Math, Reading, Physics, Technical
  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Mathematics',
      'type': 'Mathematics',
      'icon': Icons.calculate_rounded,
      'color': const Color(0xFF00BFA5),
      'desc': 'Advanced Algebra, Geometry & Calculus modules.',
      'testCount': 32,
      'progress': 0.4,
    },
    {
      'name': 'Reading',
      'type': 'Reading Comprehension',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFFD79A8),
      'desc': 'Complex Text Analysis & Logical Deductions.',
      'testCount': 20,
      'progress': 0.7,
    },
    {
      'name': 'Physics',
      'type': 'Physics',
      'icon': Icons.architecture_rounded,
      'color': const Color(0xFF6C5CE7),
      'desc': 'Kinematics, Force & Energy systems.',
      'testCount': 24,
      'progress': 0.9,
    },
    {
      'name': 'Technical Knowledge',
      'type': 'Technical Knowledge',
      'icon': Icons.precision_manufacturing_rounded,
      'color': const Color(0xFFFF7675),
      'desc': 'Engineering logic & spatial reasoning.',
      'testCount': 18,
      'progress': 0.2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF9FAFB);
    final text = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Subtle Glows
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: _buildBlurCircle(const Color(0xFF00BFA5).withOpacity(0.05), 500),
            ),
          ],

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(isDark, text)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width < 768 ? 16 : 24, 
                    0, 
                    MediaQuery.of(context).size.width < 768 ? 16 : 24, 
                    100
                  ),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 600,
                      mainAxisExtent: 280,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildPremiumSubjectCard(
                          context, subjects[index], isDark, index);
                      },
                      childCount: subjects.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active, bool isDark) {
    final color = active 
        ? const Color(0xFF38BDF8) 
        : (isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color text) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 16, isMobile ? 16 : 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildModernBackButton(isDark),
              Row(
                children: [
                   if (!isMobile) ...[
                    _buildStatusBadge(isDark),
                    const SizedBox(width: 12),
                   ],
                  SunMoonToggle(
                    isDark: isDark,
                    onToggle: widget.toggleTheme,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            "Subject Tests",
            style: TextStyle(
              fontSize: isMobile ? 32 : 42,
              fontWeight: FontWeight.w900,
              color: text,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "SELECT YOUR SPECIALIZATION",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: text.withOpacity(0.4),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBackButton(bool isDark) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 12),
          SizedBox(width: 6),
          Text(
            "ALL PATHS UNLOCKED",
            style: TextStyle(
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSubjectCard(
      BuildContext context, Map<String, dynamic> subject, bool isDark, int index) {
    final isHovered = _hoveredIndex == index;
    final Color accentColor = subject['color'];
    final text = isDark ? Colors.white : const Color(0xFF1E293B);
    final cardBg = isDark ? const Color(0xFF121826) : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TILSubjectTestViewPage(
                title: subject['name'],
                subjectType: subject['type'],
                accentColor: subject['color'],
                icon: subject['icon'],
                toggleTheme: widget.toggleTheme,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHovered
                  ? accentColor.withOpacity(0.4)
                  : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(subject['icon'], color: accentColor, size: 24),
                    ),
                    _buildStartPill(isDark),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  subject['name'],
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: text,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                _buildProgressBar(subject['progress'], accentColor, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartPill(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "START ",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white70 : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 14,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, spreadRadius: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreSubjectsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          width: 2,
          style: BorderStyle.none, // Need CustomPaint for dashed border if strictly needed
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: isDark ? Colors.white38 : Colors.black38,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "More Subjects",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Expanding our curriculum",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(24)));

    final dashWidth = 8.0;
    final dashSpace = 8.0;
    
    // Simple dashed path implementation
    double distance = 0;
    for (PathMetric measure in path.computeMetrics()) {
      while (distance < measure.length) {
        canvas.drawPath(
          measure.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
