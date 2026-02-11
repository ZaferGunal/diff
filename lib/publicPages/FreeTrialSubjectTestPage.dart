import 'package:flutter/material.dart';
import '../MyColors.dart';
import 'FreeTrialSubjectDetailTest.dart';


class FreeTrialSubjectsPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const FreeTrialSubjectsPage({super.key, required this.toggleTheme});

  @override
  State<FreeTrialSubjectsPage> createState() => _FreeTrialSubjectsPageState();
}

class _FreeTrialSubjectsPageState extends State<FreeTrialSubjectsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Her subject için test sayılarını tanımlayalım
  Map<String, int> _getTestCounts() {
    return {
      'logic': 6,
      'reading': 20,
      'critical': 6,
      'math': 32,
      'numerical': 6,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final testCounts = _getTestCounts();

    final subjects = [
      {
        'title': '🧩 Logic',
        'subtitle': 'Test your logical reasoning',
        'color': MyColors.logic,
        'icon': Icons.psychology_outlined,
        'id': 'logic',
      },
      {
        'title': '📖 Reading',
        'subtitle': 'Improve comprehension skills',
        'color':  MyColors.reading,
        'icon': Icons.menu_book_outlined,
        'id': 'reading',
      },
      {
        'title': '🔍 Critical Thinking',
        'subtitle': 'Sharpen analytical abilities',
        'color': MyColors.criticalThinking,
        'icon': Icons.insights_outlined,
        'id': 'critical',
      },
      {
        'title': '🔢 Math',
        'subtitle': 'Challenge your math skills',
        'color': MyColors.math,
        'icon': Icons.calculate_outlined,
        'id': 'math',
      },
      {
        'title': '📊 Numerical Reasoning',
        'subtitle': 'Analyze data and numbers',
        'color': MyColors.numericalReasoning,
        'icon': Icons.analytics_outlined,
        'id': 'numerical',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SUBJECT TESTS',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
        actions: [

          const SizedBox(width: 21),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          interactive: true,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(60),
            children: [
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06b6d4), Color(0xFF9333ea)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Select a Test Category',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 21),
                child: Text(
                  'Test your knowledge in different subjects',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      final subjectId = subject['id'] as String;
                      return _buildSubjectCard(
                        context,
                        subject['title'] as String,
                        subject['subtitle'] as String,
                        subject['color'] as Color,
                        subject['icon'] as IconData,
                        subjectId,
                        testCounts[subjectId]!,
                        isDark,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
      BuildContext context,
      String title,
      String subtitle,
      Color accentColor,
      IconData icon,
      String subjectId,
      int testCount,
      bool isDark,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FreeTrialSubjectDetailPage(
              title: title,
              subjectId: subjectId,
              accentColor: accentColor,
              icon: icon,
              toggleTheme: widget.toggleTheme,
              testCount: testCount,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1a1f3a), const Color(0xFF0f172a)]
                          : [Colors.white, Colors.grey[50]!],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accentColor.withOpacity(0.2),
                          accentColor.withOpacity(0.8),
                          accentColor.withOpacity(0.95),
                          accentColor.withOpacity(0.8),
                          accentColor.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: accentColor, size: 36),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 14, color: Colors.green.shade700),
                                  const SizedBox(width: 6),
                                  Text(
                                    '1 Free Test',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: accentColor.withOpacity(0.7),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}