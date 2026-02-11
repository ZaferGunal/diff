import 'package:flutter/material.dart';
import '../TILPages/TILIDashboard.dart'; // For BentoColors
import '../TILPages/TILMockExamsPage.dart';
import '../TILPages/TILPastResultsPage.dart';
import '../TILPages/TILLearnPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../UserProvider.dart';
import '../TILPages/TILMembershipPage.dart';
class TILISeamlessRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  TILISeamlessRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
}

class TILISidebar extends StatelessWidget {
  final String activeItem;
  final VoidCallback toggleTheme;

  const TILISidebar({
    super.key,
    required this.activeItem,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    final authProvider = context.watch<AuthProvider>();
    final tier = authProvider.tiliPackageTier?.toUpperCase() ?? "FREE PLAN";

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? BentoColors.darkSurface.withOpacity(0.5) : Colors.white,
        border: Border(right: BorderSide(color: text.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal,
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/soleLogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "PractiCo",
                  style: GoogleFonts.jost(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
const SizedBox(height: 16),
          _buildSidebarItem(context, "Dashboard", Icons.dashboard_outlined, activeItem == "Dashboard", text),
          _buildSidebarItem(context, "Learn", Icons.school_rounded, activeItem == "Learn", text),
          _buildSidebarItem(context, "Practice Exams", Icons.assignment_outlined, activeItem == "Practice Exams", text),
          _buildSidebarItem(context, "Past Results", Icons.history_rounded, activeItem == "Past Results", text),
          const Spacer(),
          // Membership Card
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TILMembershipPage(toggleTheme: toggleTheme))),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.teal, size: 20),
                    const SizedBox(height: 12),
                    Text(tier, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: text.withOpacity(0.5), letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.hasTiliPackage ? "View your benefits" : "Unlock all assessments", 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: text),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, String label, IconData icon, bool isActive, Color text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.teal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          onTap: () {
            if (isActive) return;
            if (label == "Dashboard") {
              Navigator.of(context).pop();
            } else if (label == "Learn") {
              Navigator.pushReplacement(
                context,
                TILISeamlessRoute(page: TILLearnPage(toggleTheme: toggleTheme)),
              );
            } else if (label == "Practice Exams") {
              Navigator.pushReplacement(
                context,
                TILISeamlessRoute(page: TILMockExamsPage(toggleTheme: toggleTheme)),
              );
            } else if (label == "Past Results") {
              Navigator.pushReplacement(
                context,
                TILISeamlessRoute(page: TILPastResultsPage(toggleTheme: toggleTheme)),
              );
            }
          },
          leading: Icon(icon, color: isActive ? Colors.teal : text.withOpacity(0.4), size: 22),
          title: Text(
            label,
            style: TextStyle(
              color: isActive ? text : text.withOpacity(0.5),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          trailing: isActive ? Container(width: 4, height: 20, decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(2))) : null,
        ),
      ),
    );
  }
}
