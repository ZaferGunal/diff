import 'package:flutter/material.dart';
import 'dart:ui';
import 'TILIDashboard.dart';
import '../widgets/theme_toggle.dart';
import 'package:provider/provider.dart';
import '../UserProvider.dart';
import 'TILMembershipPage.dart';
import 'FlashcardStudyPage.dart';
import 'package:google_fonts/google_fonts.dart';

class TILCardsPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const TILCardsPage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool hasPackage = authProvider.hasTiliPackage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.04), shape: BoxShape.circle),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: text.withOpacity(0.05),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Flashcards",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      SunMoonToggle(isDark: isDark, onToggle: toggleTheme),
                    ],
                  ),
                ),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 1;
                      double childAspectRatio = 3.5;
                      
                      if (constraints.maxWidth >= 1100) {
                        crossAxisCount = 3;
                        childAspectRatio = 1.3;
                      } else if (constraints.maxWidth >= 768) {
                        crossAxisCount = 2;
                        childAspectRatio = 1.6;
                      } else {
                        crossAxisCount = 1;
                        childAspectRatio = 3.2;
                      }

                      return GridView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: childAspectRatio,
                        ),
                        children: [
                          _buildSubjectItem(context, "Reading", "Learn essential vocabulary", Icons.menu_book_rounded, Colors.green, isDark, true, crossAxisCount > 1),
                          _buildSubjectItem(context, "Physics", "Master scientific concepts", Icons.bolt_rounded, Colors.orange, isDark, hasPackage, crossAxisCount > 1),
                          _buildSubjectItem(context, "Technical Knowledge", "Deep dive into tech details", Icons.memory_rounded, Colors.purple, isDark, hasPackage, crossAxisCount > 1),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(BuildContext context, String title, String subtitle, IconData icon, Color color, bool isDark, bool isActive, bool isGrid) {
    final text = isDark ? Colors.white : Colors.black;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isActive) {
            _showUpgradeDialog(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardStudyPage(subject: title, toggleTheme: toggleTheme),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: color.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: isGrid 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (isActive ? color : Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: isActive ? color : Colors.grey, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isActive ? text : text.withOpacity(0.4),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: text.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isActive ? color : Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: isActive ? color : Colors.grey, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isActive ? text : text.withOpacity(0.4),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: text.withOpacity(0.4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isActive)
                    Icon(Icons.lock_rounded, color: text.withOpacity(0.2), size: 18)
                  else
                    Icon(Icons.arrow_forward_ios_rounded, color: text.withOpacity(0.1), size: 16),
                ],
              ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                "Premium Required",
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                "Full access to specialized subjects and mixed study is a premium feature.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TILMembershipPage(toggleTheme: toggleTheme),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text("SEE UPGRADE PLANS", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
