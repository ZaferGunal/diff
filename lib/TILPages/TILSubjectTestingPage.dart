import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'TILIDashboard.dart'; // For BentoColors
import '../UserProvider.dart';
import '../services/authservice.dart';
import 'TILSubjectTestResultPage.dart';
import '../widgets/theme_toggle.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TILSubjectTestingPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String subjectType;
  final int testIndex;
  final String title;
  final Color accentColor;
  final int testNumber;

  const TILSubjectTestingPage({
    super.key,
    required this.toggleTheme,
    required this.subjectType,
    required this.testIndex,
    required this.title,
    required this.accentColor,
    required this.testNumber,
  });

  @override
  State<TILSubjectTestingPage> createState() => _TILSubjectTestingPageState();
}

class _TILSubjectTestingPageState extends State<TILSubjectTestingPage> {
  int currentQuestion = 0;
  Map<int, String> answers = {};

  // Test Data
  bool isLoading = true;
  bool isPreloading = false;
  bool testStarted = false;
  String? errorMessage;

  // New TILI Data Structure
  List<Map<String, dynamic>> questions = [];
  List<String> answerKey = []; // Still used for compatibility with result page
  String? topic;

  // Image Loading
  int loadedImages = 0;
  int failedImages = 0;

  // Timer/Stopwatch
  bool showTimerDialog = false;
  bool isTimerMode = true; // true = timer, false = stopwatch
  int timerSeconds = 0;
  int elapsedSeconds = 0;
  Timer? countdownTimer;
  bool timerRunning = false;


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTest();
  }

  Future<void> _loadTest() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      var response = await AuthService().getTILSubjectTest(
        widget.subjectType,
        widget.testIndex,
      );

      if (response?.data['success'] == true) {
        var test = response!.data['test'];

        // TILI text-based schema usually has a 'questions' array
        if (test['questions'] != null) {
          List<dynamic> rawQuestions = List.from(test['questions']);

          // ✅ FIX: Convert options array to Map
          questions = rawQuestions.map((q) {
            Map<String, dynamic> questionData = Map.from(q);

            // Convert options from array of {key, value} to Map
            if (questionData['options'] is List) {
              Map<String, String> optionsMap = {};
              List<dynamic> optionsList = questionData['options'];

              for (var option in optionsList) {
                if (option is Map) {
                  String key = option['key']?.toString() ?? '';
                  String value = option['value']?.toString() ?? '';
                  if (key.isNotEmpty) {
                    optionsMap[key] = value;
                  }
                }
              }
              questionData['options'] = optionsMap;
            }

            return questionData;
          }).toList();

          // ✅ FIX: Prioritize test level answerKey if it exists and has the correct length
          if (test['answerKey'] != null && (test['answerKey'] as List).length == questions.length) {
            answerKey = List<String>.from(test['answerKey']);
          } else {
            // Derive answerKey from questions array
            answerKey = questions.map((q) => q['correctAnswer']?.toString() ?? '').toList();
          }
        } else {
          // Fallback to old schema if necessary
          answerKey = List<String>.from(test['answerKey'] ?? []);

          // If no questions array, we might have questionURLs
          final urls = List<String>.from(test['questionURLs'] ?? []);
          questions = urls.map((url) => {
            'imageUrl': url,
            'questionText': '',
            'options': {'A': '', 'B': '', 'C': '', 'D': '', 'E': ''},
            'correctAnswer': ''
          }).toList();
        }

        final topicFromDB = test['topic'];
        if (topicFromDB != null &&
            topicFromDB.toString().trim().isNotEmpty &&
            topicFromDB.toString().trim().toLowerCase() != 'unknown') {
          topic = topicFromDB.toString().trim();
        } else {
          topic = null;
        }

        if (mounted) {
          setState(() {
            isLoading = false;
          });
          await _preloadImages();
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = response?.data['msg'] ?? "Test not found";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Loading error: $e";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _preloadImages() async {
    if (!mounted) return;

    // Get all image URLs from questions
    final List<String> imageUrls = questions
        .map((q) => q['imageUrl']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    if (imageUrls.isEmpty) {
      setState(() => isPreloading = false);
      return;
    }

    setState(() {
      isPreloading = true;
      loadedImages = 0;
      failedImages = 0;
    });

    try {
      final futures = imageUrls.map((url) async {
        try {
          String imageUrl = url;
          if (imageUrl.contains('github.com') && imageUrl.contains('/blob/')) {
            imageUrl = imageUrl
                .replaceAll('github.com', 'raw.githubusercontent.com')
                .replaceAll('/blob/', '/')
                .replaceAll('?raw=true', '');
          }

          await precacheImage(NetworkImage(imageUrl), context);

          if (mounted) {
            setState(() {
              loadedImages++;
            });
          }
          return true;
        } catch (e) {
          print('Failed to load image: $url - $e');
          if (mounted) {
            setState(() {
              failedImages++;
              loadedImages++;
            });
          }
          return false;
        }
      }).toList();

      await Future.wait(futures);

      if (mounted) {
        setState(() {
          isPreloading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Image preload error: $e";
          isPreloading = false;
        });
      }
    }
  }

  void _startTest() {
    setState(() {
      testStarted = true;
    });
  }

  @override
  void dispose() {
    _clearImageCache();
    _scrollController.dispose();
    _focusNode.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  void _clearImageCache() {
    final imageUrls = questions
        .map((q) => q['imageUrl']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    for (String url in imageUrls) {
      String imageUrl = url;
      if (imageUrl.contains('github.com') && imageUrl.contains('/blob/')) {
        imageUrl = imageUrl
            .replaceAll('github.com', 'raw.githubusercontent.com')
            .replaceAll('/blob/', '/')
            .replaceAll('?raw=true', '');
      }
      imageCache.evict(NetworkImage(imageUrl));
    }
    imageCache.clearLiveImages();
  }

  void _selectOption(int questionNum, String option) {
    setState(() {
      if (answers[questionNum] == option) {
        answers.remove(questionNum);
      } else {
        answers[questionNum] = option;
      }
    });
  }

  void _submitTest() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _clearImageCache();

    // Derive questionURLs for backward compatibility
    final derivedQuestionURLs = questions.map((q) => q['imageUrl']?.toString() ?? '').toList();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TILSubjectTestResultPage(
          userAnswers: answers,
          correctAnswers: answerKey,
          questionURLs: derivedQuestionURLs,
          questions: questions, // Important for topic analysis
          subjectType: widget.subjectType,
          testIndex: widget.testIndex,
          title: widget.title,
          accentColor: widget.accentColor,
          toggleTheme: widget.toggleTheme,
          token: authProvider.token!,
        ),
      ),
    );
  }

  void _startTimer() {
    if (timerRunning) return;

    setState(() {
      timerRunning = true;
      if (!isTimerMode) {
        elapsedSeconds = 0; // Reset stopwatch
      }
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          if (isTimerMode) {
            if (timerSeconds > 0) {
              timerSeconds--;
            } else {
              timer.cancel();
              timerRunning = false;
              _showTimesUpDialog();
            }
          } else {
            elapsedSeconds++;
          }
        });
      }
    });
  }

  void _pauseTimer() {
    countdownTimer?.cancel();
    if (mounted) {
      setState(() => timerRunning = false);
    }
  }

  void _resetTimer() {
    countdownTimer?.cancel();
    if (mounted) {
      setState(() {
        timerRunning = false;
        if (isTimerMode) {
          timerSeconds = 0;
        } else {
          elapsedSeconds = 0;
        }
      });
    }
  }

  void _showTimesUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? BentoColors.darkSurface
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('⏰ Time\'s Up!'),
        content: const Text('Your timer has finished. Would you like to submit the test now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continue Anyway',
              style: TextStyle(
                color: widget.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Submit Test', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showTimerSetupDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int tempMinutes = 30;
    bool tempIsTimerMode = isTimerMode;
    final TextEditingController customController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true, // ✅ Artık dialog dışına tıklayınca kapanabilir
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: isDark ? BentoColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.timer_outlined, color: widget.accentColor),
              const SizedBox(width: 12),
              const Text('Time Manager'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show controls if timer is running
              if (timerRunning) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.accentColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isTimerMode ? Icons.timer : Icons.av_timer,
                            color: widget.accentColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatTime(isTimerMode ? timerSeconds : elapsedSeconds),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: widget.accentColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          _pauseTimer();
                          setDialogState(() {});
                        },
                        icon: const Icon(Icons.pause_rounded, size: 22),
                        label: const Text('Pause', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(140, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (timerSeconds > 0 || elapsedSeconds > 0) ...[
                // Paused state - show resume button
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isTimerMode ? Icons.timer : Icons.av_timer,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatTime(isTimerMode ? timerSeconds : elapsedSeconds),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PAUSED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white38 : Colors.black38,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _startTimer();
                              setDialogState(() {});
                            },
                            icon: const Icon(Icons.play_arrow_rounded, size: 22),
                            label: const Text('Resume', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(130, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              _resetTimer();
                              setDialogState(() {});
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: const Text('Reset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              minimumSize: const Size(110, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Setup state - show mode toggle and duration options
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => tempIsTimerMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: tempIsTimerMode ? widget.accentColor.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: tempIsTimerMode ? widget.accentColor : (isDark ? Colors.white24 : Colors.black12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 20,
                                color: tempIsTimerMode ? widget.accentColor : (isDark ? Colors.white54 : Colors.black54),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Timer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: tempIsTimerMode ? widget.accentColor : (isDark ? Colors.white54 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => tempIsTimerMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !tempIsTimerMode ? widget.accentColor.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !tempIsTimerMode ? widget.accentColor : (isDark ? Colors.white24 : Colors.black12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.av_timer,
                                size: 20,
                                color: !tempIsTimerMode ? widget.accentColor : (isDark ? Colors.white54 : Colors.black54),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Stopwatch',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: !tempIsTimerMode ? widget.accentColor : (isDark ? Colors.white54 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (tempIsTimerMode) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Quick Select',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white38 : Colors.black38,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 10, 15, 30, 45, 60].map((min) {
                      final isSelected = tempMinutes == min && customController.text.isEmpty;
                      return GestureDetector(
                        onTap: () => setDialogState(() {
                          tempMinutes = min;
                          customController.clear();
                        }),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected ? widget.accentColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? widget.accentColor : (isDark ? Colors.white12 : Colors.black12),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$min',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                              Text(
                                'min',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                  color: isSelected ? Colors.white.withOpacity(0.8) : (isDark ? Colors.white38 : Colors.black38),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 2,
                        height: 14,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Or Custom',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white38 : Colors.black38,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: customController.text.isNotEmpty
                            ? widget.accentColor.withOpacity(0.5)
                            : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                        width: customController.text.isNotEmpty ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white24 : Colors.black26,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) {
                              setDialogState(() {});
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Text(
                            'minutes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // ✅ Cancel butonu timer'ı resetliyor
                _resetTimer();
                customController.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!timerRunning && timerSeconds == 0 && elapsedSeconds == 0)
              ElevatedButton(
                onPressed: () {
                  int finalMinutes = tempMinutes;

                  if (tempIsTimerMode && customController.text.isNotEmpty) {
                    final customValue = int.tryParse(customController.text);
                    if (customValue != null && customValue > 0) {
                      finalMinutes = customValue;
                    }
                  }

                  setState(() {
                    isTimerMode = tempIsTimerMode;
                    if (isTimerMode) {
                      timerSeconds = finalMinutes * 60;
                    } else {
                      elapsedSeconds = 0;
                    }
                  });

                  customController.dispose();
                  Navigator.of(dialogContext).pop();
                  _startTimer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? BentoColors.darkSurface
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('⚠️ Abandon Session?'),
        content: const Text(
          'Are you sure you want to exit? Your current progress will not be saved.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Continue Test', style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                _clearImageCache();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Exit Anyway', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _scrollController.animateTo(
          _scrollController.position.pixels + 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollController.animateTo(
          _scrollController.position.pixels - 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (currentQuestion > 0) {
          setState(() => currentQuestion--);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (currentQuestion < questions.length - 1) {
          setState(() => currentQuestion++);
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Widget _buildQuestionSidebar(bool isDark, Color text, bool isMobile) {
    return ListView.builder(
      itemCount: questions.length,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemBuilder: (context, index) {
        final qNum = index + 1;
        final isCurrent = currentQuestion == index;
        final isAnswered = answers.containsKey(qNum);

        return GestureDetector(
          onTap: () {
            setState(() => currentQuestion = index);
            if (isMobile) Navigator.pop(context); // Close drawer on mobile
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            height: 52,
            decoration: BoxDecoration(
              color: isCurrent
                  ? widget.accentColor
                  : (isAnswered ? widget.accentColor.withOpacity(0.1) : Colors.transparent),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? widget.accentColor
                    : (isAnswered ? widget.accentColor.withOpacity(0.3) : text.withOpacity(0.08)),
              ),
            ),
            child: Center(
              child: Text(
                "$qNum",
                style: TextStyle(
                  color: isCurrent ? Colors.white : (isAnswered ? widget.accentColor : text.withOpacity(0.4)),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;

    // 1. LOADING STATE
    if (isLoading) {
      return Scaffold(
        backgroundColor: bg,
        body: _buildFullScreenState(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: widget.accentColor, strokeWidth: 3, strokeCap: StrokeCap.round),
              const SizedBox(height: 24),
              Text("Synchronizing data modules...", style: TextStyle(color: text.withOpacity(0.6), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    // 2. ERROR STATE
    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: bg,
        body: _buildFullScreenState(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
              const SizedBox(height: 24),
              Text(errorMessage!, style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loadTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Reconnect System", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    // 3. PRELOADING STATE
    if (isPreloading) {
      return Scaffold(
        backgroundColor: bg,
        body: _buildFullScreenState(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: questions.isEmpty ? 0 : loadedImages / questions.length,
                      color: widget.accentColor,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    "${(questions.isEmpty ? 0 : (loadedImages / questions.length * 100)).toInt()}%",
                    style: TextStyle(fontWeight: FontWeight.w800, color: text, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Buffering graphics ($loadedImages/${questions.length})",
                style: TextStyle(color: text.withOpacity(0.6), fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      );
    }

    // 4. READY STATE (Start Screen)
    if (!testStarted) {
      return Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            if (isDark) Positioned(top: -100, right: -50, child: _buildBlurCircle(widget.accentColor.withOpacity(0.08), 300)),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 24,
                    child: _buildGlassIconButton(isDark, Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context), text),
                  ),
                  Center(
                    child: Container(
                      width: 480,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: isDark ? BentoColors.darkSurface : BentoColors.lightSurface,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 30)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: widget.accentColor.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.rocket_launch_rounded, size: 48, color: widget.accentColor),
                          ),
                          const SizedBox(height: 32),
                          Text("Ready to Begin?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: text, letterSpacing: -1)),
                          const SizedBox(height: 12),
                          Text("${widget.title} • Module ${widget.testIndex}", style: TextStyle(fontSize: 16, color: text.withOpacity(0.5), fontWeight: FontWeight.w500)),
                          if (topic != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: widget.accentColor.withOpacity(0.2)),
                              ),
                              child: Text(topic!, style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                          ],
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _startTest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 8,
                                shadowColor: widget.accentColor.withOpacity(0.4),
                              ),
                              child: const Text("Start Test", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Back to Tests", style: TextStyle(color: text.withOpacity(0.4), fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 5. TEST INTERFACE
    final answeredCount = answers.length;
    final totalQuestions = questions.length;
    final progress = totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;
    final currentQuestionData = questions.isNotEmpty ? questions[currentQuestion] : {};

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: bg,
        drawer: isMobile ? Drawer(
          backgroundColor: isDark ? BentoColors.darkSurface : BentoColors.lightSurface,
          width: 100,
          child: SafeArea(
            child: _buildQuestionSidebar(isDark, text, isMobile),
          ),
        ) : null,
        appBar: AppBar(
          backgroundColor: isDark ? BentoColors.darkSurface : BentoColors.lightSurface,
          elevation: 0,
          centerTitle: false,
          leading: isMobile 
              ? IconButton(
                  icon: Icon(Icons.menu_rounded, color: text),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                )
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: text),
                  onPressed: _showExitDialog,
                ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile) Text("TESTING SESSION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: text.withOpacity(0.4), letterSpacing: 2)),
              Text(isMobile ? "${widget.title} #${widget.testIndex}" : "${widget.title} Module ${widget.testIndex}", style: TextStyle(fontSize: isMobile ? 14 : 16, color: text, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ],
          ),
          actions: [
            // Timer/Stopwatch Button - compact on mobile
            Padding(
              padding: EdgeInsets.only(right: isMobile ? 4 : 8),
              child: GestureDetector(
                onTap: _showTimerSetupDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: timerRunning
                        ? widget.accentColor.withOpacity(0.15)
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: timerRunning
                          ? widget.accentColor.withOpacity(0.3)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        timerRunning ? (isTimerMode ? Icons.timer : Icons.av_timer) : Icons.timer_outlined,
                        size: isMobile ? 18 : 20,
                        color: timerRunning ? widget.accentColor : text.withOpacity(0.6),
                      ),
                      if (!isMobile || timerRunning) ...[
                        const SizedBox(width: 8),
                        Text(
                          timerRunning ? _formatTime(isTimerMode ? timerSeconds : elapsedSeconds) : 'Timer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: timerRunning ? widget.accentColor : text.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Answer count - hide on mobile
            if (!isMobile)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(color: widget.accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Text("$answeredCount / $totalQuestions Answers", style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ),
            // Theme toggle - hide on mobile
            if (!isMobile)
              SunMoonToggle(
                isDark: isDark,
                onToggle: widget.toggleTheme,
              ),
            SizedBox(width: isMobile ? 4 : 12),
            // Submit button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 10),
              child: ElevatedButton(
                onPressed: _submitTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: widget.accentColor.withOpacity(0.3),
                ),
                child: Text(isMobile ? "✓" : "SUBMIT", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5, fontSize: isMobile ? 16 : 14)),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: widget.accentColor.withOpacity(0.1),
              color: widget.accentColor,
              minHeight: 4,
            ),
          ),
        ),
        body: Row(
          children: [
            // Sidebar - only on desktop
            if (!isMobile)
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: isDark ? BentoColors.darkSurface : BentoColors.lightSurface,
                  border: Border(right: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04))),
                ),
                child: _buildQuestionSidebar(isDark, text, isMobile),
              ),

            // Question Delivery Area
            Expanded(
              child: Container(
                color: isDark ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.03),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(isMobile ? 16 : 40),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(color: text.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  "QUESTION 0${currentQuestion + 1}",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: text.withOpacity(0.6), letterSpacing: 1),
                                ),
                              ),
                              if (topic != null)
                                Text(topic!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.accentColor.withOpacity(0.7))),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Question Display Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Question Image
                              if (currentQuestionData['imageUrl'] != null && currentQuestionData['imageUrl'].toString().isNotEmpty) ...[
                                Center(
                                  child: GestureDetector(
                                    onTap: () => _showImageDialog(currentQuestionData['imageUrl']),
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 700),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: text.withOpacity(0.08)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.06),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              currentQuestionData['imageUrl'],
                                              fit: BoxFit.contain,
                                              loadingBuilder: (ctx, child, progress) {
                                                if (progress == null) return child;
                                                return Container(
                                                  height: 300,
                                                  width: double.infinity,
                                                  color: isDark ? BentoColors.darkSurface : Colors.white,
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      color: widget.accentColor,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              bottom: 16,
                                              right: 16,
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.4),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.zoom_in_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Question Text
                              if (currentQuestionData['questionText'] != null && currentQuestionData['questionText'].toString().isNotEmpty) ...[
                                MathText(
                                  text: currentQuestionData['questionText'].toString(),
                                  style: TextStyle(
                                    fontSize: 17,
                                    height: 1.7,
                                    color: text,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ],
                          ),

                          const SizedBox(height: 48),

                          // Options Display
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final optionsData = currentQuestionData['options'];
                              if (optionsData is Map) {
                                final optionsMap = Map<String, String>.from(optionsData);
                                final sortedOptions = optionsMap.keys.toList()..sort();

                                return Column(
                                  children: sortedOptions.map((opt) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: _buildOptionButton(
                                        opt,
                                        optionsMap[opt].toString(),
                                        text,
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else {
                                return const Text(
                                  'Invalid options format',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 60),

                          // Navigation Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildNavButton(
                                "PREVIOUS",
                                Icons.chevron_left_rounded,
                                currentQuestion > 0 ? () => setState(() => currentQuestion--) : null,
                                text,
                              ),
                              _buildNavButton(
                                "NEXT QUESTION",
                                Icons.chevron_right_rounded,
                                currentQuestion < totalQuestions - 1 ? () => setState(() => currentQuestion++) : null,
                                text,
                                isPrimary: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenState({required Widget child}) {
    return Center(child: child);
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildGlassIconButton(bool isDark, IconData icon, VoidCallback onTap, Color textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String key, String value, Color text) {
    final isSelected = answers[currentQuestion + 1] == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _selectOption(currentQuestion + 1, key),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? widget.accentColor : (isDark ? BentoColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? widget.accentColor : text.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: widget.accentColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : widget.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : widget.accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MathText(
                text: value,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : text,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
      String label,
      IconData icon,
      VoidCallback? onTap,
      Color text, {
        bool isPrimary = false,
      }) {
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.3 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: isPrimary && !disabled ? widget.accentColor.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary && !disabled ? widget.accentColor.withOpacity(0.3) : text.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              if (icon == Icons.chevron_left_rounded)
                Icon(
                  icon,
                  size: 20,
                  color: isPrimary ? widget.accentColor : text,
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isPrimary ? widget.accentColor : text,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              if (icon == Icons.chevron_right_rounded)
                Icon(
                  icon,
                  size: 20,
                  color: isPrimary ? widget.accentColor : text,
                ),
            ],
          ),
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
    final combinedRegex = RegExp(r'\$\$(.*?)\$\$|\$(.*?)\$', dotAll: true);
    final matches = combinedRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (var match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      final mathContent = match.group(1) ?? match.group(2) ?? '';
      final isDisplayMode = match.group(1) != null;

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