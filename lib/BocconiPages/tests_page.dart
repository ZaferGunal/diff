import 'package:flutter/material.dart';
import '../MyColors.dart';
import 'SubjectTestViewPage.dart';


class TestsPage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const TestsPage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SUBJECT TESTS',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
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
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              int crossAxisCount = screenWidth > 900 ? 2 : 1;

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(60),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [MyColors.cyan, MyColors.bocco_blue],
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
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 2.2,
                    children: [
                      _buildTestCard(
                        '🧩 Logic',
                        'Test your logical reasoning',
                        context,
                        isDark,
                        Colors.purple,
                        Icons.psychology_outlined,
                        'logic',
                        false,
                      ),
                      _buildTestCard(
                        '📖 Reading',
                        'Improve comprehension skills',
                        context,
                        isDark,
                        MyColors.reading,
                        Icons.menu_book_outlined,
                        'reading',
                        false,
                      ),
                      _buildTestCard(
                        '🔍 Critical Thinking',
                        'Sharpen analytical abilities',
                        context,
                        isDark,
                        MyColors.criticalThinking,
                        Icons.insights_outlined,
                        'critical_thinking',
                        false,
                      ),
                      _buildTestCard(
                        '🔢 Math',
                        'Challenge your math skills',
                        context,
                        isDark,
                        MyColors.cyan,
                        Icons.calculate_outlined,
                        'math',
                        false,
                      ),
                      _buildTestCard(
                        '📊 Numerical Reasoning',
                        'Analyze data and numbers',
                        context,
                        isDark,
                        MyColors.numericalReasoning,
                        Icons.analytics_outlined,
                        'numerical_reasoning',
                        false,
                      ),
                      _buildTestCard(
                        '💬 Verbal Reasoning',
                        'Master language and logic',
                        context,
                        isDark,
                        MyColors.verbalReasoning,
                        Icons.record_voice_over_outlined,
                        'verbal_reasoning',
                        true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(
      String title,
      String subtitle,
      BuildContext context,
      bool isDark,
      Color accentColor,
      IconData icon,
      String subjectType,
      bool showComingSoon,
      ) {
    return GestureDetector(
      onTap: () {
        if (showComingSoon) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.construction, color: Colors.orange, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This feature is coming soon!',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We are working hard to bring you $title tests. Stay tuned!',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectTestViewPage(
                title: title,
                subjectType: subjectType,
                accentColor: accentColor,
                icon: icon,
              ),
            ),
          );
        }
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
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
                          ? [
                        const Color(0xFF1a1f3a),
                        const Color(0xFF0f172a),
                      ]
                          : [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
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
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          accentColor.withOpacity(0.15),
                          accentColor.withOpacity(0.08),
                          accentColor.withOpacity(0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
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
                Positioned(
                  left: -50,
                  top: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentColor.withOpacity(0.08),
                          accentColor.withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ),
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
                        child: Icon(
                          icon,
                          color: accentColor,
                          size: 36,
                        ),
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
                                letterSpacing: 0.5,
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
                            if (showComingSoon) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Coming Soon',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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