import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../MyColors.dart';
import '../UserProvider.dart';

class PastPracticeResults extends StatefulWidget {
  final VoidCallback? toggleTheme;

  const PastPracticeResults({Key? key, this.toggleTheme}) : super(key: key);

  @override
  State<PastPracticeResults> createState() => _PastPracticeResultsState();
}

class _PastPracticeResultsState extends State<PastPracticeResults> {
  int? expandedTest;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void toggleTest(int testId, bool isCompleted) {
    if (!isCompleted) return;

    setState(() {
      expandedTest = expandedTest == testId ? null : testId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    Map<String, dynamic>? test1Result = authProvider.getResultForTest(1);
    Map<String, dynamic>? test2Result = authProvider.getResultForTest(2);
    Map<String, dynamic>? test3Result = authProvider.getResultForTest(3);
    Map<String, dynamic>? test4Result = authProvider.getResultForTest(4);

    final List<Map<String, dynamic>> tests = [
      {
        'id': 1,
        'name': 'Practice Test 1',
        'isCompleted': authProvider.practicesSolved[0],
        'correctAnswers': test1Result?["correctAnswers"],
        'wrongAnswers': test1Result?["wrongAnswers"],
        'emptyAnswers': test1Result?["emptyAnswers"],
        'score': test1Result?["score"],
        'date': test1Result?["date"]
      },
      {
        'id': 2,
        'name': 'Practice Test 2',
        'isCompleted': authProvider.practicesSolved[1],
        'correctAnswers': test2Result?["correctAnswers"],
        'wrongAnswers': test2Result?["wrongAnswers"],
        'emptyAnswers': test2Result?["emptyAnswers"],
        'score': test2Result?["score"],
        'date': test2Result?["date"]
      },
      {
        'id': 3,
        'name': 'Practice Test 3',
        'isCompleted': authProvider.practicesSolved[2],
        'correctAnswers': test3Result?["correctAnswers"],
        'wrongAnswers': test3Result?["wrongAnswers"],
        'emptyAnswers': test3Result?["emptyAnswers"],
        'score': test3Result?["score"],
        'date': test3Result?["date"]
      },
      {
        'id': 4,
        'name': 'Practice Test 4',
        'isCompleted': authProvider.practicesSolved[3],
        'correctAnswers': test4Result?["correctAnswers"],
        'wrongAnswers': test4Result?["wrongAnswers"],
        'emptyAnswers': test4Result?["emptyAnswers"],
        'score': test4Result?["score"],
        'date': test4Result?["date"]
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TEST RESULTS',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.toggleTheme != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? MyColors.cyan.withOpacity(0.3) : MyColors.green.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? Colors.yellow : MyColors.bocco_blue,
                ),
                onPressed: widget.toggleTheme,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: Column(
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                    MyColors.cyan.withOpacity(0.8),
                    MyColors.bocco_blue.withOpacity(0.8),
                  ]
                      : [
                    MyColors.green.withOpacity(0.8),
                    MyColors.green_light.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Practice Test History',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '${tests.where((t) => t['isCompleted']).length}/${tests.length} Completed',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Test List
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(8),
                interactive: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: tests.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    final isExpanded = expandedTest == test['id'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1a1f37)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: test['isCompleted']
                                ? (isDark ? MyColors.cyan.withOpacity(0.3) : MyColors.green.withOpacity(0.3))
                                : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => toggleTest(
                              test['id'],
                              test['isCompleted'],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Icon Container
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: test['isCompleted']
                                              ? LinearGradient(
                                            colors: isDark
                                                ? [
                                              MyColors.cyan.withOpacity(0.8),
                                              MyColors.bocco_blue.withOpacity(0.8),
                                            ]
                                                : [
                                              MyColors.green.withOpacity(0.8),
                                              MyColors.green_light.withOpacity(0.8),
                                            ],
                                          )
                                              : null,
                                          color: test['isCompleted']
                                              ? null
                                              : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(
                                          test['isCompleted']
                                              ? Icons.check_circle_outline
                                              : Icons.lock_outline,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 20),

                                      // Test Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              test['name'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: test['isCompleted']
                                                    ? (isDark ? Colors.white : Colors.black87)
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: test['isCompleted']
                                                    ? Colors.green.shade100
                                                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                test['isCompleted']
                                                    ? 'Completed'
                                                    : 'Not Solved',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: test['isCompleted']
                                                      ? Colors.green.shade700
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Expand Icon
                                      if (test['isCompleted'])
                                        AnimatedRotation(
                                          duration: const Duration(milliseconds: 300),
                                          turns: isExpanded ? 0.5 : 0,
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: isDark ? MyColors.cyan : MyColors.green,
                                            size: 32,
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Expanded Details
                                  if (test['isCompleted'] && isExpanded)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF0f172a)
                                              : Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isDark
                                                ? MyColors.cyan.withOpacity(0.2)
                                                : MyColors.green.withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildDetailRow(
                                              'Correct Answers',
                                              test['correctAnswers'].toString(),
                                              Icons.check_circle,
                                              Colors.green.shade600,
                                              isDark,
                                            ),
                                            const Divider(height: 28),
                                            _buildDetailRow(
                                              'Wrong Answers',
                                              test['wrongAnswers'].toString(),
                                              Icons.cancel,
                                              Colors.red.shade600,
                                              isDark,
                                            ),
                                            const Divider(height: 28),
                                            _buildDetailRow(
                                              'Empty Answers',
                                              test['emptyAnswers'].toString(),
                                              Icons.radio_button_unchecked,
                                              Colors.orange.shade600,
                                              isDark,
                                            ),
                                            const Divider(height: 28, thickness: 2),
                                            _buildScoreRow(
                                              test['score'].toString(),
                                              isDark,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label,
      String value,
      IconData icon,
      Color color,
      bool isDark,
      ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(String score, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.indigo.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              SizedBox(width: 12),
              Text(
                'Final Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            score,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}