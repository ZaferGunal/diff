import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../MyColors.dart';
import '../UserProvider.dart';
import '../services/authservice.dart';
import 'TempPracticeResultPage.dart';

// MAIN TEST PAGE
class PracticeTestPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final int testIndex; // 1, 2, 3, 4 (database'deki index)

  const PracticeTestPage({
    super.key,
    required this.toggleTheme,
    required this.testIndex,
  });

  @override
  State<PracticeTestPage> createState() => _PracticeTestPageState();
}

class _PracticeTestPageState extends State<PracticeTestPage> {
  int currentQuestion = 0;
  Map<int, String> answers = {};
  Timer? timer;
  int timeRemaining = 75 * 60;
  bool isImageExpanded = false;

  // Database'den gelecek veriler
  bool isLoading = true;
  String? errorMessage;
  List<String> questionURLs = [];
  List<String> answerKey = [];
  String testTitle = "";

  // ✅ Resim yükleme durumu
  bool isLoadingImages = false;
  int loadedImagesCount = 0;
  List<ImageProvider> preloadedImages = [];

  // ✅ Test submit durumu
  bool isSubmitting = false;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTest();
  }

  Future<void> _loadTest() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      var response = await AuthService().getPracticeTest(widget.testIndex);

      if (!mounted) return;

      if (response?.data['success'] == true) {
        setState(() {
          var test = response!.data['test'];
          testTitle = test['title'];
          answerKey = List<String>.from(test['answerKey']);
          questionURLs = List<String>.from(test['questionURLs']);
          isLoading = false;
        });

        // ✅ Test verisi geldi, şimdi resimleri yükle
        await _preloadAllImages();

      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = response?.data['msg'] ?? "Test bulunamadı";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Yükleme hatası: $e";
        isLoading = false;
      });
    }
  }

  // ✅ Tüm resimleri PARALEL olarak önceden yükle
  Future<void> _preloadAllImages() async {
    if (!mounted) return;

    setState(() {
      isLoadingImages = true;
      loadedImagesCount = 0;
    });

    print('🖼️ [PRELOAD] Starting to preload ${questionURLs.length} images in parallel...');

    try {
      final futures = <Future<void>>[];

      for (int i = 0; i < questionURLs.length; i++) {
        final imageProvider = NetworkImage(questionURLs[i]);
        preloadedImages.add(imageProvider);

        futures.add(
            precacheImage(imageProvider, context).then((_) {
              if (mounted) {
                setState(() {
                  loadedImagesCount++;
                });
              }
              print('✅ [PRELOAD] Loaded image $loadedImagesCount/${questionURLs.length}');
            }).catchError((error) {
              print('⚠️ [PRELOAD] Error loading image $i: $error');
              if (mounted) {
                setState(() {
                  loadedImagesCount++;
                });
              }
            })
        );
      }

      await Future.wait(futures);

      print('🎉 [PRELOAD] All images loaded successfully!');

      if (mounted) {
        setState(() {
          isLoadingImages = false;
        });

        // ✅ Resimler yüklendi, timer'ı başlat
        _startTimer();
      }

    } catch (e) {
      print('❌ [PRELOAD] Error loading test data: $e');
      if (mounted) {
        setState(() {
          errorMessage = "Error occurred while loading: $e";
          isLoadingImages = false;
        });
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _clearImageCache();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearImageCache() {
    if (preloadedImages.isEmpty) return;

    print('🗑️ [CACHE] Clearing ${preloadedImages.length} images from cache...');

    for (var imageProvider in preloadedImages) {
      try {
        imageProvider.evict();
      } catch (e) {
        print('⚠️ [CACHE] Error evicting image: $e');
      }
    }

    preloadedImages.clear();
    print('✅ [CACHE] Cache cleared - Memory freed!');
  }

  void _startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (timeRemaining > 0) {
          timeRemaining--;
        } else {
          timer.cancel();
          _submitTest();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _selectOption(int questionNum, String option) {
    if (!mounted) return;

    setState(() {
      if (answers[questionNum] == option) {
        answers.remove(questionNum);
      } else {
        answers[questionNum] = option;
      }
    });
  }

  void _submitTest() async {
    if (isSubmitting || !mounted) {
      print('⚠️ [SUBMIT] Already submitting or widget unmounted');
      return;
    }

    print('🚀 [SUBMIT] Starting test submission...');

    setState(() {
      isSubmitting = true;
    });

    timer?.cancel();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      // Hesaplamaları yap
      int correctCount = 0;
      int wrongCount = 0;
      int emptyCount = 0;

      final totalQuestions = answerKey.length;

      for (int i = 1; i <= totalQuestions; i++) {
        if (!answers.containsKey(i)) {
          emptyCount++;
        } else if (answers[i] == answerKey[i - 1]) {
          correctCount++;
        } else {
          wrongCount++;
        }
      }

      double score = correctCount - (wrongCount / 4);
      score = score < 0 ? 0 : score;

      print('📊 [SUBMIT] Calculated: C=$correctCount, W=$wrongCount, E=$emptyCount, Score=$score');

      // Practice solved güncelle
      print('💾 [SUBMIT] Updating practice solved...');
      await auth.updatePracticeSolved(widget.testIndex - 1, true);
      print('✅ [SUBMIT] Practice solved updated');

      // Test results kaydet
      print('💾 [SUBMIT] Saving test results...');
      await auth.updatePracticeTestResult(
        testNumber: widget.testIndex,
        correctAnswers: correctCount.toDouble(),
        wrongAnswers: wrongCount.toDouble(),
        emptyAnswers: emptyCount.toDouble(),
        score: score,
      );
      print('✅ [SUBMIT] Test results saved');

      if (!mounted) {
        print('⚠️ [SUBMIT] Widget unmounted after save');
        return;
      }

      print('🚀 [SUBMIT] Navigating to results...');

      // ✅ Results sayfasına git - push kullan (pop ile geri dönebilsin)
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TestResultsPage(
            userAnswers: answers,
            correctAnswers: answerKey,
            questionURLs: questionURLs,
            testIndex: widget.testIndex,
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );

      print('✅ [SUBMIT] Navigation completed!');

    } catch (e) {
      print('❌ [SUBMIT] Error: $e');

      if (mounted) {
        setState(() {
          isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving results: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Exit Test?'),
        content: const Text(
          'Are you sure you want to exit the test? Your progress will be lost and you\'ll need to start over!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              timer?.cancel();
              Navigator.of(context).pop(); // Dialog
              Navigator.of(context).pop(); // Test page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.cyan,
            ),
            child: const Text('Exit Test'),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl, int imageIndex) {
    const double dialogSizeRatio = 0.92;

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
                child: Container(
                  color: Colors.black87,
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: MediaQuery.of(context).size.width * dialogSizeRatio,
                    height: MediaQuery.of(context).size.height * dialogSizeRatio,
                    color: Colors.transparent,
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image(
                        image: preloadedImages[imageIndex],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.white, size: 30),
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
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollController.jumpTo(0);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Loading states
    if (isLoading || isLoadingImages) {
      return Scaffold(
        appBar: AppBar(
          title: Text('PRACTICE TEST ${widget.testIndex}'),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: MyColors.cyan),
              const SizedBox(height: 20),
              if (isLoading)
                const Text('Test loading...', style: TextStyle(fontSize: 18))
              else if (isLoadingImages)
                Column(
                  children: [
                    const Text(
                      'Loading practice...',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: questionURLs.isEmpty ? 0 : loadedImagesCount / questionURLs.length,
                        child: Container(
                          decoration: BoxDecoration(
                            color: MyColors.cyan,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$loadedImagesCount / ${questionURLs.length}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('PRACTICE TEST ${widget.testIndex}'),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loadTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.cyan,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Submitting state
    if (isSubmitting) {
      return Scaffold(
        appBar: AppBar(
          title: Text('PRACTICE TEST ${widget.testIndex}'),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: MyColors.cyan),
              const SizedBox(height: 20),
              const Text(
                'Saving results...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    // Main test UI
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(testTitle.toUpperCase()),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.yellow : MyColors.bocco_blue,
              ),
              onPressed: widget.toggleTheme,
              tooltip: 'Toggle Theme',
            ),
            const SizedBox(width: 21),
            Container(
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: _showExitDialog,
                icon: const Icon(Icons.exit_to_app, color: MyColors.cyan),
                label: const Text(
                  'Exit Test',
                  style: TextStyle(color: MyColors.cyan, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 13)
          ],
        ),
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 280,
              color: isDark ? const Color(0xFF0f172a) : Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Timer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [MyColors.cyan, MyColors.bocco_blue],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.cyan.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _formattedTime,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'QUESTIONS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Question grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: questionURLs.length,
                      itemBuilder: (context, index) {
                        final questionNum = index + 1;
                        final isAnswered = answers.containsKey(questionNum);
                        final isCurrent = currentQuestion == index;

                        return GestureDetector(
                          onTap: () {
                            if (mounted) {
                              setState(() => currentQuestion = index);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isAnswered
                                  ? const LinearGradient(
                                colors: [MyColors.cyan, MyColors.bocco_blue],
                              )
                                  : null,
                              color: isAnswered
                                  ? null
                                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCurrent
                                    ? MyColors.cyan
                                    : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
                                width: isCurrent ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$questionNum',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isAnswered ? Colors.white : null,
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
            // Test content
            Expanded(
              child: Container(
                color: isDark ? const Color(0xFF0a0e27).withOpacity(0.5) : const Color(0xFFe8edf2),
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: isDark ? MyColors.white : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
                          ),
                        ),
                        child: RawScrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 8,
                          radius: const Radius.circular(4),
                          thumbColor: Colors.grey[700],
                          trackColor: Colors.grey[300],
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${currentQuestion + 1} of ${questionURLs.length}',
                                    style: const TextStyle(
                                      color: MyColors.cyan,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Image
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => _showImageDialog(
                                        questionURLs[currentQuestion],
                                        currentQuestion,
                                      ),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: ConstrainedBox(
                                                constraints: const BoxConstraints(
                                                  maxHeight: 500,
                                                  maxWidth: 700,
                                                ),
                                                child: Image(
                                                  image: preloadedImages[currentQuestion],
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      height: 300,
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.error_outline,
                                                          size: 48,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.zoom_in, color: Colors.white, size: 18),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Click to expand',
                                                      style: TextStyle(color: Colors.white, fontSize: 12),
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
                                  const SizedBox(height: 30),
                                  // Options
                                  ...['A', 'B', 'C', 'D', 'E'].map((option) {
                                    final isSelected = answers[currentQuestion + 1] == option;
                                    return _buildOption(option, isSelected, isDark);
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Navigation buttons
                    Row(
                      children: [
                        if (currentQuestion > 0)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (mounted) {
                                  setState(() => currentQuestion--);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                              child: const Text('← Previous'),
                            ),
                          ),
                        if (currentQuestion > 0) const SizedBox(width: 15),
                        Expanded(
                          child: currentQuestion < questionURLs.length - 1
                              ? Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [MyColors.cyan, MyColors.bocco_blue],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (mounted) {
                                  setState(() => currentQuestion++);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                              child: const Text('Next →'),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [MyColors.cyan, MyColors.bocco_blue],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submitTest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                              child: const Text('Submit Test'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String option, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => _selectOption(currentQuestion + 1, option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              MyColors.cyan.withOpacity(0.3),
              MyColors.bocco_blue.withOpacity(0.3),
            ],
          )
              : null,
          color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MyColors.cyan : MyColors.cyan,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: option,
              groupValue: answers[currentQuestion + 1],
              onChanged: (value) => _selectOption(currentQuestion + 1, option),
              activeColor: MyColors.cyan,
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return MyColors.cyan;
                }
                return MyColors.optionColor;
              }),
            ),
            const SizedBox(width: 10),
            Text(
              'Option $option',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}