import 'package:flutter/material.dart';
import 'FreeTrialPracticesPage.dart';
import 'FreeTrialSubjectTestPage.dart';
import 'FreeTrialTipsPage.dart';

class FreeTrialHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const FreeTrialHomePage({super.key, required this.toggleTheme});

  @override
  State<FreeTrialHomePage> createState() => _FreeTrialHomePageState();
}

class _FreeTrialHomePageState extends State<FreeTrialHomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PractiCo - Free Trial',
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
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(60),
            child: Column(
              children: [
                // Hero Section
                Container(
                  padding: const EdgeInsets.all(60),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06b6d4), Color(0xFF0891b2)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06b6d4).withOpacity(0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'FREE TRIAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'PractiCo',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Try our premium test preparation platform for free.\nPractice with exam questions and improve your skills.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFeatureChip('✓ 1 Full Practice Test'),
                          _buildFeatureChip('✓ 5 Subject Tests'),
                          _buildFeatureChip('✓ Tips & Methods'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Upgrade Button
                      ElevatedButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/')
                        ,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF06b6d4),
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.rocket_launch, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Upgrade for More Features',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // Quick Access Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 900 ? 3 : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 32,
                      childAspectRatio: 1.1,
                      children: [
                        _buildCategoryCard(
                          context,
                          'Practice Tests',
                          '1 full test available',
                          Icons.edit_document,
                          const Color(0xFF06b6d4),
                          isDark,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FreeTrialPracticesPage(
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          ),
                        ),
                        _buildCategoryCard(
                          context,
                          'Subject Tests',
                          '5 subjects, 1 test each',
                          Icons.psychology_outlined,
                          const Color(0xFF9333ea),
                          isDark,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FreeTrialSubjectsPage(
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          ),
                        ),
                        _buildCategoryCard(
                          context,
                          'Tips & Methods',
                          'Study strategies',
                          Icons.lightbulb_outline,
                          const Color(0xFFf59e0b),
                          isDark,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LearningHall(
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      bool isDark,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1a1f37) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}