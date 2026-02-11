import 'package:flutter/material.dart';
import 'FreeTrialTestPage.dart';

class FreeTrialSubjectDetailPage extends StatelessWidget {
  final String title;
  final String subjectId;
  final Color accentColor;
  final IconData icon;
  final VoidCallback toggleTheme;
  final int testCount;

  const FreeTrialSubjectDetailPage({
    super.key,
    required this.title,
    required this.subjectId,
    required this.accentColor,
    required this.icon,
    required this.toggleTheme,
    required this.testCount,
  });

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Premium Feature'),
          ],
        ),
        content: const Text(
          'This test is available in the premium version. Upgrade to unlock all tests!',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
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
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(60),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
                      ),
                      child: Icon(icon, color: accentColor, size: 48),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: accentColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              '$testCount Tests Available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // Tests List
                ...List.generate(testCount, (index) {
                  final isLocked = index > 0; // İlk test (index 0) açık, diğerleri kilitli
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GestureDetector(
                      onTap: () {
                        if (isLocked) {
                          _showLockedDialog(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FreeTrialTestPage(
                                toggleTheme: toggleTheme,
                                testType: subjectId, // ← DEĞİŞTİRİLDİ: 'subject' yerine subjectId
                                testTitle: '$title - Test ${index + 1}',
                                testColor: accentColor,
                                hasTimed: false,
                              ),
                            ),
                          );
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1a1f37) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLocked
                                  ? Colors.grey.withOpacity(0.3)
                                  : accentColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isLocked
                                        ? [Colors.grey, Colors.grey]
                                        : [accentColor.withOpacity(0.8), accentColor],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLocked ? 'Available in Premium' : 'Free Test',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isLocked ? Colors.orange : accentColor,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Test ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isLocked
                                      ? Colors.orange.withOpacity(0.15)
                                      : accentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLocked)
                                      const Icon(Icons.lock, color: Colors.orange, size: 16)
                                    else
                                      const Text(
                                        'Start',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isLocked ? null : Icons.arrow_forward,
                                      color: isLocked ? Colors.orange : accentColor,
                                      size: 16,
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
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}