import 'package:flutter/material.dart';
import '../MyColors.dart';

class SubjectTestResultPage extends StatelessWidget {
  final Map<int, String> userAnswers;
  final List<String> correctAnswers;
  final List<String> questionURLs; // ✅ Yeni parametre
  final String subjectType;
  final int testIndex;
  final String title;
  final Color accentColor;
  final VoidCallback toggleTheme;

  const SubjectTestResultPage({
    super.key,
    required this.userAnswers,
    required this.correctAnswers,
    required this.questionURLs, // ✅ Parametre eklendi
    required this.subjectType,
    required this.testIndex,
    required this.title,
    required this.accentColor,
    required this.toggleTheme,
  });

  // ✅ Resim dialog'u gösterme fonksiyonu
  void _showImageDialog(BuildContext context, String? imageUrl) {
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
              // Arka plan
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                ),
              ),
              // Görsel
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
              // Close butonu
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

    // ✅ Hesaplamalar - Dinamik soru sayısı
    int correctCount = 0;
    int wrongCount = 0;
    int emptyCount = 0;
    List<Map<String, dynamic>> incorrectQuestions = [];

    final totalQuestions = correctAnswers.length;

    for (int i = 0; i < totalQuestions; i++) {
      final questionNum = i + 1;
      final answerIndex = i;
      final hasImage = answerIndex < questionURLs.length;

      if (!userAnswers.containsKey(questionNum)) {
        emptyCount++;
        incorrectQuestions.add({
          'questionNum': questionNum,
          'userAnswer': '-',
          'correctAnswer': correctAnswers[answerIndex],
          'isEmpty': true,
          'imageUrl': hasImage ? questionURLs[answerIndex] : null,
        });
      } else if (userAnswers[questionNum] == correctAnswers[answerIndex]) {
        correctCount++;
      } else {
        wrongCount++;
        incorrectQuestions.add({
          'questionNum': questionNum,
          'userAnswer': userAnswers[questionNum],
          'correctAnswer': correctAnswers[answerIndex],
          'isEmpty': false,
          'imageUrl': hasImage ? questionURLs[answerIndex] : null,
        });
      }
    }

    final score = ((correctCount / totalQuestions) * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text('${title.toUpperCase()} - TEST $testIndex RESULTS'),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              color: isDark ? Colors.yellow : MyColors.bocco_blue,
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: toggleTheme,
          ),
          const SizedBox(width: 21),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  // Score Card
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.8),
                          accentColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Test Completed!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              score,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '%',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 36,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$correctCount out of $totalQuestions correct',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Statistics
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1a1f37) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed Statistics',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildStatRow(
                          'Correct Answers',
                          correctCount,
                          totalQuestions,
                          MyColors.green,
                          Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          'Wrong Answers',
                          wrongCount,
                          totalQuestions,
                          MyColors.red,
                          Icons.cancel_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          'Unanswered',
                          emptyCount,
                          totalQuestions,
                          Colors.orange,
                          Icons.radio_button_unchecked,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ✅ Yanlış ve Boş Sorular Listesi
                  if (incorrectQuestions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1a1f37)
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
                            'Wrong and Unanswered Questions (${incorrectQuestions.length})',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                                    // Soru numarası
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accentColor.withOpacity(0.8),
                                            accentColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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

                                    // Şıklar
                                    Expanded(
                                      child: Row(
                                        children: [
                                          // Kullanıcının cevabı
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isEmpty
                                                  ? Colors.orange.withOpacity(0.15)
                                                  : Colors.red.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isEmpty
                                                    ? Colors.orange.withOpacity(0.5)
                                                    : Colors.red.withOpacity(0.5),
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
                                                  isEmpty ? 'Empty' : 'Yours: $userAnswer',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),

                                          // Doğru cevap
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.green.withOpacity(0.5),
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
                                                  'Correct: $correctAnswer',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
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

                                    // Soru resmi - küçük thumbnail
                                    if (imageUrl != null)
                                      GestureDetector(
                                        onTap: () => _showImageDialog(context, imageUrl),
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: accentColor,
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder:
                                                        (context, child, loadingProgress) {
                                                      if (loadingProgress == null) {
                                                        return child;
                                                      }
                                                      return Center(
                                                        child: SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: accentColor,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder:
                                                        (context, error, stackTrace) {
                                                      return const Center(
                                                        child: Icon(
                                                          Icons.error_outline,
                                                          color: Colors.red,
                                                          size: 24,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  // Zoom ikonu overlay
                                                  Container(
                                                    color: Colors.black.withOpacity(0.3),
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
                        ],
                      ),
                    ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.home),
                          label: const Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF1a1f37)
                                : Colors.white,
                            foregroundColor:
                            isDark ? Colors.white : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey[300]!,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.8),
                                accentColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text(
                              'Back to Tests',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
      String label,
      int value,
      int total,
      Color color,
      IconData icon,
      ) {
    final percentage = ((value / total) * 100).toStringAsFixed(1);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value / total,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}