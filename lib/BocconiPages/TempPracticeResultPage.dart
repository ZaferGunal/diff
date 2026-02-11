// TestResultsPage.dart - Navigation düzeltmesi

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../MyColors.dart';
import '../UserProvider.dart';

import 'home_page.dart';

class TestResultsPage extends StatefulWidget {
  final Map<int, String> userAnswers;
  final List<String> correctAnswers;
  final List<String> questionURLs;
  final int testIndex;
  final VoidCallback toggleTheme;

  const TestResultsPage({
    super.key,
    required this.userAnswers,
    required this.correctAnswers,
    required this.questionURLs,
    required this.testIndex,
    required this.toggleTheme,
  });

  @override
  State<TestResultsPage> createState() => _TestResultsPageState();
}

class _TestResultsPageState extends State<TestResultsPage> {
  void _showImageDialog(String? imageUrl) {
    if (imageUrl == null) return;

    const double dialogSizeRatio = 0.92;

    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: MediaQuery.of(context).size.width * dialogSizeRatio,
                    height: MediaQuery.of(context).size.height * dialogSizeRatio,
                    color: Colors.transparent,
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.white, size: 30),
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

    // Hesaplamalar
    int correctCount = 0;
    int wrongCount = 0;
    int emptyCount = 0;
    List<Map<String, dynamic>> incorrectQuestions = [];

    final totalQuestions = widget.correctAnswers.length;

    for (int i = 1; i <= totalQuestions; i++) {
      final answerIndex = i - 1;
      final hasImage = answerIndex < widget.questionURLs.length;

      if (!widget.userAnswers.containsKey(i)) {
        emptyCount++;
        incorrectQuestions.add({
          'questionNum': i,
          'userAnswer': '-',
          'correctAnswer': widget.correctAnswers[answerIndex],
          'isEmpty': true,
          'imageUrl': hasImage ? widget.questionURLs[answerIndex] : null,
        });
      } else if (widget.userAnswers[i] == widget.correctAnswers[answerIndex]) {
        correctCount++;
      } else {
        wrongCount++;
        incorrectQuestions.add({
          'questionNum': i,
          'userAnswer': widget.userAnswers[i],
          'correctAnswer': widget.correctAnswers[answerIndex],
          'isEmpty': false,
          'imageUrl': hasImage ? widget.questionURLs[answerIndex] : null,
        });
      }
    }

    double score = correctCount - (wrongCount / 4);
    score = score < 0 ? 0 : score;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // HomePage'i yeniden oluştur ve tüm stack'i temizle
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(
                  toggleTheme: widget.toggleTheme,
                  token: authProvider.token!,
                ),
              ),
                  (route) => false, // Tüm stack'i temizle
            );
          },
        ),
        title: Text('Test ${widget.testIndex} Results'),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        actions: [
          IconButton(
            icon: Icon(
                color: isDark ? Colors.yellow : MyColors.bocco_blue,
                isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Container(
        color: isDark
            ? const Color(0xFF0a0e27).withOpacity(0.5)
            : const Color(0xFFe8edf2),
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Özet Kartları
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Doğru',
                    correctCount.toString(),
                    Colors.green,
                    isDark,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    'Yanlış',
                    wrongCount.toString(),
                    Colors.red,
                    isDark,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    'Boş',
                    emptyCount.toString(),
                    Colors.orange,
                    isDark,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    'Puan',
                    score.toStringAsFixed(1),
                    const Color(0xFF667eea),
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Yanlış + Boş Sorular Listesi
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0f172a).withOpacity(0.7)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yanlış ve Boş Sorular (${incorrectQuestions.length})',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: incorrectQuestions.isEmpty
                          ? const Center(
                        child: Text(
                          '🎉 Tebrikler! Hiç yanlış ve boş soru yok!',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                          : ListView.builder(
                        itemCount: incorrectQuestions.length,
                        itemBuilder: (context, index) {
                          final question = incorrectQuestions[index];
                          final questionNum = question['questionNum'];
                          final userAnswer = question['userAnswer'];
                          final correctAnswer = question['correctAnswer'];
                          final isEmpty = question['isEmpty'];
                          final imageUrl = question['imageUrl'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.03)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2)
                                      ],
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$questionNum',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isEmpty
                                              ? Colors.orange
                                              .withOpacity(0.15)
                                              : Colors.red
                                              .withOpacity(0.15),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isEmpty
                                                ? Colors.orange
                                                .withOpacity(0.5)
                                                : Colors.red
                                                .withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isEmpty
                                                  ? Icons.remove_circle
                                                  : Icons.close,
                                              color: isEmpty
                                                  ? Colors.orange
                                                  : Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isEmpty
                                                  ? 'Boş'
                                                  : 'Senin: $userAnswer',
                                              style: const TextStyle(
                                                fontWeight:
                                                FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green
                                              .withOpacity(0.15),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.green
                                                .withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Doğru: $correctAnswer',
                                              style: const TextStyle(
                                                fontWeight:
                                                FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () =>
                                      _showImageDialog(imageUrl),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                          color: MyColors.cyan,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context,
                                                  child,
                                                  loadingProgress) {
                                                if (loadingProgress ==
                                                    null) {
                                                  return child;
                                                }
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color:
                                                      MyColors.cyan,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context,
                                                  error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons.error_outline,
                                                    color: Colors.red,
                                                    size: 24,
                                                  ),
                                                );
                                              },
                                            ),
                                            Container(
                                              color: Colors.black
                                                  .withOpacity(0.3),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.zoom_in,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // HomePage'i yeniden oluştur ve tüm stack'i temizle
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            toggleTheme: widget.toggleTheme,
                            token: authProvider.token!,
                          ),
                        ),
                            (route) => false, // Tüm stack'i temizle
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0f172a).withOpacity(0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}