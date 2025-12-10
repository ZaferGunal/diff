import 'package:flutter/material.dart';
import '../MyColors.dart';
import '../services/authservice.dart';
import 'SubjectTestPage.dart';

class SubjectTestViewPage extends StatefulWidget {
  final String title;
  final String subjectType;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? toggleTheme;

  const SubjectTestViewPage({
    super.key,
    required this.title,
    required this.subjectType,
    required this.accentColor,
    required this.icon,
    this.toggleTheme,
  });

  @override
  State<SubjectTestViewPage> createState() => _SubjectTestViewPageState();
}

class _SubjectTestViewPageState extends State<SubjectTestViewPage> {
  bool isLoading = true;
  String? errorMessage;
  Map<int, String?> testTopics = {}; // testIndex -> topic

  // ✅ Her subject için test sayısı
  int get testCount {
    switch (widget.subjectType) {
      case 'Mathematics':
        return 32;
      case 'Reading Comprehension':
        return 20;
      case 'Numerical Reasoning':
        return 6;
      case 'Logic':
        return 6;
      case 'Critical Thinking':
        return 6;
    // Eski formatlar için fallback
      case 'math':
      case 'Math':
        return 32;
      case 'reading':
      case 'Reading':
        return 20;
      case 'numerical_reasoning':
        return 6;
      case 'logic':
        return 6;
      case 'critical_thinking':
        return 6;
      default:
        print('⚠️ Unknown subject type: "${widget.subjectType}"');
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTestTopics();
  }

  Future<void> _loadTestTopics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Tüm testlerin topic'lerini paralel yükle
      final futures = List.generate(testCount, (index) async {
        final testIndex = index + 1;
        try {
          var response = await AuthService().getSubjectTest(
            widget.subjectType,
            testIndex,
          );

          if (response?.data['success'] == true) {
            var test = response!.data['test'];
            final topicFromDB = test['topic'];

            // Topic kontrolü
            if (topicFromDB != null &&
                topicFromDB.toString().trim().isNotEmpty &&
                topicFromDB.toString().trim().toLowerCase() != 'unknown') {
              return MapEntry(testIndex, topicFromDB.toString().trim());
            }
          }
          return MapEntry(testIndex, null);
        } catch (e) {
          print('❌ Test $testIndex topic yüklenemedi: $e');
          return MapEntry(testIndex, null);
        }
      });

      final results = await Future.wait(futures);

      setState(() {
        testTopics = Map.fromEntries(results);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Topics couldn't be loaded: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
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
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: widget.accentColor),
              const SizedBox(height: 20),
              const Text('Loading tests...', style: TextStyle(fontSize: 16)),
            ],
          ),
        )
            : Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(60),
            children: [
              // Header Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.accentColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '$testCount Tests Available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Error message
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Tests Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 2 : 1,
                  crossAxisSpacing: 32,
                  mainAxisSpacing: 24,
                  childAspectRatio: 5.5,
                ),
                itemCount: testCount,
                itemBuilder: (context, index) {
                  final testIndex = index + 1;
                  final topic = testTopics[testIndex];

                  return _buildTestContainer(
                    context,
                    isDark,
                    testIndex,
                    topic, // null olabilir
                    widget.accentColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestContainer(
      BuildContext context,
      bool isDark,
      int testNumber,
      String? topic, // nullable yaptık
      Color color,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectTestPage(
              toggleTheme: widget.toggleTheme ?? () {},
              subjectType: widget.subjectType,
              testIndex: testNumber,
              title: widget.title,
              accentColor: widget.accentColor,
              testNumber: testNumber,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1a1f37) : Colors.white,
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.8),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$testNumber',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Topic göster (varsa)
                        if (topic != null)
                          Text(
                            topic,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? color.withOpacity(0.7) : color.withOpacity(0.7),
                              letterSpacing: 0.8,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const SizedBox.shrink(), // Topic yoksa boş alan

                        if (topic != null) const SizedBox(height: 4),

                        Text(
                          'Test $testNumber',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: isDark ? color : color,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}