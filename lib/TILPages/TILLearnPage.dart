import 'package:flutter/material.dart';
import 'TILIDashboard.dart';
import 'TILMathLearningPage.dart';
import 'TILPhysicsLearningPage.dart';
import 'TILTechnicalLearningPage.dart';
import '../widgets/theme_toggle.dart';
import 'package:google_fonts/google_fonts.dart';

class TILLearnPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const TILLearnPage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1622) : const Color(0xFFF5F7FA);
    final text = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 60 : (isTablet ? 32 : 20),
            vertical: isDesktop ? 32 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Back Button + Theme Toggle only
              _buildHeader(context, isDark, text),
              SizedBox(height: isDesktop ? 40 : 28),
              
              // Title Section
              _buildTitleSection(text, isDesktop),
              SizedBox(height: isDesktop ? 36 : 24),
              
              // Subject Cards Grid - 3 subjects only
              _buildSubjectGrid(context, isDark, text, isDesktop, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color text) {
    return Row(
      children: [
        // Back Button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2332) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3A4A) : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 18),
          ),
        ),
        const Spacer(),
        // Theme Toggle
        SunMoonToggle(isDark: isDark, onToggle: toggleTheme),
      ],
    );
  }

  Widget _buildTitleSection(Color text, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subject Selection Hub",
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your STEM progression roadmap. Choose your next deep-dive.",
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 16 : 14,
            color: text.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectGrid(BuildContext context, bool isDark, Color text, bool isDesktop, bool isTablet) {
    final subjects = [
      {
        'title': 'Mathematics',
        'description': 'Advanced Calculus, Linear\nAlgebra & Number Theory',
        'icon': Icons.functions_rounded,
        'gradient': [const Color(0xFF1E3A5F), const Color(0xFF2A4A6F)],
        'accentColor': const Color(0xFF00D9FF),
        'page': TILMathLearningPage(toggleTheme: toggleTheme),
      },
      {
        'title': 'Physics',
        'description': 'Classical Mechanics, Quantum\nTheory & Thermodynamics',
        'icon': Icons.blur_circular_rounded,
        'gradient': [const Color(0xFF2D1B4E), const Color(0xFF3D2B5E)],
        'accentColor': const Color(0xFFAA7BFF),
        'page': TILPhysicsLearningPage(toggleTheme: toggleTheme),
      },
      {
        'title': 'Technical Knowledge',
        'description': 'Engineering Systems, Circuitry\n& Material Science',
        'icon': Icons.memory_rounded,
        'gradient': [const Color(0xFF1A2744), const Color(0xFF253454)],
        'accentColor': const Color(0xFF7B9FFF),
        'page': TILTechnicalLearningPage(toggleTheme: toggleTheme),
      },
    ];

    // For desktop: first row 2 cards, second row 1 card centered
    // For tablet/mobile: single column
    if (isDesktop) {
      return Column(
        children: [
          // First row - 2 cards
          Row(
            children: [
              Expanded(child: _buildSubjectCard(context, isDark, subjects[0])),
              const SizedBox(width: 20),
              Expanded(child: _buildSubjectCard(context, isDark, subjects[1])),
            ],
          ),
          const SizedBox(height: 20),
          // Second row - 1 card (half width, left aligned)
          Row(
            children: [
              Expanded(child: _buildSubjectCard(context, isDark, subjects[2])),
              const SizedBox(width: 20),
              Expanded(child: Container()), // Empty space
            ],
          ),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSubjectCard(context, isDark, subjects[0])),
              const SizedBox(width: 16),
              Expanded(child: _buildSubjectCard(context, isDark, subjects[1])),
            ],
          ),
          const SizedBox(height: 16),
          _buildSubjectCard(context, isDark, subjects[2]),
        ],
      );
    } else {
      return Column(
        children: subjects.map((subject) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSubjectCard(context, isDark, subject),
          );
        }).toList(),
      );
    }
  }

  Widget _buildSubjectCard(BuildContext context, bool isDark, Map<String, dynamic> subject) {
    final gradient = subject['gradient'] as List<Color>;
    final accentColor = subject['accentColor'] as Color;
    
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => subject['page'] as Widget)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? gradient : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? accentColor.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subject['title'],
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subject['description'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Right Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                subject['icon'] as IconData,
                color: accentColor,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
