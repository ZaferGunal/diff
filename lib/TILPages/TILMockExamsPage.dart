import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'TILIDashboard.dart'; // For BentoColors
import '../widgets/theme_toggle.dart';
import '../services/authservice.dart';
import '../UserProvider.dart';
import 'TILPracticeExamTestingPage.dart';
import 'TILPastResultsPage.dart';
import '../widgets/tili_sidebar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'TILMembershipPage.dart';

class TILMockExamsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const TILMockExamsPage({super.key, required this.toggleTheme});

  @override
  State<TILMockExamsPage> createState() => _TILMockExamsPageState();
}

class _TILMockExamsPageState extends State<TILMockExamsPage> {
  bool isLoading = true;
  List<dynamic> exams = [];
  String? errorMessage;
  Set<int> completedExamIndices = {};

  @override
  void initState() {
    super.initState();
    _fetchExams();
    _fetchCompletedExams();
  }

  Future<void> _fetchExams() async { // Renamed from _loadExams
    setState(() => isLoading = true);
    try {
      final response = await AuthService().getAllTILPracticeExams();
      if (response != null && response.data['success'] == true) {
        List<dynamic> fetchedExams = response.data['exams'] ?? [];
        
        // Ensure exactly 5 exams are displayed
        List<dynamic> reconciledExams = [];
        for (int i = 1; i <= 5; i++) {
          final existing = fetchedExams.firstWhere((e) => (e['index'] == i || e['title'].toString().contains(i.toString())), orElse: () => null);
          if (existing != null) {
            reconciledExams.add(existing);
          } else {
            reconciledExams.add({
              'index': i,
              'title': 'Practice Exam $i',
              'questions': [],
              'isPlaceholder': true,
            });
          }
        }
        
        setState(() {
          exams = reconciledExams;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response?.data['msg'] ?? "Failed to load exams";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCompletedExams() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) return;

      final response = await AuthService().getCompletedTILPracticeExamIndices(token);
      if (response?.data['success'] == true) {
        List<dynamic> indices = response.data['completedIndices'] ?? [];
        setState(() {
          completedExamIndices = indices.map((e) => e as int).toSet();
        });
      }
    } catch (e) {
      print('Error fetching completed exams: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final surface = isDark ? BentoColors.darkSurface : Colors.white;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    final secondaryText = isDark ? BentoColors.darkTextSecondary : BentoColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Row(
        children: [
          // Sidebar Navigation
          if (MediaQuery.of(context).size.width > 800)
            TILISidebar(activeItem: "Practice Exams", toggleTheme: widget.toggleTheme),

          // Main Content
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: -150, right: -150,
                  child: _buildBlurCircle(isDark, Colors.teal.withOpacity(0.05), 500),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width < 768 ? 20 : 40, 
                      vertical: MediaQuery.of(context).size.width < 768 ? 20 : 32
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            if (MediaQuery.of(context).size.width <= 800)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Practice Exams",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width < 768 ? 24 : 32, 
                                      fontWeight: FontWeight.w900, 
                                      color: text, 
                                      letterSpacing: -1
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width < 768 
                                        ? double.infinity 
                                        : MediaQuery.of(context).size.width * 0.6,
                                    child: Text(
                                      "Ready to test your knowledge? Each practice exam is crafted to official patterns.",
                                      style: TextStyle(fontSize: 14, color: secondaryText, height: 1.5, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (MediaQuery.of(context).size.width >= 768)
                                    Row(
                                      children: [
                                        Text("HOME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.teal, letterSpacing: 1)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Text("/", style: TextStyle(fontSize: 11, color: secondaryText)),
                                        ),
                                        Text("LIBRARY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: secondaryText, letterSpacing: 1)),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (MediaQuery.of(context).size.width >= 768) ...[
                              const Spacer(),
                              SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
                            ] else 
                              SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width < 768 ? 24 : 48),
                        
                        // Grid of Exams
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                              : errorMessage != null
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 60, color: Colors.red.withOpacity(0.3)),
                                const SizedBox(height: 20),
                                Text(errorMessage!, style: TextStyle(color: text.withOpacity(0.4))),
                              ],
                            ),
                          )
                              : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : (MediaQuery.of(context).size.width > 900 ? 2 : 1),
                              crossAxisSpacing: 32,
                              mainAxisSpacing: 32,
                              childAspectRatio: 1.35, // Shorter cards since desc is gone
                            ),
                            itemCount: exams.length,
                            itemBuilder: (context, index) {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              final bool hasPackage = authProvider.hasTiliPackage;
                              final bool isLocked = !hasPackage && index > 0;
                              
                              final exam = exams[index];
                              final examIndex = exam['index'] ?? (index + 1);
                              final isCompleted = completedExamIndices.contains(examIndex);
                              return _buildExamCard(isDark, exam, text, secondaryText, isCompleted, isLocked);
                            },
                          ),
                        ),
                      ],
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

  Widget _buildExamCard(bool isDark, dynamic exam, Color text, Color secondaryText, bool isCompleted, bool isLocked) {
    final indexStr = (exam['index'] ?? 0).toString().padLeft(2, '0');
    final title = exam['title']?.toString().replaceAll("Mock", "Practice") ?? "Practice Exam";
    final isPlaceholder = exam['isPlaceholder'] == true;

    // Determine colors for numbers and button text based on theme
    final numberColor = isDark ? text.withOpacity(0.03) : Colors.black.withOpacity(0.08);
    final buttonTextColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? BentoColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: text.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Large Index Background
          Positioned(
            top: 24,
            right: 24,
            child: Text(
              indexStr,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: numberColor,
              ),
            ),
          ),
          
          if (isLocked)
            Positioned(
              top: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text("UPGRADE", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 20.0 : 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container with optional completion checkmark
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock_outline_rounded : Icons.assignment_outlined, 
                        color: isLocked ? Colors.grey : Colors.teal, 
                        size: 22
                      ),
                    ),
                    // Green checkmark for completed exams
                    if (isCompleted && !isLocked)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? BentoColors.darkSurface : Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19, 
                    fontWeight: FontWeight.w800, 
                    color: isLocked ? text.withOpacity(0.4) : text, 
                    height: 1.2
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Metadata
                Row(
                  children: [
                    _buildMetaItem(Icons.layers_outlined, "42 QS", isLocked ? secondaryText.withOpacity(0.3) : secondaryText),
                    const SizedBox(width: 20),
                    _buildMetaItem(Icons.schedule_rounded, "90 MIN", isLocked ? secondaryText.withOpacity(0.3) : secondaryText),
                  ],
                ),
                const SizedBox(height: 24),
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (isPlaceholder || (isLocked)) 
                      ? (isLocked ? () {
                          _showUpgradeDialog();
                        } : null) 
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TILPracticeExamTestingPage(
                              toggleTheme: widget.toggleTheme,
                              examIndex: exam['index'],
                              title: title,
                              accentColor: Colors.teal,
                            ),
                          ),
                        );
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLocked 
                        ? Colors.amber.shade700 
                        : (isPlaceholder ? Colors.teal.withOpacity(0.2) : Colors.teal),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLocked ? "UPGRADE TO UNLOCK" : "Start Exam", 
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)
                        ),
                        const SizedBox(width: 8),
                        Icon(isLocked ? Icons.workspace_premium_rounded : Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      ],
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

  void _showUpgradeDialog() {
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                "Upgrade Required",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Upgrade your account to unlock all practice exams and assessment materials.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TILMembershipPage(toggleTheme: widget.toggleTheme),
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
                child: const Text("SEE UPGRADE PLANS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Maybe Later", style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.4)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildBlurCircle(bool isDark, Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
