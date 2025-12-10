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
      var response = await AuthService().getPracticeTest(widget.testIndex);

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
        setState(() {
          errorMessage = response?.data['msg'] ?? "Test bulunamadı";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Yükleme hatası: $e";
        isLoading = false;
      });
    }
  }

  // ✅ Tüm resimleri PARALEL olarak önceden yükle
  Future<void> _preloadAllImages() async {
    setState(() {
      isLoadingImages = true;
      loadedImagesCount = 0;
    });

    print('🖼️ [PRELOAD] Starting to preload ${questionURLs.length} images in parallel...');

    try {
      // ✅ TÜM RESİMLERİ AYNI ANDA YÜKLE
      final futures = <Future<void>>[];

      for (int i = 0; i < questionURLs.length; i++) {
        final imageProvider = NetworkImage(questionURLs[i]);
        preloadedImages.add(imageProvider);

        // Her resim için ayrı bir Future oluştur
        futures.add(
            precacheImage(imageProvider, context).then((_) {
              setState(() {
                loadedImagesCount++;
              });
              print('✅ [PRELOAD] Loaded image $loadedImagesCount/${questionURLs.length}');
            })
        );
      }

      // ✅ TÜM RESİMLERİN YÜKLENMESİNİ BEKLE
      await Future.wait(futures);

      print('🎉 [PRELOAD] All images loaded successfully!');

      setState(() {
        isLoadingImages = false;
      });

      // ✅ Resimler yüklendi, timer'ı başlat
      _startTimer();

    } catch (e) {
      print('❌ [PRELOAD] Error loading test data: $e');
      setState(() {
        errorMessage = "error occurred while loading: $e";
        isLoadingImages = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    // ✅ Scaffold'dan çıkıldığında cache'i temizle
    _clearImageCache();

    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ✅ Yüklenen resimleri cache'den temizle
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
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    setState(() {
      // Eğer aynı şık seçiliyse, işareti kaldır
      if (answers[questionNum] == option) {
        answers.remove(questionNum);
      } else {
        answers[questionNum] = option;
      }
    });
  }

  void _submitTest() async {
    timer?.cancel();

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // ✅ 1. ÖNCE practicesSolved'ı güncelle ve BEKLENİN
    await auth.updatePracticeSolved(widget.testIndex - 1, true);

    // ✅ 2. SONRA test results'ı kaydet ve BEKLENİN
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

    // ✅ Results'ı kaydet ve BEKLENİN
    await auth.updatePracticeTestResult(
      testNumber: widget.testIndex,
      correctAnswers: correctCount.toDouble(),
      wrongAnswers: wrongCount.toDouble(),
      emptyAnswers: emptyCount.toDouble(),
      score: score,
    );

    // ✅ 3. HER ŞEY KAYDEDİLDİKTEN SONRA results sayfasına git
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
              // Arka plan
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                ),
              ),
              // ✅ Preloaded image kullan
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
              // Close butonu
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

  // Klavye tuşlarını dinle - BASIT VERSİYON
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Aşağı ok - En alta git
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // Yukarı ok - En üste git
        _scrollController.jumpTo(0);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Test verisi yüklenirken veya resimler yüklenirken
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
                    const SizedBox(height: 12),

                    const SizedBox(height: 16),
                    Container(
                      width: 300,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: loadedImagesCount / questionURLs.length,
                        child: Container(
                          decoration: BoxDecoration(
                            color: MyColors.cyan,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

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
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
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
                color: isDark ? Colors.yellow : MyColors.bocco_blue,
                isDark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: widget.toggleTheme,
            ),
            const SizedBox(width: 21),
            Container(
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: _showExitDialog,
                icon: const Icon(Icons.exit_to_app),
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
                          onTap: () => setState(() => currentQuestion = index),
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
                                  // ✅ Preloaded image kullan
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => _showImageDialog(questionURLs[currentQuestion]),
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
                    Row(
                      children: [
                        if (currentQuestion > 0)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() => currentQuestion--),
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
                              onPressed: () => setState(() => currentQuestion++),
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
                              onPressed: _submitTest,
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
            color: isSelected
                ? MyColors.cyan
                : MyColors.cyan,
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