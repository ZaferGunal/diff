import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'TILIDashboard.dart'; // For BentoColors
import '../UserProvider.dart';

import '../widgets/theme_toggle.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TILSubjectTestResultPage extends StatefulWidget {
  final Map<int, String> userAnswers;
  final List<String> correctAnswers;
  final List<String> questionURLs;
  final List<Map<String, dynamic>> questions;
  final String subjectType;
  final int testIndex;
  final String title;
  final Color accentColor;
  final VoidCallback toggleTheme;
  final String token;

  const TILSubjectTestResultPage({
    super.key,
    required this.userAnswers,
    required this.correctAnswers,
    required this.questionURLs,
    required this.questions,
    required this.subjectType,
    required this.testIndex,
    required this.title,
    required this.accentColor,
    required this.toggleTheme,
    required this.token,
  });

  @override
  State<TILSubjectTestResultPage> createState() => _TILSubjectTestResultPageState();
}

class _TILSubjectTestResultPageState extends State<TILSubjectTestResultPage> {
  late int correctCount;
  late int wrongCount;
  late int emptyCount;
  late int totalQuestions;
  late double score;
  List<Map<String, dynamic>> incorrectQuestions = [];
  Map<String, List<bool>> topicPerformance = {};

  @override
  void initState() {
    super.initState();
    _calculateResults();
  }

  void _calculateResults() {
    correctCount = 0;
    wrongCount = 0;
    emptyCount = 0;
    totalQuestions = widget.correctAnswers.length;
    incorrectQuestions = [];
    topicPerformance = {};

    for (int i = 0; i < totalQuestions; i++) {
      final questionNum = i + 1;
      final correctAnswer = widget.correctAnswers[i];
      final userAnswer = widget.userAnswers[questionNum];
      final questionData = widget.questions.length > i ? widget.questions[i] : null;
      final topic = questionData?['topic']?.toString() ?? 'General';
      
      if (!topicPerformance.containsKey(topic)) {
        topicPerformance[topic] = [];
      }

      bool isCorrect = false;
      final normalizedUserAnswer = userAnswer?.trim().toUpperCase() ?? '';
      final normalizedCorrectAnswer = correctAnswer.trim().toUpperCase();

      if (normalizedUserAnswer.isEmpty || normalizedUserAnswer == '-') {
        emptyCount++;
        isCorrect = false;
        incorrectQuestions.add({
          'questionNum': questionNum,
          'userAnswer': '-',
          'correctAnswer': normalizedCorrectAnswer,
          'isEmpty': true,
          'imageUrl': questionData?['imageUrl'],
          'topic': topic,
        });
      } else if (normalizedUserAnswer == normalizedCorrectAnswer) {
        correctCount++;
        isCorrect = true;
      } else {
        wrongCount++;
        isCorrect = false;
        incorrectQuestions.add({
          'questionNum': questionNum,
          'userAnswer': normalizedUserAnswer,
          'correctAnswer': normalizedCorrectAnswer,
          'isEmpty': false,
          'imageUrl': questionData?['imageUrl'],
          'topic': topic,
        });
      }
      
      topicPerformance[topic]!.add(isCorrect);
    }

    score = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;
  }



  void _showImageDialog(String? imageUrl) {
    if (imageUrl == null) return;
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.9))),
              Center(
                child: InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 40, right: 40,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestionDetailDialog(Map<String, dynamic> q) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    const turquoise = Color(0xFF00CED1);
    
    final originalQuestion = widget.questions.firstWhere(
      (element) => (widget.questions.indexOf(element) + 1) == q['questionNum'],
      orElse: () => {},
    );

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
            border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.5)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: turquoise.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Center(child: Text("${q['questionNum']}", style: const TextStyle(color: turquoise, fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Question Review", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
                          Text("Topic: ${q['topic']}", style: GoogleFonts.outfit(fontSize: 14, color: text.withOpacity(0.5))),
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
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: text.withValues(alpha: 0.1)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(q['imageUrl'], fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (originalQuestion['questionText'] != null) ...[
                        MathText(
                          text: originalQuestion['questionText'].toString(),
                          style: GoogleFonts.outfit(fontSize: 18, color: text, height: 1.6),
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (originalQuestion['options'] is Map) ...[
                        ...((originalQuestion['options'] as Map).keys.toList()..sort()).map((key) {
                          final value = originalQuestion['options'][key];
                          final isCorrect = key == q['correctAnswer'];
                          final isUserChoice = key == q['userAnswer'];
                          
                          Color optionBg = Colors.transparent;
                          Color borderColor = text.withOpacity(0.1);
                          Color textColor = text;
                          double borderW = 1.2;
                          
                          if (isCorrect) {
                            optionBg = Colors.green.withValues(alpha: 0.1);
                            borderColor = Colors.green;
                            textColor = Colors.green;
                            borderW = 2.5;
                          }
                          
                          if (isUserChoice && !isCorrect) {
                            borderColor = Colors.redAccent;
                            textColor = Colors.redAccent;
                            optionBg = Colors.redAccent.withValues(alpha: 0.05);
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
                                    color: isCorrect ? Colors.green : (isUserChoice ? Colors.redAccent : text.withValues(alpha: 0.1)),
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
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final surface = isDark ? BentoColors.darkSurface : BentoColors.lightSurface;
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
            child: _buildBlurCircle(widget.accentColor.withValues(alpha: 0.1), 400),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(isDark, text),
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 16 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroScoreCard(isDark, text),
                          const SizedBox(height: 24),
                          _buildQuickStats(isDark, text),
                          const SizedBox(height: 40),
                          
                          if (incorrectQuestions.isNotEmpty) ...[
                            _buildSectionTitle("Review Questions", widget.accentColor),
                            const SizedBox(height: 16),
                            ...incorrectQuestions.map((q) => _buildQuestionReviewCard(q, isDark, text)),
                            const SizedBox(height: 40),
                          ],
                          
                          _buildSectionTitle("Test Analysis", widget.accentColor),
                          const SizedBox(height: 16),
                          _buildAnalysisCard(isDark, text),
                          const SizedBox(height: 100), // Extra space at bottom
                          
                          _buildBottomActions(isDark, text),
                          const SizedBox(height: 40),
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
        "Result Summary",
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: text),
      ),
      actions: [
        SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
        const SizedBox(width: 16),
      ],
      floating: true,
    );
  }

  Widget _buildHeroScoreCard(bool isDark, Color text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 48, horizontal: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: isDark ? BentoColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
        border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.5)),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.1),
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
            "Final Score",
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: text.withValues(alpha: 0.4),
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.05),
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
            Text(label, style: GoogleFonts.outfit(fontSize: isMobile ? 12 : 14, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4))),
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

  Widget _buildQuestionReviewCard(Map<String, dynamic> q, bool isDark, Color text) {
    final isEmpty = q['isEmpty'] == true;
    final turquoise = const Color(0xFF00CED1); // DarkTurquoise
    final accent = isEmpty ? turquoise : Colors.redAccent;
    final hasImage = q['imageUrl'] != null && q['imageUrl'].toString().isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? BentoColors.darkSurface.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                        color: accent.withValues(alpha: 0.1),
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
                            "Topic: ${q['topic']}",
                            style: GoogleFonts.outfit(fontSize: 13, color: text.withValues(alpha: 0.4), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    if (hasImage) 
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: text.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.image_rounded, color: text.withValues(alpha: 0.3), size: 20),
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded, color: text.withValues(alpha: 0.2), size: 16),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.vertical(bottom: const Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    _buildAnswerResultText("Correct Answer", q['correctAnswer'], Colors.green, isCorrectAns: true),
                    const SizedBox(width: 24),
                    _buildAnswerResultText("Selected", q['userAnswer'], accent),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: turquoise.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Review",
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: turquoise),
                      ),
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

  Widget _buildAnswerResultText(String label, String value, Color color, {bool isCorrectAns = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.3), fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Container(
          padding: isCorrectAns ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4) : null,
          decoration: isCorrectAns ? BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ) : null,
          child: Text(value.isEmpty ? '?' : value, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: color, fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildMiniResultChip(String label, String value, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3), fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      ],
    );
  }

  Widget _buildAnalysisCard(bool isDark, Color text) {
    // If we have topics, we might show a radar chart or bar chart
    final topics = topicPerformance.keys.toList();
    final topCount = topics.length;

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
          if (topCount >= 3) ...[
            SizedBox(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  dataSets: [
                    RadarDataSet(
                      fillColor: widget.accentColor.withValues(alpha: 0.2),
                      borderColor: widget.accentColor,
                      entryRadius: 3,
                      dataEntries: topics.map((t) {
                        final perfs = topicPerformance[t]!;
                        final corrects = perfs.where((c) => c).length;
                        return RadarEntry(value: corrects / perfs.length * 10); // Scale to 10
                      }).toList(),
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  titlePositionPercentageOffset: 0.15,
                  titleTextStyle: GoogleFonts.outfit(fontSize: 10, color: text.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
                  getTitle: (index, angle) {
                    final t = topics[index];
                    return RadarChartTitle(text: t.length > 10 ? "${t.substring(0, 8)}.." : t);
                  },
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                  gridBorderData: BorderSide(color: text.withValues(alpha: 0.05), width: 1),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Performance list
          ...topics.map((t) {
            final perfs = topicPerformance[t]!;
            final corrects = perfs.where((c) => c).length;
            final pct = corrects / perfs.length;
            final color = pct > 0.75 ? Colors.green : (pct > 0.4 ? Colors.orange : Colors.redAccent);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: text)),
                      Text("${(pct * 100).toInt()}%", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
              true,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              "Return to Tests", 
              Icons.arrow_back_rounded, 
              isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), 
              () => Navigator.pop(context),
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap, bool isPrimary) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isPrimary ? color : color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isPrimary ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MathText Widget
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
