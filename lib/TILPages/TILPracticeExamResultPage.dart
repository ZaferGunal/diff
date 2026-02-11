import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'TILIDashboard.dart'; // For BentoColors
import '../UserProvider.dart';
import '../services/authservice.dart';

import '../widgets/theme_toggle.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TILPracticeExamResultPage extends StatefulWidget {
  final Map<int, String> userAnswers;
  final List<String> correctAnswers;
  final List<Map<String, dynamic>> questions;
  final int examIndex;
  final String title;
  final Color accentColor;
  final VoidCallback toggleTheme;
  final String token;
  final List<Map<String, dynamic>> sections; // Added sections parameter

  const TILPracticeExamResultPage({
    super.key,
    required this.userAnswers,
    required this.correctAnswers,
    required this.questions,
    required this.examIndex,
    required this.title,
    required this.accentColor,
    required this.toggleTheme,
    required this.token,
    required this.sections,
  });

  @override
  State<TILPracticeExamResultPage> createState() => _TILPracticeExamResultPageState();
}

class _TILPracticeExamResultPageState extends State<TILPracticeExamResultPage> {
  late int correctCount;
  late int wrongCount;
  late int emptyCount;
  late int totalQuestions;
  late double score;
  List<Map<String, dynamic>> incorrectQuestions = [];
  Map<String, Map<String, int>> sectionPerformance = {}; // Section -> {total, correct}

  @override
  void initState() {
    super.initState();
    _calculateResults();
    _saveResult();
  }

  Future<void> _saveResult() async {
    try {
      // Convert Map<int, String> to Map<String, String> for JSON serialization
      final Map<String, String> formattedAnswers = widget.userAnswers.map(
        (key, value) => MapEntry(key.toString(), value)
      );

      await AuthService().saveTILPracticeExamResult(
        token: widget.token,
        examIndex: widget.examIndex,
        title: widget.title,
        correctCount: correctCount,
        wrongCount: wrongCount,
        emptyCount: emptyCount,
        score: score,
        userAnswers: formattedAnswers,
        correctAnswers: widget.correctAnswers,
      );
      print('✅ Exam result saved successfully');
    } catch (e) {
      print('❌ Failed to save exam result: $e');
    }
  }

  void _calculateResults() {
    correctCount = 0;
    wrongCount = 0;
    emptyCount = 0;
    totalQuestions = widget.questions.length;
    incorrectQuestions = [];
    sectionPerformance = {};

    // Initialize section performance
    for (var section in widget.sections) {
      sectionPerformance[section['name']] = {'total': 0, 'correct': 0};
    }

    for (int i = 0; i < totalQuestions; i++) {
        // Determine which section this question belongs to
        Map<String, dynamic>? currentSection;
        for (var section in widget.sections) {
            int start = section['startIndex'];
            int end = section['endIndex'];
            // Check based on standard index ranges
            // Or better, just count total items per section
            // In the testing page, we used startIndex and questionCount.
            // Here we receive sections with start and end index (inclusive) or similar logic from testing page.
            
            // Re-inferring from the Passed sections:
            // "startIndex": 0, "endIndex": 14
            if (i >= start && i <= end) {
                currentSection = section;
                break;
            }
        }
        
        String sectionName = currentSection?['name'] ?? 'Unknown';
        if (sectionPerformance[sectionName] == null) {
           sectionPerformance[sectionName] = {'total': 0, 'correct': 0};
        }
        sectionPerformance[sectionName]!['total'] = (sectionPerformance[sectionName]!['total'] ?? 0) + 1;

        final questionNum = i; // 0-indexed internally for arrays
        final correctAnswer = widget.correctAnswers[i];
        final userAnswer = widget.userAnswers[i]; // 0-indexed keys in answers map
        final questionData = widget.questions[i];
        final topic = questionData['topic']?.toString() ?? 'General';
        
        String normalizedUserAnswer = userAnswer?.trim().toUpperCase() ?? '-';
        String normalizedCorrectAnswer = correctAnswer.trim().toUpperCase();

        bool isCorrect = false;

        if (normalizedUserAnswer == '-' || normalizedUserAnswer.isEmpty) {
          emptyCount++;
          isCorrect = false;
          incorrectQuestions.add({
            'questionNum': i + 1,
            'userAnswer': '-',
            'correctAnswer': normalizedCorrectAnswer,
            'isEmpty': true,
            'imageUrl': questionData['imageUrl'],
            'topic': topic,
            'questionText': questionData['questionText'],
            'options': questionData['options'],
            'section': sectionName,
          });
        } else if (normalizedUserAnswer == normalizedCorrectAnswer) {
          correctCount++;
          isCorrect = true;
          sectionPerformance[sectionName]!['correct'] = (sectionPerformance[sectionName]!['correct'] ?? 0) + 1;
        } else {
          wrongCount++;
          isCorrect = false;
           incorrectQuestions.add({
            'questionNum': i + 1,
            'userAnswer': normalizedUserAnswer,
            'correctAnswer': normalizedCorrectAnswer,
            'isEmpty': false,
            'imageUrl': questionData['imageUrl'],
            'topic': topic,
            'questionText': questionData['questionText'],
            'options': questionData['options'],
            'section': sectionName,
          });
        }
    }

    score = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;
  }


  
  void _showQuestionDetailDialog(Map<String, dynamic> q) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    const turquoise = Color(0xFF00CED1);
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 24 : 40),
        child: Container(
          width: isMobile ? double.infinity : 800,
          decoration: BoxDecoration(
            color: isDark ? BentoColors.darkBg : BentoColors.lightBg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.5)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: turquoise.withOpacity(0.1), shape: BoxShape.circle),
                      child: Center(child: Text("${q['questionNum']}", style: const TextStyle(color: turquoise, fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Question Review", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
                          Text("Section: ${q['section']}", style: GoogleFonts.outfit(fontSize: 14, color: text.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: text.withOpacity(0.5)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       if (q['imageUrl'] != null && q['imageUrl'].toString().isNotEmpty) ...[
                        Center(
                           child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 300),
                              child: ClipRRect(
                                 borderRadius: BorderRadius.circular(16),
                                 child: Image.network(q['imageUrl'], fit: BoxFit.contain),
                              ),
                           ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (q['questionText'] != null) ...[
                        MathText(
                          text: q['questionText'].toString(),
                          style: GoogleFonts.outfit(fontSize: 18, color: text, height: 1.6),
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (q['options'] is Map) ...[
                        ...((q['options'] as Map).keys.toList()..sort()).map((key) {
                          final value = q['options'][key];
                          final isCorrect = key == q['correctAnswer'];
                          final isUserChoice = key == q['userAnswer'];
                          
                          Color optionBg = Colors.transparent;
                          Color borderColor = text.withOpacity(0.1);
                          Color textColor = text;
                          double borderW = 1.2;
                          
                          if (isCorrect) {
                            optionBg = Colors.green.withOpacity(0.1);
                            borderColor = Colors.green;
                            textColor = Colors.green;
                            borderW = 2.5;
                          } else if (isUserChoice && !isCorrect) {
                            borderColor = Colors.redAccent;
                            textColor = Colors.redAccent;
                            optionBg = Colors.redAccent.withOpacity(0.05);
                            borderW = 2.5;
                          }

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: optionBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: borderW),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: isCorrect ? Colors.green : (isUserChoice ? Colors.redAccent : text.withOpacity(0.1)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text(key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: MathText(
                                    text: value.toString(),
                                    style: GoogleFonts.outfit(fontSize: 16, color: textColor, fontWeight: isCorrect || isUserChoice ? FontWeight.bold : FontWeight.normal),
                                  ),
                                ),
                                if (isCorrect) const Icon(Icons.check_circle_rounded, color: Colors.green),
                                if (isUserChoice && !isCorrect) const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
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
    final bg = isDark ? BentoColors.darkBg : const Color(0xFFFBFBFE); // Extra light and airy
    final surface = isDark ? BentoColors.darkSurface : Colors.white;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background Ambience
          Positioned(
            top: -100, right: -100,
            child: _buildBlurCircle(widget.accentColor.withOpacity(0.1), 400),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(isDark, text),
                SliverToBoxAdapter(
                  child: Center( // Center the content
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 900), // Max width for desktop
                      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 24 : 48, isMobile ? 16 : 24, 32),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroScoreCard(isDark, text, isMobile),
                        SizedBox(height: isMobile ? 32 : 48), // Increased spacing
                        _buildQuickStats(isDark, text),
                        const SizedBox(height: 64), // Increased spacing
                        
                        _buildSectionTitle("Section Analysis", widget.accentColor),
                        const SizedBox(height: 24), // Increased spacing
                        _buildSectionAnalysisCard(isDark, text),
                        const SizedBox(height: 64), // Increased spacing

                        if (incorrectQuestions.isNotEmpty) ...[
                          _buildSectionTitle("Review Incorrect Questions", Colors.redAccent),
                          const SizedBox(height: 24), // Increased spacing
                          ...incorrectQuestions.map((q) => Padding(
                             padding: const EdgeInsets.only(bottom: 24), // Increased card spacing
                             child: _buildQuestionReviewCard(q, isDark, text),
                          )),
                          const SizedBox(height: 64), // Increased spacing
                        ],
                        
                        _buildBottomActions(isDark, text),
                        const SizedBox(height: 64), // More room at the bottom
                      ],
                    ),
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

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark, Color text) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: text),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Exam Results",
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: text),
      ),
      actions: [
        SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
        const SizedBox(width: 16),
      ],
      floating: true,
      pinned: true, // Make it pinned so toggle stays visible
    );
  }

  Widget _buildHeroScoreCard(bool isDark, Color text, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 48, horizontal: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: isDark ? BentoColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 40), // More rounded
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.8)),
        boxShadow: [
           BoxShadow(
              color: widget.accentColor.withOpacity(isDark ? 0.15 : 0.08), 
              blurRadius: 40, 
              offset: const Offset(0, 20),
           ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded, color: widget.accentColor, size: isMobile ? 32 : 48),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: GoogleFonts.outfit(
                  fontSize: isMobile ? 56 : 80,
                  fontWeight: FontWeight.w900,
                  color: text,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "%",
                style: GoogleFonts.outfit(
                  fontSize: isMobile ? 18 : 24,
                  fontWeight: FontWeight.w600,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
          Text(
            "Overall Score",
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: text.withOpacity(0.4),
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$correctCount Correct • $wrongCount Wrong • $emptyCount Empty",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: widget.accentColor,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark, Color text) {
    // Check if mobile via context if possible, or pass it. 
    // Since we didn't pass isMobile to this method in the build call update, 
    // we should update it there or just use MediaQuery here.
    // However, clean approach is to use MediaQuery here if not passed.
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Row(
      children: [
        _buildStatBox("Accuracy", "${totalQuestions > 0 ? (correctCount / (correctCount + wrongCount + 0.0001) * 100).toInt() : 0}%", Icons.speed, Colors.blue, isDark, isMobile),
        const SizedBox(width: 16),
        _buildStatBox("Completion", "${totalQuestions > 0 ? ((correctCount + wrongCount) / totalQuestions * 100).toInt() : 0}%", Icons.donut_large, Colors.teal, isDark, isMobile),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color, bool isDark, bool isMobile) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: isDark ? BentoColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: isMobile ? 20 : 24),
            SizedBox(height: isMobile ? 8 : 12),
            Text(value, style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            Text(label, style: GoogleFonts.outfit(fontSize: isMobile ? 12 : 14, color: (isDark ? Colors.white : Colors.black).withOpacity(0.4))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionAnalysisCard(bool isDark, Color text) {
     // Prepare radar chart data
     List<String> sectionNames = widget.sections.map((s) => s['name'].toString()).toList();
     List<double> sectionScores = widget.sections.map((s) {
       var perf = sectionPerformance[s['name']] ?? {'total': 0, 'correct': 0};
       int total = perf['total'] ?? 0;
       int correct = perf['correct'] ?? 0;
       return total > 0 ? (correct / total) * 100 : 0.0;
     }).toList();

     // Section colors
     final sectionColors = {
       'Mathematics': Colors.blue,
       'Reading': Colors.orange,
       'Physics': Colors.purple,
       'Technical Knowledge': Colors.teal,
     };

     final screenWidth = MediaQuery.of(context).size.width;
     final isMobile = screenWidth < 768;

     return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
           color: isDark ? BentoColors.darkSurface : Colors.white,
           borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
           border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.5)),
        ),
        child: Column(
           children: [
             // Radar Chart Section
             SizedBox(
               height: 280,
               child: RadarChart(
                 RadarChartData(
                   dataSets: [
                     RadarDataSet(
                       dataEntries: sectionScores.map((score) => RadarEntry(value: score)).toList(),
                       fillColor: widget.accentColor.withOpacity(0.2),
                       borderColor: widget.accentColor,
                       borderWidth: 2.5,
                       entryRadius: 4,
                     ),
                   ],
                   radarBackgroundColor: Colors.transparent,
                   borderData: FlBorderData(show: false),
                   radarBorderData: BorderSide(color: text.withOpacity(0.1), width: 1),
                   tickBorderData: BorderSide(color: text.withOpacity(0.05), width: 1),
                   gridBorderData: BorderSide(color: text.withOpacity(0.08), width: 1),
                   tickCount: 4,
                   ticksTextStyle: GoogleFonts.outfit(fontSize: 10, color: text.withOpacity(0.4)),
                   titlePositionPercentageOffset: 0.2,
                   getTitle: (index, angle) {
                     String name = sectionNames[index];
                     String shortName = name.length > 10 ? name.substring(0, 10) : name;
                     if (name == 'Technical Knowledge') shortName = 'Tech';
                     if (name == 'Mathematics') shortName = 'Math';
                     
                     return RadarChartTitle(
                       text: shortName,
                       angle: 0,
                       positionPercentageOffset: 0.05,
                     );
                   },
                   titleTextStyle: GoogleFonts.outfit(
                     fontSize: 12,
                     fontWeight: FontWeight.w600,
                     color: text.withOpacity(0.7),
                   ),
                 ),
               ),
             ),

             const SizedBox(height: 32),
             
             // Divider
             Container(
               height: 1,
               color: text.withOpacity(0.05),
             ),
             
             const SizedBox(height: 24),

             // Progress Bars Detail
             ...widget.sections.map((section) {
              String name = section['name'];
              var perf = sectionPerformance[name] ?? {'total': 0, 'correct': 0};
              int total = perf['total'] ?? 0;
              int correct = perf['correct'] ?? 0;
              double pct = total > 0 ? correct / total : 0;
              
              Color barColor = sectionColors[name] ?? widget.accentColor;
              
              return Padding(
                 padding: const EdgeInsets.only(bottom: 20),
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Row(
                               children: [
                                 Container(
                                   width: 10,
                                   height: 10,
                                   decoration: BoxDecoration(
                                     color: barColor,
                                     borderRadius: BorderRadius.circular(3),
                                   ),
                                 ),
                                 const SizedBox(width: 10),
                                 Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: text)),
                               ],
                             ),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: barColor.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: Text(
                                 "${(pct * 100).toInt()}%", 
                                 style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: barColor),
                               ),
                             ),
                          ],
                       ),
                       const SizedBox(height: 10),
                       ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                             value: pct,
                             backgroundColor: barColor.withOpacity(0.08),
                             valueColor: AlwaysStoppedAnimation(barColor),
                             minHeight: 10,
                          ),
                       ),
                       const SizedBox(height: 6),
                       Text("$correct / $total Correct", style: GoogleFonts.outfit(fontSize: 12, color: text.withOpacity(0.4))),
                    ],
                 ),
              );
           }).toList(),
          ],
        ),
     );
  }

  Widget _buildQuestionReviewCard(Map<String, dynamic> q, bool isDark, Color text) {
    final isEmpty = q['isEmpty'] == true;
    final turquoise = const Color(0xFF00CED1);
    final accent = isEmpty ? turquoise : Colors.redAccent;
    final hasImage = q['imageUrl'] != null && q['imageUrl'].toString().isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? BentoColors.darkSurface.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(28), // More rounded
        border: Border.all(color: accent.withOpacity(isDark ? 0.15 : 0.1), width: 1.5),
        boxShadow: [
           BoxShadow(
              color: accent.withOpacity(isDark ? 0.08 : 0.04), 
              blurRadius: 24, 
              offset: const Offset(0, 12),
           ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showQuestionDetailDialog(q),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          "${q['questionNum']}", 
                          style: GoogleFonts.outfit(color: accent, fontWeight: FontWeight.w900, fontSize: 18)
                        )
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEmpty ? "NOT ANSWERED" : "INCORRECT",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900, 
                              color: accent, 
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Section: ${q['section']}",
                            style: GoogleFonts.outfit(fontSize: 13, color: text.withOpacity(0.4), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    if (hasImage) 
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: text.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.image_rounded, color: text.withOpacity(0.3), size: 20),
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded, color: text.withOpacity(0.2), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isDark, Color text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 400),
        child: Column(
          children: [
            _buildActionButton(
              "Back to Dashboard", 
              Icons.dashboard_rounded, 
              widget.accentColor, 
              () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => TILIDashboard(
                      toggleTheme: widget.toggleTheme,
                      token: widget.token,
                    ),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

// MathText Widget Duplicate (Should be shared but copying for now/safety)
class MathText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const MathText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final combinedRegex = RegExp(r'\$\$(.*?)\$\$|\$(.*?)\$', dotAll: true);
    final matches = combinedRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (var match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      final mathContent = match.group(1) ?? match.group(2) ?? '';
      final isDisplayMode = match.group(1) != null;

      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        baseline: TextBaseline.alphabetic,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDisplayMode ? 8 : 3,
            vertical: isDisplayMode ? 6 : 0,
          ),
          child: Math.tex(
            mathContent.trim(),
            mathStyle: isDisplayMode ? MathStyle.display : MathStyle.text,
            textStyle: style,
            textScaleFactor: 1.0,
          ),
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
}
