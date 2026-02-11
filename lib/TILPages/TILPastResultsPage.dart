import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'TILIDashboard.dart'; // For BentoColors
import '../widgets/theme_toggle.dart';
import '../widgets/tili_sidebar.dart';
import '../services/authservice.dart';
import '../UserProvider.dart';
import 'TILPracticeExamResultPage.dart';

class TILPastResultsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const TILPastResultsPage({super.key, required this.toggleTheme});

  @override
  State<TILPastResultsPage> createState() => _TILPastResultsPageState();
}

class _TILPastResultsPageState extends State<TILPastResultsPage> {
  bool isLoading = true;
  List<dynamic> results = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() {
          errorMessage = "Please log in to view results";
          isLoading = false;
        });
        return;
      }

      final response = await AuthService().getTILPracticeExamResults(token, limit: 5);

      if (response?.data['success'] == true) {
        setState(() {
          results = response.data['results'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response?.data['msg'] ?? "Failed to load results";
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

  String _formatDate(String? isoDate) {
    if (isoDate == null) return "Unknown date";
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return "Today";
      } else if (diff.inDays == 1) {
        return "Yesterday";
      } else if (diff.inDays < 7) {
        return "${diff.inDays} days ago";
      } else if (diff.inDays < 30) {
        return "${(diff.inDays / 7).floor()} week${(diff.inDays / 7).floor() > 1 ? 's' : ''} ago";
      } else {
        return "${date.day}/${date.month}/${date.year}";
      }
    } catch (e) {
      return "Unknown date";
    }
  }

  Color _getColorForScore(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.teal;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    final secondaryText = isDark ? BentoColors.darkTextSecondary : BentoColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Row(
        children: [
          // Sidebar Navigation
          if (MediaQuery.of(context).size.width > 800)
            TILISidebar(activeItem: "Past Results", toggleTheme: widget.toggleTheme),

          // Main Content
          Expanded(
            child: Stack(
              children: [
                // Ambient Background
                Positioned(
                  top: -150, right: -150,
                  child: _buildBlurCircle(isDark, Colors.purple.withOpacity(0.05), 500),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Past Results",
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 768 ? 24 : 32, 
                                    fontWeight: FontWeight.w900, 
                                    color: text, 
                                    letterSpacing: -1
                                  ),
                                ),
                                const SizedBox(height: 6),
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
                            const Spacer(),
                            SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width < 768 ? 24 : 48),
                        
                        // Results List
                        Expanded(
                          child: _buildResultsContent(isDark, text, secondaryText),
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

  Widget _buildResultsContent(bool isDark, Color text, Color secondaryText) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text(errorMessage!, style: TextStyle(color: text.withOpacity(0.4))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchResults,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.teal.withOpacity(0.2)),
            const SizedBox(height: 24),
            Text(
              "No Results Yet",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: text),
            ),
            const SizedBox(height: 8),
            Text(
              "Complete a practice exam to see your results here.",
              style: TextStyle(fontSize: 16, color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final title = result['title'] ?? "Practice Exam ${result['examIndex'] ?? ''}";
        final score = (result['score'] ?? 0).toDouble();
        final correctCount = result['correctCount'] ?? 0;
        final wrongCount = result['wrongCount'] ?? 0;
        final emptyCount = result['emptyCount'] ?? 0;
        final totalQuestions = correctCount + wrongCount + emptyCount;
        final completedAt = result['completedAt']?.toString();
        final color = _getColorForScore(score);

        return _buildResultCard(
          context, 
          isDark, 
          title, 
          _formatDate(completedAt), 
          "$correctCount/$totalQuestions", 
          color, 
          score,
          result,
        );
      },
    );
  }

  Widget _buildResultCard(BuildContext context, bool isDark, String title, String date, String score, Color color, double percentage, dynamic resultData) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return GestureDetector(
      onTap: () async {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.teal)),
        );

        try {
          final examIndex = resultData['examIndex'];
          final response = await AuthService().getTILPracticeExam(examIndex);
          
          if (!context.mounted) return;
          Navigator.pop(context); // Remove loading indicator

          if (response?.data['success'] == true) {
            final exam = response!.data['exam'];
            final List<dynamic> rawQuestions = exam['questions'] ?? [];
            final List<Map<String, dynamic>> processedQuestions = [];
            
            // Reconstruct sections like in TestingPage
            final Map<String, List<int>> sectionQuestionIndices = {
              'Mathematics': [],
              'Reading': [],
              'Physics': [],
              'Technical': []
            };

            int idx = 0;
            for (var q in rawQuestions) {
              Map<String, dynamic> questionData = Map.from(q);
              if (questionData['options'] is List) {
                Map<String, String> optionsMap = {};
                for (var opt in questionData['options']) {
                  if (opt is Map) {
                    optionsMap[opt['key']] = opt['value'];
                  }
                }
                questionData['options'] = optionsMap;
              }
              processedQuestions.add(questionData);

              String subj = (questionData['subject'] ?? '').toString().toLowerCase();
              if (subj.contains('math')) sectionQuestionIndices['Mathematics']!.add(idx);
              else if (subj.contains('reading')) sectionQuestionIndices['Reading']!.add(idx);
              else if (subj.contains('physic')) sectionQuestionIndices['Physics']!.add(idx);
              else sectionQuestionIndices['Technical']!.add(idx);
              idx++;
            }

            List<Map<String, dynamic>> resultSections = [];
            sectionQuestionIndices.forEach((key, indices) {
              if (indices.isNotEmpty) {
                resultSections.add({
                  'name': key,
                  'startIndex': indices.first,
                  'endIndex': indices.last,
                });
              }
            });

            // Reconstruct user answers Map<int, String>
            final Map<dynamic, dynamic> savedAnswers = resultData['userAnswers'] ?? {};
            final Map<int, String> userAnswers = {};
            savedAnswers.forEach((key, value) {
              userAnswers[int.parse(key.toString())] = value.toString();
            });

            final List<String> correctAnswers = List<String>.from(resultData['correctAnswers'] ?? []);
            final authProvider = Provider.of<AuthProvider>(context, listen: false);

            Navigator.push(context, MaterialPageRoute(builder: (_) => 
              TILPracticeExamResultPage(
                userAnswers: userAnswers,
                correctAnswers: correctAnswers,
                questions: processedQuestions,
                examIndex: examIndex,
                title: resultData['title'] ?? title,
                accentColor: Colors.teal,
                toggleTheme: widget.toggleTheme,
                token: authProvider.token!,
                sections: resultSections,
              )
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to load exam details")),
            );
          }
        } catch (e) {
          if (context.mounted) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: isDark ? BentoColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.assignment_turned_in_outlined, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? BentoColors.darkTextSecondary : BentoColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.5), size: 16),
          ],
        ),
      ),
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
