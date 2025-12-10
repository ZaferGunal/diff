import 'package:flutter/material.dart';
import 'package:untitled5/pages/welcome_page.dart';
import '../MyColors.dart';
import '../services/authservice.dart';

class AddTestPage extends StatefulWidget {
  final VoidCallback? toggleTheme;

  const AddTestPage({
    super.key,
    this.toggleTheme,
  });

  @override
  State<AddTestPage> createState() => _AddTestPageState();
}

class _AddTestPageState extends State<AddTestPage> {
  // Test Type Selection
  bool isPracticeTest = true; // true = Practice Test, false = Subject Test

  // Practice Test Controllers
  final TextEditingController practiceIndexController = TextEditingController();
  final TextEditingController practiceTitleController = TextEditingController();
  final TextEditingController practiceAnswerKeyController = TextEditingController();
  final TextEditingController practiceQuestionURLsController = TextEditingController();

  // Subject Test Controllers
  final TextEditingController subjectIndexController = TextEditingController();
  final TextEditingController subjectTopicController = TextEditingController();
  final TextEditingController subjectAnswerKeyController = TextEditingController();
  final TextEditingController subjectQuestionURLsController = TextEditingController();

  String selectedSubject = 'Mathematics';
  final List<String> subjects = [
    'Mathematics',
    'Reading Comprehension',
    'Logic',
    'Critical Thinking',
    'Numerical Reasoning',
  ];

  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    practiceIndexController.dispose();
    practiceTitleController.dispose();
    practiceAnswerKeyController.dispose();
    practiceQuestionURLsController.dispose();
    subjectIndexController.dispose();
    subjectTopicController.dispose();
    subjectAnswerKeyController.dispose();
    subjectQuestionURLsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Geliştirilmiş URL Parse Fonksiyonu
// Geliştirilmiş URL Parse Fonksiyonu
  List<String> _parseQuestionURLs(String input) {
    // Tüm satırları ve boşlukları temizle
    String cleaned = input.trim();

    List<String> urls = [];

    // GitHub URL'lerini bul (hem normal hem raw formatında)
    RegExp githubPattern = RegExp(r'https://github\.com/[^\s]+\.(?:png|jpg|jpeg|gif|pdf|webp)', caseSensitive: false);
    RegExp rawPattern = RegExp(r'https://raw\.githubusercontent\.com/[^\s]+');

    // Önce raw.githubusercontent.com URL'lerini bul
    Iterable<Match> rawMatches = rawPattern.allMatches(cleaned);
    for (Match match in rawMatches) {
      String url = match.group(0)!.trim();
      // Eğer ?raw=true varsa kaldır
      url = url.replaceAll('?raw=true', '');
      if (url.isNotEmpty) {
        urls.add(url);
      }
    }

    // Sonra github.com URL'lerini bul ve dönüştür
    Iterable<Match> githubMatches = githubPattern.allMatches(cleaned);
    for (Match match in githubMatches) {
      String url = match.group(0)!.trim();
      // ?raw=true'yu kaldır
      url = url.replaceAll('?raw=true', '');

      // github.com'u raw.githubusercontent.com'a çevir ve /blob/ kısmını kaldır
      if (url.contains('github.com')) {
        url = url
            .replaceAll('https://github.com/', 'https://raw.githubusercontent.com/')
            .replaceAll('/blob/', '/');
      }

      if (url.isNotEmpty && !urls.contains(url)) {
        urls.add(url);
      }
    }

    // Eğer hiç URL bulunamadıysa, genel URL pattern'i ile dene
    if (urls.isEmpty) {
      RegExp generalPattern = RegExp(r'https://[^\s,]+', caseSensitive: false);
      Iterable<Match> matches = generalPattern.allMatches(cleaned);

      for (Match match in matches) {
        String url = match.group(0)!.trim();
        // ?raw=true'yu kaldır
        url = url.replaceAll('?raw=true', '');

        // GitHub URL'lerini dönüştür
        if (url.contains('github.com')) {
          url = url
              .replaceAll('https://github.com/', 'https://raw.githubusercontent.com/')
              .replaceAll('/blob/', '/');
        }

        if (url.isNotEmpty && !urls.contains(url)) {
          urls.add(url);
        }
      }
    }

    return urls;
  }
  // Geliştirilmiş Answer Key Parse Fonksiyonu
  List<String> _parseAnswerKey(String input) {
    // Tüm satırları ve boşlukları temizle
    String cleaned = input.trim().toUpperCase();

    List<String> answers = [];

    // Format 1: "1. B 2. C 3. C" veya "1- A 2- C"
    RegExp pattern1 = RegExp(r'(\d+)[\.\-]\s*([A-E])');
    Iterable<Match> matches = pattern1.allMatches(cleaned);

    if (matches.isNotEmpty) {
      // Sıralı kontrolü için map oluştur
      Map<int, String> answersMap = {};
      for (Match match in matches) {
        int questionNum = int.parse(match.group(1)!);
        String answer = match.group(2)!;
        answersMap[questionNum] = answer;
      }

      // Sıralı şekilde listeye ekle
      for (int i = 1; i <= answersMap.length; i++) {
        if (answersMap.containsKey(i)) {
          answers.add(answersMap[i]!);
        }
      }

      return answers;
    }

    // Format 2: "A,B,C,D,E" (virgülle ayrılmış)
    if (cleaned.contains(',')) {
      answers = cleaned
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && RegExp(r'^[A-E]$').hasMatch(e))
          .toList();

      if (answers.isNotEmpty) return answers;
    }

    // Format 3: "A B C D E" (boşlukla ayrılmış)
    answers = cleaned
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty && RegExp(r'^[A-E]$').hasMatch(e))
        .toList();

    return answers;
  }

  Future<void> _addPracticeTest() async {
    if (practiceIndexController.text.isEmpty ||
        practiceTitleController.text.isEmpty ||
        practiceAnswerKeyController.text.isEmpty ||
        practiceQuestionURLsController.text.isEmpty) {
      _showErrorDialog('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      final index = int.parse(practiceIndexController.text);
      final answerKey = _parseAnswerKey(practiceAnswerKeyController.text);
      final questionURLs = _parseQuestionURLs(practiceQuestionURLsController.text);

      if (answerKey.isEmpty) {
        _showErrorDialog('Could not parse answer key. Please check the format.');
        setState(() => isLoading = false);
        return;
      }

      if (questionURLs.isEmpty) {
        _showErrorDialog('Could not parse question URLs. Please check the format.');
        setState(() => isLoading = false);
        return;
      }

      if (answerKey.length != questionURLs.length) {
        _showErrorDialog('Answer key count (${answerKey.length}) and question URLs count (${questionURLs.length}) must match');
        setState(() => isLoading = false);
        return;
      }

      final response = await AuthService().addPracticeTest(
        index: index,
        title: practiceTitleController.text,
        answerKey: answerKey,
        questionURLs: questionURLs,
      );

      if (response?.data['success'] == true) {
        _showSuccessDialog('Practice Test added successfully!\n${questionURLs.length} questions added.');
        _clearPracticeFields();
      } else {
        _showErrorDialog(response?.data['msg'] ?? 'Failed to add test');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addSubjectTest() async {
    if (subjectIndexController.text.isEmpty ||
        subjectAnswerKeyController.text.isEmpty ||
        subjectQuestionURLsController.text.isEmpty) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      final index = int.parse(subjectIndexController.text);
      final answerKey = _parseAnswerKey(subjectAnswerKeyController.text);
      final questionURLs = _parseQuestionURLs(subjectQuestionURLsController.text);

      if (answerKey.isEmpty) {
        _showErrorDialog('Could not parse answer key. Please check the format.');
        setState(() => isLoading = false);
        return;
      }

      if (questionURLs.isEmpty) {
        _showErrorDialog('Could not parse question URLs. Please check the format.');
        setState(() => isLoading = false);
        return;
      }

      if (answerKey.length != questionURLs.length) {
        _showErrorDialog('Answer key count (${answerKey.length}) and question URLs count (${questionURLs.length}) must match');
        setState(() => isLoading = false);
        return;
      }

      final response = await AuthService().addSubjectTest(
        subject: selectedSubject,
        index: index,
        answerKey: answerKey,
        questionURLs: questionURLs,
        topic: subjectTopicController.text.isEmpty ? '' : subjectTopicController.text,
      );

      if (response?.data['success'] == true) {
        _showSuccessDialog('Subject Test added successfully!\n${questionURLs.length} questions added.');
        _clearSubjectFields();
      } else {
        _showErrorDialog(response?.data['msg'] ?? 'Failed to add test');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearPracticeFields() {
    practiceIndexController.clear();
    practiceTitleController.clear();
    practiceAnswerKeyController.clear();
    practiceQuestionURLsController.clear();
  }

  void _clearSubjectFields() {
    subjectIndexController.clear();
    subjectTopicController.clear();
    subjectAnswerKeyController.clear();
    subjectQuestionURLsController.clear();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
        title: const Text(
          'ADD TEST',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
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
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.yellow : MyColors.bocco_blue,
            ),
            onPressed: widget.toggleTheme,
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MyColors.bocco_blue.withOpacity(0.8),
                  MyColors.bocco_blue,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage(toggleTheme: () {  },)),
                      (route) => false,
                );
              },
              icon: const Icon(
                Icons.home,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(60),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1a1f37) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                MyColors.bocco_blue.withOpacity(0.8),
                                MyColors.bocco_blue,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Test',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose test type and fill the details',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Test Type Switch
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isPracticeTest = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: isPracticeTest
                                      ? LinearGradient(
                                    colors: [
                                      MyColors.bocco_blue.withOpacity(0.8),
                                      MyColors.bocco_blue,
                                    ],
                                  )
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Practice Test',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isPracticeTest
                                          ? Colors.white
                                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isPracticeTest = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: !isPracticeTest
                                      ? LinearGradient(
                                    colors: [
                                      MyColors.green.withOpacity(0.8),
                                      MyColors.green,
                                    ],
                                  )
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Subject Test',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: !isPracticeTest
                                          ? Colors.white
                                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form Area
                    if (isPracticeTest) _buildPracticeTestForm(isDark) else _buildSubjectTestForm(isDark),

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : (isPracticeTest ? _addPracticeTest : _addSubjectTest),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPracticeTest
                                  ? [
                                MyColors.bocco_blue.withOpacity(0.8),
                                MyColors.bocco_blue,
                              ]
                                  : [
                                MyColors.green.withOpacity(0.8),
                                MyColors.green,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Add Test to Database',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeTestForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: practiceIndexController,
          label: 'Test Index',
          hint: 'e.g., 1, 2, 3, 4',
          icon: Icons.numbers,
          isDark: isDark,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: practiceTitleController,
          label: 'Test Title',
          hint: 'e.g., Practice Test 1',
          icon: Icons.title,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: practiceAnswerKeyController,
          label: 'Answer Key',
          hint: 'Format: "1. B 2. C 3. C" or "1- A 2- C" or "A,B,C,D"',
          icon: Icons.check_circle_outline,
          isDark: isDark,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: practiceQuestionURLsController,
          label: 'Question URLs',
          hint: 'Paste all URLs (space or line separated, must end with ?raw=true)',
          icon: Icons.link,
          isDark: isDark,
          maxLines: 6,
        ),
      ],
    );
  }

  Widget _buildSubjectTestForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject Dropdown
        Text(
          'Subject',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
            ),
          ),
          child: DropdownButton<String>(
            value: selectedSubject,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.white : Colors.black87,
            ),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: isDark ? const Color(0xFF1a1f37) : Colors.white,
            items: subjects.map((String subject) {
              return DropdownMenuItem<String>(
                value: subject,
                child: Text(subject),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() => selectedSubject = newValue!);
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: subjectIndexController,
          label: 'Test Index',
          hint: 'e.g., 1, 2, 3...',
          icon: Icons.numbers,
          isDark: isDark,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: subjectTopicController,
          label: 'Topic (Optional)',
          hint: 'e.g., Algebra, Geometry (leave empty if not needed)',
          icon: Icons.topic,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: subjectAnswerKeyController,
          label: 'Answer Key',
          hint: 'Format: "1. B 2. C 3. C" or "1- A 2- C" or "A,B,C,D"',
          icon: Icons.check_circle_outline,
          isDark: isDark,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: subjectQuestionURLsController,
          label: 'Question URLs',
          hint: 'Paste all URLs (space or line separated, must end with ?raw=true)',
          icon: Icons.link,
          isDark: isDark,
          maxLines: 6,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isPracticeTest ? MyColors.bocco_blue : MyColors.green,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}