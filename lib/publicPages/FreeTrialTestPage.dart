import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'FreeTrialResultsPage.dart';
import 'TestData.dart';

class FreeTrialTestPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String testType;
  final String testTitle;
  final Color testColor;
  final bool hasTimed;

  const FreeTrialTestPage({
    super.key,
    required this.toggleTheme,
    required this.testType,
    required this.testTitle,
    required this.testColor,
    required this.hasTimed,
  });

  @override
  State<FreeTrialTestPage> createState() => _FreeTrialTestPageState();
}

class _FreeTrialTestPageState extends State<FreeTrialTestPage> {
  int currentQuestion = 0;
  Map<int, String> answers = {};
  Timer? timer;
  int timeRemaining = 75 * 60;

  // Test verileri
  bool isLoading = true;
  bool isPreloading = false;
  bool testStarted = false;
  String? errorMessage;
  List<String> questionURLs = [];
  List<String> answerKey = [];
  int loadedImages = 0;
  int failedImages = 0;
  List<ImageProvider> preloadedImages = [];

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Context'e bağlı işlemleri frame sonrasına ertele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTest();
    });
  }

  Future<void> _loadTest() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // FreeTrialTestData'dan veriyi al
      final testData = FreeTrialTestData.getTestData(widget.testType);

      if (testData != null) {
        if (!mounted) return;
        setState(() {
          questionURLs = testData.questionURLs;
          answerKey = testData.answerKey;
          timeRemaining = testData.timeLimit;
          isLoading = false;
        });

        // Test verisi yüklendi, şimdi resimleri yükle
        await _preloadImages();
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = "Test data not found for type: ${widget.testType}";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Loading error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _preloadImages() async {
    if (!mounted) return;

    setState(() {
      isPreloading = true;
      loadedImages = 0;
      failedImages = 0;
    });

    try {
      print('🖼️ [PRELOAD] Starting to preload ${questionURLs.length} images in parallel...');

      // TÜM RESİMLERİ AYNI ANDA YÜKLE
      final futures = <Future<void>>[];

      for (int i = 0; i < questionURLs.length; i++) {
        final imageProvider = NetworkImage(questionURLs[i]);
        preloadedImages.add(imageProvider);

        futures.add(
          precacheImage(imageProvider, context).then((_) {
            if (mounted) {
              setState(() {
                loadedImages++;
              });
            }
            print('✅ [PRELOAD] Loaded $loadedImages/${questionURLs.length}');
          }).catchError((error) {
            print('❌ [PRELOAD] Failed to load question ${i + 1}: $error');
            if (mounted) {
              setState(() {
                failedImages++;
                loadedImages++;
              });
            }
          }),
        );
      }

      // TÜM RESİMLERİN YÜKLENMESİNİ BEKLE
      await Future.wait(futures);

      print('🎉 [PRELOAD] All images loaded successfully!');

      if (!mounted) return;
      setState(() {
        isPreloading = false;
      });
    } catch (e) {
      print('❌ [PRELOAD] Error loading images: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = "Error occurred while loading images: $e";
        isPreloading = false;
      });
    }
  }

  void _startTest() {
    setState(() {
      testStarted = true;
    });

    // Timer'ı sadece hasTimed true ise başlat
    if (widget.hasTimed) {
      _startTimer();
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeRemaining > 0) {
            timeRemaining--;
          } else {
            timer.cancel();
            _submitTest();
          }
        });
      }
    });
  }

  String get _formattedTime {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
    timer?.cancel();

    // Cache'i temizle
    _clearImageCache();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FreeTrialResultsPage(
          userAnswers: answers,
          correctAnswers: answerKey,
          questionURLs: questionURLs,
          testTitle: widget.testTitle,
          testColor: widget.testColor,
          toggleTheme: widget.toggleTheme,
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Exit Test?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              timer?.cancel();
              _clearImageCache();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.testColor,
            ),
            child: const Text('Exit Test', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

  void _showImageDialog(String imageUrl) {
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
                child: Container(color: Colors.black87),
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
                        image: preloadedImages[currentQuestion],
                        fit: BoxFit.contain,
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
  void dispose() {
    timer?.cancel();
    _clearImageCache();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // LOADING: Test verisi yüklenirken
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.testTitle.toUpperCase()),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: widget.testColor),
              const SizedBox(height: 20),
              const Text('Loading test data...', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    // ERROR: Test yüklenemedi
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.testTitle.toUpperCase()),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loadTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.testColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // PRELOADING: Resimler yüklenirken
    if (isPreloading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.testTitle.toUpperCase()),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: questionURLs.isEmpty ? null : loadedImages / questionURLs.length,
                        strokeWidth: 8,
                        color: widget.testColor,
                        backgroundColor: widget.testColor.withOpacity(0.2),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$loadedImages/${questionURLs.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: widget.testColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${((loadedImages / questionURLs.length) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Loading test...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please wait, test is loading',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // READY: Resimler yüklendi, test başlatılmayı bekliyor
    if (!testStarted) {
      final successCount = loadedImages - failedImages;

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.testTitle.toUpperCase()),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        ),
        body: Center(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0f172a) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: widget.testColor,
                ),
                const SizedBox(height: 30),
                Text(
                  'Test Ready!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.testColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.testTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoCard(
                      icon: Icons.quiz,
                      label: 'Questions',
                      value: '${questionURLs.length}',
                      color: widget.testColor,
                    ),
                    if (widget.hasTimed) ...[
                      const SizedBox(width: 20),
                      _buildInfoCard(
                        icon: Icons.timer,
                        label: 'Time Limit',
                        value: '${timeRemaining ~/ 60} min',
                        color: Colors.orange,
                      ),
                    ],
                    const SizedBox(width: 20),

                    if (failedImages > 0) ...[
                      const SizedBox(width: 20),
                      _buildInfoCard(
                        icon: Icons.error_outline,
                        label: 'Failed',
                        value: '$failedImages',
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.testColor.withOpacity(0.8),
                        widget.testColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.testColor.withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _startTest,
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      'START TEST',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    _clearImageCache();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // TEST BAŞLADI: Normal test ekranı
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.testTitle.toUpperCase()),
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.yellow : widget.testColor,
              ),
              onPressed: widget.toggleTheme,
            ),
            const SizedBox(width: 21),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: _showExitDialog,
                icon: const Icon(Icons.exit_to_app),
                label: Text(
                  'Exit Test',
                  style: TextStyle(
                    color: widget.testColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
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
                  // Timer or Progress
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.testColor.withOpacity(0.8),
                          widget.testColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.testColor.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.hasTimed
                          ? Text(
                        _formattedTime,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      )
                          : Column(
                        children: [
                          Text(
                            '${answers.length}/${questionURLs.length}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Answered',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
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
                  // Questions Grid
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
                          onTap: () => setState(() => currentQuestion = index),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isAnswered
                                  ? LinearGradient(
                                colors: [
                                  widget.testColor.withOpacity(0.8),
                                  widget.testColor,
                                ],
                              )
                                  : null,
                              color: isAnswered
                                  ? null
                                  : (isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCurrent
                                    ? widget.testColor
                                    : (isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey[300]!),
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
            // Main Content
            Expanded(
              child: Container(
                color: isDark
                    ? const Color(0xFF0a0e27).withOpacity(0.5)
                    : const Color(0xFFe8edf2),
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
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
                                    style: TextStyle(
                                      color: widget.testColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Question Image
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => _showImageDialog(
                                          questionURLs[currentQuestion]),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              child: ConstrainedBox(
                                                constraints:
                                                const BoxConstraints(
                                                  maxHeight: 500,
                                                  maxWidth: 700,
                                                ),
                                                child: Image(
                                                  image: preloadedImages[
                                                  currentQuestion],
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding:
                                                const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius:
                                                  BorderRadius.circular(8),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.zoom_in,
                                                        color: Colors.white,
                                                        size: 18),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Click to expand',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12),
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
                                    final isSelected =
                                        answers[currentQuestion + 1] == option;
                                    return _buildOption(
                                        option, isSelected, isDark);
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Navigation Buttons
                    Row(
                      children: [
                        if (currentQuestion > 0)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => currentQuestion--),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey[200],
                                padding:
                                const EdgeInsets.symmetric(vertical: 18),
                              ),
                              child: const Text('← Previous'),
                            ),
                          ),
                        if (currentQuestion > 0) const SizedBox(width: 15),
                        Expanded(
                          child: currentQuestion < questionURLs.length - 1
                              ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.testColor.withOpacity(0.8),
                                  widget.testColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => currentQuestion++),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18),
                              ),
                              child: const Text('Next →'),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.testColor.withOpacity(0.8),
                                  widget.testColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _submitTest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
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
              widget.testColor.withOpacity(0.3),
              widget.testColor.withOpacity(0.2),
            ],
          )
              : null,
          color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? widget.testColor : widget.testColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: option,
              groupValue: answers[currentQuestion + 1],
              onChanged: (value) => _selectOption(currentQuestion + 1, option),
              activeColor: widget.testColor,
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return widget.testColor;
                }
                return Colors.grey.shade400;
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