import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart'; // Add this import
import 'dart:ui'; // For ImageFilter

import 'package:untitled5/TILPages/TILPracticeExamResultPage.dart';
import '../UserProvider.dart';
import '../services/authservice.dart';
import 'TILIDashboard.dart'; // For BentoColors
import '../widgets/theme_toggle.dart';
import 'package:google_fonts/google_fonts.dart';

class TILPracticeExamTestingPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final int examIndex;
  final String title; // "Practice Exam 1", etc.
  final Color accentColor;

  const TILPracticeExamTestingPage({
    super.key,
    required this.toggleTheme,
    required this.examIndex,
    required this.title,
    required this.accentColor,
  });

  @override
  State<TILPracticeExamTestingPage> createState() => _TILPracticeExamTestingPageState();
}

class _TILPracticeExamTestingPageState extends State<TILPracticeExamTestingPage> {
  // Exam Data
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? examData;
  List<Map<String, dynamic>> questions = []; // Flat list of questions
  List<String> answerKey = [];
  String? examTitle;
  String? readingPassage;

  int loadedImages = 0;
  int failedImages = 0;
  bool isPreloading = false;
  bool testStarted = false;

  // State
  int currentQuestion = 0;
  int currentSectionIndex = 0; // 0: Math, 1: Reading, 2: Physics, 3: Technical
  Map<int, String> answers = {}; // Key: Question Index, Value: 'A', 'B', etc.
  bool isSidebarOpen = true; // Default open as requested

  // Structure for Sidebar
  final List<String> sectionNames = ['Mathematics', 'Reading', 'Physics', 'Technical'];
  final Map<String, List<int>> sectionQuestionIndices = {
     'Mathematics': [],
     'Reading': [],
     'Physics': [],
     'Technical': []
  };

  // Timer
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;
  
  // TILI Section Durations (seconds)
  final Map<String, int> _sectionDurations = {
    'Mathematics': 36 * 60,
    'Reading': 20 * 60,
    'Physics': 22 * 60,
    'Technical': 12 * 60,
  };

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadExam() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await AuthService().getTILPracticeExam(widget.examIndex);

      if (response?.data['success'] == true) {
        var exam = response!.data['exam'];
        examTitle = exam['title'];
        readingPassage = exam['readingPassage'];

        if (exam['questions'] != null) {
          List<dynamic> rawQuestions = List.from(exam['questions']);
          
          List<Map<String, dynamic>> processedQuestions = [];

          // Removed custom sorting logic - trust backend order
          // This ensures index alignment with the answerKey which is ordered by question number

          // Reset section indices
          sectionQuestionIndices.forEach((key, value) => value.clear());

          int index = 0;
          for (var q in rawQuestions) {
             Map<String, dynamic> questionData = Map.from(q);

             if (questionData['options'] is List) {
                Map<String, String> optionsMap = {};
                for (var opt in questionData['options']) {
                   if (opt is Map) {
                      optionsMap[opt['key']] = opt['value'];
                   }
                }
                questionData['options'] = optionsMap;
             }
             processedQuestions.add(questionData);

             // Populate section indices
             String subj = (questionData['subject'] ?? '').toString().toLowerCase();
             if (subj.contains('math')) sectionQuestionIndices['Mathematics']!.add(index);
             else if (subj.contains('reading')) sectionQuestionIndices['Reading']!.add(index);
             else if (subj.contains('physic')) sectionQuestionIndices['Physics']!.add(index);
             else sectionQuestionIndices['Technical']!.add(index);
             
             index++;
          }

          questions = processedQuestions;

          // ✅ FIX: Prioritize exam-level answerKey if it exists and has correct length
          if (exam['answerKey'] != null && (exam['answerKey'] as List).length == questions.length) {
            answerKey = List<String>.from(exam['answerKey']);
            print('📋 Using exam-level answerKey: ${answerKey.length} items');
          } else {
            // Derive answerKey from questions array's correctAnswer field
            answerKey = questions.map((q) => q['correctAnswer']?.toString() ?? '').toList();
            print('📋 Using question-level correctAnswer: ${answerKey.length} items');
          }
          print('📋 AnswerKey sample: ${answerKey.take(5).toList()}');
          
          if (mounted) {
             await _preloadImages(questions);
          }

          setState(() {
            isLoading = false;
            // Set initial timer for the first section (Mathematics)
            _secondsRemaining = _sectionDurations['Mathematics']!; 
          });
        }
      } else {
        setState(() {
          errorMessage = response?.data['msg'] ?? "Exam not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading exam: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _preloadImages(List<Map<String, dynamic>> qs) async {
    setState(() {
      isPreloading = true;
      loadedImages = 0;
      failedImages = 0;
    });

    List<String> urls = qs
        .map((q) => q['imageUrl']?.toString() ?? '')
        .where((u) => u.isNotEmpty)
        .toList();

    if (urls.isEmpty) {
      setState(() => isPreloading = false);
      return;
    }

    final futures = urls.map((url) async {
      try {
        await precacheImage(NetworkImage(url), context);
        if (mounted) setState(() => loadedImages++);
      } catch (e) {
        print("Image load error: $url");
        if (mounted) setState(() => failedImages++);
      }
    }).toList();

    await Future.wait(futures);
    if (mounted) setState(() => isPreloading = false);
  }

  void _startExam() {
    setState(() {
      testStarted = true;
      _isTimerRunning = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            // Section Time Expired!
            if (currentSectionIndex < sectionNames.length - 1) {
               // Auto-move to next section
               _autoProceedToNextSection();
            } else {
               // Last section finished
               _timer?.cancel();
               _isTimerRunning = false;
               _submitExam(); 
            }
          }
        });
      }
    });
  }

  void _autoProceedToNextSection() {
    setState(() {
      currentSectionIndex++;
      // Reset timer for new section
      String nextSectionName = sectionNames[currentSectionIndex];
      _secondsRemaining = _sectionDurations[nextSectionName] ?? 600; 
      
      // Find first question of next section
      List<int> nextIndices = sectionQuestionIndices[nextSectionName] ?? [];
      if (nextIndices.isNotEmpty) {
        currentQuestion = nextIndices.first;
      }
    });
    _scrollController.jumpTo(0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Time expired! Automatically moved to ${sectionNames[currentSectionIndex]}."),
        backgroundColor: widget.accentColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _selectOption(int qIndex, String key) {
    setState(() {
      if (answers[qIndex] == key) {
        answers.remove(qIndex);
      } else {
        answers[qIndex] = key;
      }
    });
  }

  void _submitExam() {
    _timer?.cancel();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Create sections structure for result page
    List<Map<String, dynamic>> resultSections = [];
    sectionQuestionIndices.forEach((key, indices) {
       if (indices.isNotEmpty) {
          resultSections.add({
             'name': key,
             'startIndex': indices.first,
             'endIndex': indices.last,
          });
       }
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => 
      TILPracticeExamResultPage(
        userAnswers: answers,
        correctAnswers: answerKey,
        questions: questions,
        examIndex: widget.examIndex,
        title: widget.title,
        accentColor: widget.accentColor,
        toggleTheme: widget.toggleTheme,
        token: authProvider.token!,
        sections: resultSections,
      )
    ));
  }
  
  void _showFinishExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Finish Exam?"),
        content: const Text("Are you sure you want to finish and exit? Your current answers will be submitted and you will see your results."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitExam();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Finish & View Results", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Submit Exam?"),
        content: const Text("Are you sure you want to submit your exam? You cannot go back once you submit."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitExam();
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.accentColor),
            child: const Text("Submit Exam", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _getSectionForQuestion(int index) {
      String sectionName = 'Unknown';
      Color color = Colors.grey;
      String key = 'unknown';

      sectionQuestionIndices.forEach((k, indices) {
         if (indices.contains(index)) {
            sectionName = k;
            if (k == 'Mathematics') { color = Colors.blue; key = 'math'; }
            else if (k == 'Reading') { color = Colors.orange; key = 'reading'; }
            else if (k == 'Physics') { color = Colors.purple; key = 'physics'; }
            else { color = Colors.teal; key = 'tech'; }
         }
      });
      return {'name': sectionName, 'color': color, 'key': key};
  }
  
  // Navigation Logic
  bool _canNavigateTo(int index) {
     String targetSection = _getSectionForQuestion(index)['name'];
     String currentSection = sectionNames[currentSectionIndex];
     return targetSection == currentSection;
  }
  
  void _nextSection() {
     if (currentSectionIndex < sectionNames.length - 1) {
        showDialog(
           context: context, 
           builder: (ctx) => AlertDialog(
              title: const Text("Finish Section?"),
              content: const Text("You are about to finish this section and move to the next. You CANNOT return to this section once you proceed."),
              actions: [
                 TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                 ElevatedButton(
                    onPressed: () {
                       Navigator.pop(ctx);
                       setState(() {
                          currentSectionIndex++;

                           // Reset timer for new section
                           String nextSectionName = sectionNames[currentSectionIndex];
                           _secondsRemaining = _sectionDurations[nextSectionName] ?? 600;
                          // Find first question of next section
                          List<int> nextIndices = sectionQuestionIndices[nextSectionName] ?? [];
                          if (nextIndices.isNotEmpty) {
                             currentQuestion = nextIndices.first;
                          }
                       });
                       _scrollController.jumpTo(0);
                    }, 
                    child: const Text("Confirm & Proceed")
                 )
              ],
           )
        );
     } else {
        _submitExam();
     }
  }

  void _showImageDialog(String imageUrl) {
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
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.black87),
                ),
              ),
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
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
    
    // Premium Design Tokens
    final bg = isDark ? const Color(0xFF0F1020) : BentoColors.lightBg;
    final sidebarBg = isDark ? const Color(0xFF16182D) : Colors.white;
    final surface = isDark ? const Color(0xFF1F223C) : BentoColors.lightSurface;
    final accent = widget.accentColor;
    final text = isDark ? Colors.white : BentoColors.lightTextPrimary;
    final textSecondary = isDark ? const Color(0xFF8A8D9F) : BentoColors.lightTextSecondary;
    final borderColor = isDark ? const Color(0xFF1F223C) : Colors.black.withOpacity(0.05);

    if (isLoading) {
       return Scaffold(
          backgroundColor: bg,
          body: Center(child: CircularProgressIndicator(color: widget.accentColor)),
       );
    }

    if (errorMessage != null) {
       return Scaffold(
          backgroundColor: bg,
          body: Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red))),
       );
    }
    
    if (isPreloading) {
       return Scaffold(
          backgroundColor: bg,
          body: Center(
             child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   CircularProgressIndicator(color: widget.accentColor),
                   const SizedBox(height: 20),
                   Text("Loading resources... $loadedImages / ${questions.length}", style: TextStyle(color: text)),
                ],
             ),
          ),
       );
    }

    if (!testStarted) {
       return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            title: Text(widget.title), 
            backgroundColor: surface,
            elevation: 0,
          ),
          body: Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.rocket_launch_rounded, size: 80, color: accent.withOpacity(0.5)),
                 const SizedBox(height: 24),
                 Text(
                   "Ready to start your exam?",
                   style: TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.bold),
                 ),
                 const SizedBox(height: 32),
                 ElevatedButton(
                    onPressed: _startExam,
                    style: ElevatedButton.styleFrom(
                       backgroundColor: accent,
                       padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                       elevation: 10,
                       shadowColor: accent.withOpacity(0.5),
                    ),
                    child: const Text("Launch Exam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                 ),
               ],
             ),
          ),
       );
    }

    final q = questions[currentQuestion];
    final sectionInfo = _getSectionForQuestion(currentQuestion);
    
    // Reading Passage Logic
    bool showReadingPassage = false;
    if (sectionInfo['key'] == 'reading') {
        List<int> readingIndices = sectionQuestionIndices['Reading'] ?? [];
        if (readingIndices.isNotEmpty) {
           int relativeIndex = readingIndices.indexOf(currentQuestion);
           if (relativeIndex >= 0 && relativeIndex < 5) {
              showReadingPassage = true;
           }
        }
    }
    
    // Determine Nav Button State
    String currentSectionName = sectionNames[currentSectionIndex];
    List<int> indices = sectionQuestionIndices[currentSectionName] ?? [];
    bool isLastQuestionInSection = indices.isNotEmpty && indices.last == currentQuestion;
    bool isFirstQuestionInSection = indices.isNotEmpty && indices.first == currentQuestion;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: isMobile ? Drawer(
        backgroundColor: sidebarBg,
        child: SafeArea(child: _buildSidebar(isDark, sidebarBg, surface, accent, text, textSecondary, borderColor)),
      ) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           // Sidebar only on desktop
           if (!isMobile)
             AnimatedContainer(
               duration: const Duration(milliseconds: 300),
               width: isSidebarOpen ? 300 : 0, 
               child: isSidebarOpen ? _buildSidebar(isDark, sidebarBg, surface, accent, text, textSecondary, borderColor) : const SizedBox.shrink(),
             ),


           // Main Content Area
           Expanded(
              child: Column(
                children: [
                  _buildMainHeader(sectionInfo['name'], text, textSecondary, isMobile),

                  
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 40, 0, isMobile ? 16 : 40, 40),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Question Title & Status
                              Row(
                                children: [
                                  Text(
                                    "Question ${(currentQuestion % indices.length) + 1}".toUpperCase(),
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.menu_rounded, color: textSecondary),
                                    onPressed: () {
                                      if (isMobile) {
                                        _scaffoldKey.currentState?.openDrawer();
                                      } else {
                                        setState(() => isSidebarOpen = !isSidebarOpen);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              if (showReadingPassage && readingPassage != null)
                                _buildReadingPassageModule(surface, accent, text),

                              if (q['imageUrl'] != null && q['imageUrl'].toString().isNotEmpty)
                                _buildImageModule(q['imageUrl'], borderColor),

                              const SizedBox(height: 24),
                              
                              // The Question Text
                              MathText(
                                text: q['questionText'] ?? "",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: text,
                                  height: 1.5,
                                ),
                              ),
                              
                              const SizedBox(height: 48),

                              // Option Cards
                              ...['A', 'B', 'C', 'D', 'E'].map((opt) {
                                if (!q['options'].containsKey(opt)) return const SizedBox.shrink();
                                final isSelected = answers[currentQuestion] == opt;
                                return _buildOptionCard(opt, q['options'][opt], isSelected, surface, accent, text, borderColor);
                              }).toList(),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom Nav
                  _buildBottomNav(isFirstQuestionInSection, isLastQuestionInSection, surface, text, accent, isMobile),
                ],
              ),
           ),
        ],
      ),
    );
  }

  Widget _buildReadingPassageModule(Color surface, Color accent, Color text) {
     return Container(
        height: 300,
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
           color: surface,
           borderRadius: BorderRadius.circular(24),
           border: Border.all(color: accent.withOpacity(0.2)),
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Row(
                 children: [
                    Icon(Icons.menu_book_rounded, color: accent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                       "Reading Passage",
                       style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                 ],
              ),
              const SizedBox(height: 16),
              Expanded(
                 child: SingleChildScrollView(
                    child: SelectableText(
                       readingPassage!,
                       style: TextStyle(fontSize: 17, height: 1.6, color: text),
                    ),
                 ),
              ),
           ],
        ),
     );
  }

  Widget _buildImageModule(String url, Color borderColor) {
    return Padding(
       padding: const EdgeInsets.only(bottom: 32),
       child: GestureDetector(
          onTap: () => _showImageDialog(url),
          child: ClipRRect(
             borderRadius: BorderRadius.circular(24),
             child: Container(
                decoration: BoxDecoration(border: Border.all(color: borderColor)),
                child: Image.network(url, fit: BoxFit.contain),
             ),
          ),
       ),
    );
  }


  // --- NEW UI COMPONENTS ---

  Widget _buildSidebar(bool isDark, Color bg, Color surface, Color accent, Color text, Color textSecondary, Color borderColor) {
    return Column(
      children: [
        _buildSidebarHeader(isDark, text),
        _buildTimeCard(accent, surface, text, textSecondary),
        Expanded(
          child: _buildQuestionGrid(isDark, surface, accent, text, textSecondary, borderColor),
        ),
        _buildSidebarFooter(isDark, borderColor),
      ],
    );
  }

  Widget _buildSidebarHeader(bool isDark, Color text) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
        Image.asset(
              'assets/soleLogo.png',
              width: 39,
              height: 39,
            ),
          
          const SizedBox(width: 12),
          Text(
  "PractiCo",
  style: GoogleFonts.jost(
    color: text,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  ),
)
       
        ],
      ),
    );
  }

  Widget _buildTimeCard(Color accent, Color surface, Color text, Color textSecondary) {
    double progress = 1.0;
    String currentSectionName = sectionNames[currentSectionIndex];
    int totalSeconds = _sectionDurations[currentSectionName] ?? 600;
    if (totalSeconds > 0) {
      progress = _secondsRemaining / totalSeconds;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            "SECTION TIME",
            style: TextStyle(
              color: textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
            style: TextStyle(
              color: text,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: accent.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionGrid(bool isDark, Color surface, Color accent, Color text, Color textSecondary, Color borderColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: sectionNames.asMap().entries.map((entry) {
        String name = entry.value;
        int idx = entry.key;
        List<int> qIndices = sectionQuestionIndices[name] ?? [];
        if (qIndices.isEmpty) return const SizedBox.shrink();

        bool isCurrentSection = idx == currentSectionIndex;
        bool isLocked = !isCurrentSection;
        bool isPast = idx < currentSectionIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      color: isCurrentSection ? text : textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (isCurrentSection)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${answers.keys.where((k) => qIndices.contains(k)).length}/${qIndices.length}",
                        style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )
                  else if (isPast)
                    Icon(Icons.check_circle_rounded, color: accent.withOpacity(0.5), size: 16)
                  else
                    Icon(Icons.lock_outline_rounded, color: textSecondary.withOpacity(0.3), size: 16),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: qIndices.map((qIdx) {
                bool isSelected = qIdx == currentQuestion;
                bool isAnswered = answers.containsKey(qIdx);
                int relativeNum = qIndices.indexOf(qIdx) + 1;

                Color cardBg = surface;
                Color txtColor = isDark ? Colors.white70 : Colors.black87;
                BoxBorder? border = Border.all(color: borderColor, width: 1);

                if (isSelected) {
                  cardBg = accent;
                  txtColor = Colors.white;
                  border = null;
                } else if (isAnswered) {
                  cardBg = accent.withOpacity(0.1);
                  txtColor = accent;
                  border = Border.all(color: accent.withOpacity(0.3));
                }

                return GestureDetector(
                  onTap: isLocked ? null : () => setState(() => currentQuestion = qIdx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: border,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$relativeNum",
                      style: TextStyle(
                        color: txtColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSidebarFooter(bool isDark, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Night Mode",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isDark,
                  onChanged: (v) => widget.toggleTheme(),
                  activeColor: widget.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showFinishExitDialog(),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text("Finish & Exit", style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader(String sectionName, Color text, Color textSecondary, bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 40, 24, isMobile ? 16 : 40, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                sectionName,
                style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Icon(Icons.chevron_right_rounded, color: textSecondary, size: 16),
              const Text(
                "Active Test",
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildOptionCard(String key, String value, bool isSelected, Color surface, Color accent, Color text, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _selectOption(currentQuestion, key),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? accent.withOpacity(0.05) : surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? accent : borderColor,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(color: accent.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
            ] : [],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? accent : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  key,
                  style: TextStyle(
                    color: isSelected ? Colors.white : text.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MathText(
                  text: value,
                  style: TextStyle(
                    color: isSelected ? Colors.white : text,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: accent, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isFirst, bool isLast, Color surface, Color text, Color accent, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: surface.withOpacity(0.5),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          // Previous Button
          if (!isFirst)
            _buildNavButton(
              onPressed: () => setState(() => currentQuestion--),
              label: isMobile ? "" : "Previous",
              icon: Icons.arrow_back_rounded,
              isSecondary: true,
              surface: surface,
              text: text,
              accent: accent,
              isMobile: isMobile,
            )
          else
            const Spacer(),

          const Spacer(),
          
          // Page Indicator dots - hide on mobile
          if (!isMobile)
            Row(
              children: List.generate(4, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == currentSectionIndex ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color: index == currentSectionIndex ? accent : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),

          const Spacer(),

          // Next Button
          _buildNavButton(
            onPressed: () {
              if (isLast) {
                if (currentSectionIndex == sectionNames.length - 1) {
                  _showSubmitConfirmDialog();
                } else {
                  _nextSection();
                }
              } else {
                setState(() => currentQuestion++);
              }
            },
            label: isLast 
                ? (currentSectionIndex == sectionNames.length - 1 ? (isMobile ? "Submit" : "Submit Exam") : (isMobile ? "Next" : "Next Section")) 
                : (isMobile ? "Next" : "Next Question"),
            icon: Icons.arrow_forward_rounded,
            isSecondary: false,
            surface: surface,
            text: text,
            accent: accent,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required bool isSecondary,
    required Color surface,
    required Color text,
    required Color accent,
    bool isMobile = false,
  }) {
    if (isSecondary) {
      // On mobile with empty label, show just icon
      if (isMobile && label.isEmpty) {
        return IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 24, color: text),
          style: IconButton.styleFrom(
            backgroundColor: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 12 : 16),
          foregroundColor: text,
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16)),
        label: Icon(icon, size: isMobile ? 16 : 18),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: isMobile ? 12 : 16),
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

}

// MathText Widget
class MathText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const MathText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    // Regex to identify LaTeX math expressions ($...$ or $$...$$)
    final combinedRegex = RegExp(r'\$\$(.*?)\$\$|\$(.*?)\$', dotAll: true);
    final matches = combinedRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (var match in matches) {
      // Add text before the math
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      // Extract math content
      final mathContent = match.group(1) ?? match.group(2) ?? '';
      final isDisplayMode = match.group(1) != null; // $$...$$ is display mode

      // Add math widget
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        baseline: TextBaseline.alphabetic,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDisplayMode ? 8 : 3,
            vertical: isDisplayMode ? 6 : 0,
          ),
          child: Math.tex(
            mathContent.trim(),
            mathStyle: isDisplayMode ? MathStyle.display : MathStyle.text,
            textStyle: style,
            textScaleFactor: 1.0,
          ),
        ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
}