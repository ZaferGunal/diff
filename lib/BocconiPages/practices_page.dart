import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled5/services/authservice.dart';

import ' practice_test_page.dart';


import '../MyColors.dart';
import '../UserProvider.dart';

class PracticesPage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const PracticesPage({
    super.key,
    required this.toggleTheme,
  });

  void _showReadyDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch, color: MyColors.cyan, size: 28),
            SizedBox(width: 10),
            Text('Are You Ready?', style: TextStyle(fontSize: 22)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MyColors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyColors.cyan.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.quiz, color: MyColors.cyan, size: 20),
                      SizedBox(width: 8),
                      Text('50 Questions',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, color: MyColors.cyan, size: 20),
                      SizedBox(width: 8),
                      Text('75 Minutes',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Timer starts immediately!',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PracticeTestPage(toggleTheme: toggleTheme, testIndex: index),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.cyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start Test', style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('PRACTICES',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1)),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              color: isDark ? Colors.yellow : MyColors.bocco_blue,
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: toggleTheme,
          ),SizedBox(width:21),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final practices = auth.practicesSolved;

          return Container(
            color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                padding: const EdgeInsets.all(60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 40,
                          decoration: BoxDecoration(
                            color: MyColors.cyan,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Select a Practice',
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
                        'Choose a practice test to improve your skills',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Scrollbar(
                        thickness: 8,
                        radius: const Radius.circular(10),
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(right: 20),
                          child: Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: List.generate(4, (index) {
                              bool isSolved = index < practices.length
                                  ? practices[index]
                                  : false;

                              return _buildPracticeCard(
                                context,
                                'Practice ${index + 1}',
                                isDark,
                                isSolved,
                                index,
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPracticeCard(
      BuildContext context,
      String title,
      bool isDark,
      bool isSolved,
      int index,
      ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 1000
        ? 300
        : screenWidth > 600
        ? (screenWidth / 2) - 80
        : screenWidth - 120;

    return GestureDetector(
      onTap: () => _showReadyDialog(context, index + 1),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: cardWidth,
          height: 170,
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: MyColors.cyan.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: MyColors.cyan.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles

              Positioned(
                right: -30,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.cyan.withOpacity(0.05),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MyColors.cyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_document,
                            color: MyColors.cyan,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        Consumer<AuthProvider>(
                          builder: (context, auth, child) {
                            bool solved = auth.practicesSolved[index];
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: solved
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                solved ? Icons.check_circle : Icons.circle_outlined,
                                color: solved ? Colors.green : Colors.grey,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 14,
                              color: isDark ? Colors.white60 : Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '50 Questions',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black45,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: isDark ? Colors.white60 : Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '75 min',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
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
}