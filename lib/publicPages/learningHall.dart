// learning_hall.dart
import 'package:flutter/material.dart';
import '../MyColors.dart';


class LearningHall extends StatefulWidget {
  final VoidCallback? toggleTheme;

  const LearningHall({Key? key, this.toggleTheme}) : super(key: key);

  @override
  State<LearningHall> createState() => _LearningHallState();
}

class _LearningHallState extends State<LearningHall> {
  final List<Map<String, dynamic>> subjects = [
    {
      'title': 'Mathematics',
      'icon': Icons.calculate_outlined,
      'color': MyColors.math,
      'description': 'Master problem-solving strategies',
      'topics': 'Algebra • Geometry • Calculus',
    },
    {
      'title': 'Reading Comprehension',
      'icon': Icons.menu_book_outlined,
      'color': MyColors.reading,
      'description': 'Analyze texts effectively',
      'topics': 'Main Ideas • Inferences • Details',
    },
    {
      'title': 'Logic',
      'icon': Icons.psychology_outlined,
      'color': MyColors.logic,
      'description': 'Solve logical puzzles',
      'topics': 'Patterns • Deduction • Tables',
    },
    {
      'title': 'Critical Thinking',
      'icon': Icons.lightbulb_outline,
      'color': MyColors.criticalThinking,
      'description': 'Evaluate statements critically',
      'topics': 'True/False • Context • Analysis',
    },
    {
      'title': 'Numerical Reasoning',
      'icon': Icons.analytics_outlined,
      'color': MyColors.numericalReasoning,
      'description': 'Work with numbers & charts',
      'topics': 'Percentages • Ratios • Graphs',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TIPS & METHODS',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2),
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
        actions: [SizedBox(width:21),
          if (widget.toggleTheme != null)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.amber : MyColors.bocco_blue,
              ),
              onPressed: widget.toggleTheme,
            ),SizedBox(width:21),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: isDark ? const Color(0xFF0f172a) : Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learning Hall',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Choose your subject to explore',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TipsPage(
                                subject: subject['title'] as String,
                                color: subject['color'] as Color,
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1a1f37) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (subject['color'] as Color).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: (subject['color'] as Color).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  subject['icon'] as IconData,
                                  color: subject['color'] as Color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject['title'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subject['description'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      subject['topics'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: (subject['color'] as Color).withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: subject['color'] as Color,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// tips_page.dart
// ============================================================================

class TipsPage extends StatefulWidget {
  final String subject;
  final Color color;
  final VoidCallback? toggleTheme;

  const TipsPage({
    Key? key,
    required this.subject,
    required this.color,
    this.toggleTheme,
  }) : super(key: key);

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getContentSections() {
    switch (widget.subject) {
      case 'Mathematics':
        return [
          {
            'emoji': '🔍',
            'title': 'Understanding the Problem',
            'subtitle': 'The foundation of every solution',
            'tips': [
              'Read the problem twice - first for overview, second for details',
              'Circle keywords like "total," "difference," "ratio"',
              'Ask yourself: What exactly am I solving for?',
              'Write down what you know vs. what you need to find',
            ],
          },
          {
            'emoji': '✏️',
            'title': 'Visualization is Your Secret Weapon',
            'subtitle': 'A picture is worth a thousand calculations',
            'tips': [
              'Draw diagrams for geometry problems immediately',
              'Use number lines for inequalities',
              'Sketch graphs for function problems',
              'Create tables for word problems with multiple variables',
            ],
          },
          {
            'emoji': '🎯',
            'title': 'Strategic Thinking',
            'subtitle': 'Work smarter, not harder',
            'tips': [
              'Try plugging in the answer choices (work backwards)',
              'Use estimation to eliminate obviously wrong answers',
              'Break complex problems into smaller sub-problems',
              'Look for patterns in sequences or repeated operations',
            ],
          },
          {
            'emoji': '⚡',
            'title': 'Speed Techniques',
            'subtitle': 'Time is precious in exams',
            'tips': [
              'Memorize common formulas beforehand',
              'Practice mental math for quick calculations',
              'Skip problems that stump you - come back later',
              'Use shortcuts: 10% = move decimal, 50% = divide by 2',
            ],
          },
          {
            'emoji': '🚫',
            'title': 'Avoid These Traps',
            'subtitle': 'Common mistakes to watch out for',
            'tips': [
              'Don\'t confuse "of" (multiply) with "more than" (add)',
              'Check if units match (km/h vs m/s)',
              'Read carefully: "at least" vs "at most" vs "exactly"',
              'Watch for negative signs in equations',
            ],
          },
        ];

      case 'Reading Comprehension':
        return [
          {
            'emoji': '📖',
            'title': 'Active Reading Mode',
            'subtitle': 'Engage with the text, don\'t just scan',
            'tips': [
              'Read the questions first to know what to look for',
              'Underline topic sentences (usually first or last)',
              'Mark transition words: however, therefore, in contrast',
              'Make quick mental notes: "Main idea?" "Author\'s opinion?"',
            ],
          },
          {
            'emoji': '🎭',
            'title': 'Understanding Question Types',
            'subtitle': 'Each type needs a different approach',
            'tips': [
              'Main Idea: What is the passage mostly about?',
              'Detail: Find exact info mentioned in text',
              'Inference: What can you logically conclude?',
              'Vocabulary: Use context clues around the word',
            ],
          },
          {
            'emoji': '🔎',
            'title': 'Finding the Right Answer',
            'subtitle': 'Evidence-based decision making',
            'tips': [
              'Go back to the passage - don\'t rely on memory',
              'The correct answer must be supported by text',
              'Wrong answers often mix facts from different parts',
              'Watch for "trap" answers that sound good but aren\'t supported',
            ],
          },
          {
            'emoji': '⚠️',
            'title': 'Red Flags in Answer Choices',
            'subtitle': 'Spot the wrong answers quickly',
            'tips': [
              'Extreme words: "always," "never," "all," "none"',
              'Information not mentioned in the passage',
              'Statements that contradict the text',
              'Answers that are too narrow or too broad',
            ],
          },
          {
            'emoji': '💡',
            'title': 'Pro Tips',
            'subtitle': 'Level up your reading game',
            'tips': [
              'Practice reading diverse topics daily',
              'Time yourself - aim for 10-12 minutes per passage',
              'When stuck between two, reread relevant section',
              'Your job is to find what the AUTHOR says, not what you think',
            ],
          },
        ];

      case 'Logic':
        return [
          {
            'emoji': '🧩',
            'title': 'Organize Your Thinking',
            'subtitle': 'Structure brings clarity',
            'tips': [
              'Draw truth tables for complex statements',
              'Use abbreviations: A = Alice, B = Bob',
              'Create visual diagrams or grids',
              'List all possibilities systematically',
            ],
          },
          {
            'emoji': '🎲',
            'title': 'Test with Assumptions',
            'subtitle': 'Try "what if" scenarios',
            'tips': [
              'Assume one person tells truth, check if others fit',
              'Test each possibility until you find consistency',
              'Eliminate contradictions as you go',
              'Work through process of elimination',
            ],
          },
          {
            'emoji': '🔄',
            'title': 'Logical Operations',
            'subtitle': 'Master the fundamentals',
            'tips': [
              'If-then: p → q means "if p is true, q must be true"',
              'Contrapositive: NOT q → NOT p is equivalent',
              'Negation flips: "All cats" becomes "At least one non-cat"',
              'AND requires both true, OR requires at least one true',
            ],
          },
          {
            'emoji': '🎯',
            'title': 'Venn Diagram Magic',
            'subtitle': 'Visual tool for set problems',
            'tips': [
              'Draw two overlapping circles',
              'Fill intersection first (both categories)',
              'Then fill the exclusive parts',
              'Check: all numbers should add up to total',
            ],
          },
          {
            'emoji': '⚡',
            'title': 'Quick Strategies',
            'subtitle': 'Save time, boost accuracy',
            'tips': [
              'Start with statements that give definite info',
              'Look for contradictions between statements',
              'Use "if this, then that" reasoning chains',
              'Double-check your conclusion makes all statements work',
            ],
          },
        ];

      case 'Critical Thinking':
        return [
          {
            'emoji': '✅',
            'title': 'The Three Outcomes',
            'subtitle': 'Every statement falls into one category',
            'tips': [
              'TRUE: Text explicitly says it OR it logically must be true',
              'FALSE: Text directly contradicts the statement',
              'CANNOT DETERMINE: Not enough info in text to decide',
            ],
          },
          {
            'emoji': '🔍',
            'title': 'Your Systematic Process',
            'subtitle': 'Follow these steps every time',
            'tips': [
              'Step 1: Read passage carefully, note main facts',
              'Step 2: Read the statement you\'re evaluating',
              'Step 3: Go back to passage - does it say this?',
              'Step 4: If not explicit, can it be logically deduced?',
              'Step 5: Choose answer based ONLY on text evidence',
            ],
          },
          {
            'emoji': '🎯',
            'title': 'Spotting TRUE Statements',
            'subtitle': 'When to confidently say TRUE',
            'tips': [
              'Text uses same or equivalent words',
              'Statement is a direct logical consequence',
              'Can be proven using facts given in passage',
              'Multiple parts of text together support it',
            ],
          },
          {
            'emoji': '❌',
            'title': 'Recognizing FALSE Statements',
            'subtitle': 'Direct contradictions',
            'tips': [
              'Statement says opposite of what text says',
              'Numbers, dates, or facts clearly don\'t match',
              'Text says "some" but statement claims "all"',
              'Clear logical impossibility based on passage',
            ],
          },
          {
            'emoji': '❓',
            'title': 'CANNOT DETERMINE Territory',
            'subtitle': 'The tricky middle ground',
            'tips': [
              'Text simply doesn\'t mention the topic',
              'Requires info not provided in passage',
              'Needs assumptions not supported by text',
              'If debating FALSE vs CANNOT - likely CANNOT',
            ],
          },
          {
            'emoji': '⚠️',
            'title': 'Avoid These Traps',
            'subtitle': 'Stay objective and text-focused',
            'tips': [
              'Don\'t use outside knowledge - ONLY the passage',
              'Watch extreme words: "only," "always," "never"',
              'Don\'t add information that isn\'t there',
              'Stay literal - don\'t over-interpret',
            ],
          },
        ];

      case 'Numerical Reasoning':
        return [
          {
            'emoji': '📊',
            'title': 'Core Topics',
            'subtitle': 'What you need to master',
            'tips': [
              'Percentages: increases, decreases, percentage change',
              'Ratios: part-to-part and part-to-whole',
              'Speed = Distance ÷ Time problems',
              'Averages: mean, weighted average',
              'Profit/Loss, Interest, Discount calculations',
            ],
          },
          {
            'emoji': '🧮',
            'title': 'Essential Formulas',
            'subtitle': 'Your calculation toolkit',
            'tips': [
              'Percentage: (Part ÷ Whole) × 100',
              '% Increase: ((New - Old) ÷ Old) × 100',
              'Ratio A:B from total: A = (A/(A+B)) × Total',
              'Average = Sum ÷ Count',
              'Speed = Distance ÷ Time (rearrange as needed)',
            ],
          },
          {
            'emoji': '⚡',
            'title': 'Mental Math Shortcuts',
            'subtitle': 'Calculate faster',
            'tips': [
              '10%: Move decimal left (10% of 450 = 45)',
              '5%: Half of 10% (5% of 450 = 22.5)',
              '25%: Divide by 4 (25% of 80 = 20)',
              '15%: 10% + 5% (15% of 200 = 30)',
              'Multiply by 5: ×10 then ÷2',
            ],
          },
          {
            'emoji': '🎯',
            'title': 'Problem-Solving Strategy',
            'subtitle': 'Systematic approach wins',
            'tips': [
              'Underline what is asked - don\'t solve for wrong thing',
              'List given information clearly',
              'Choose appropriate formula',
              'Check units match (convert if needed)',
              'Estimate answer range before calculating',
              'Verify your answer makes logical sense',
            ],
          },
          {
            'emoji': '🚫',
            'title': 'Common Calculation Errors',
            'subtitle': 'Don\'t fall for these',
            'tips': [
              '❌ Adding percentages of different bases',
              '✅ Calculate each percentage separately',
              '❌ Ratio 3:7 = 3/7',
              '✅ Ratio 3:7 = 3/10 and 7/10',
              '❌ Average speed = (v1+v2)/2',
              '✅ Average speed = Total distance ÷ Total time',
            ],
          },
        ];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sections = _getContentSections();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
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
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.amber : MyColors.bocco_blue,
              ),
              onPressed: widget.toggleTheme,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 12,
          radius: const Radius.circular(6),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color.withOpacity(0.2),
                        widget.color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: widget.color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '💡',
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tips & Strategies',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Master ${widget.subject} with proven techniques',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // Dynamic sections with varied layouts: right, left, center-wide pattern
                ...sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  final layoutType = index % 3; // 0: right, 1: left, 2: center wide

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      children: [
                        // Left spacer for right-aligned cards
                        if (layoutType == 0) const Spacer(),

                        // Small left spacer for center-wide cards
                        if (layoutType == 2) const SizedBox(width: 100),

                        // Main content card
                        Expanded(
                          flex: layoutType == 2 ? 4 : 2,
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1a1f37)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      section['emoji'] as String,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            section['title'] as String,
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            section['subtitle'] as String,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark
                                                  ? Colors.white
                                                  .withOpacity(0.6)
                                                  : Colors.black45,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                ...(section['tips'] as List<String>)
                                    .asMap()
                                    .entries
                                    .map((tipEntry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                          const EdgeInsets.only(top: 6),
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.withOpacity(0.6),
                                                Colors.purple.withOpacity(0.6),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${tipEntry.key + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            tipEntry.value,
                                            style: TextStyle(
                                              fontSize: 16,
                                              height: 1.6,
                                              color: isDark
                                                  ? Colors.white
                                                  .withOpacity(0.9)
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),

                        // Small right spacer for center-wide cards
                        if (layoutType == 2) const SizedBox(width: 100),

                        // Right spacer for left-aligned cards
                        if (layoutType == 1) const Spacer(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}