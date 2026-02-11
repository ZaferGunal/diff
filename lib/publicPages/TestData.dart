// Test Data Model
class TestData {
  final String title;
  final List<String> questionURLs;
  final List<String> answerKey;
  final bool hasTimed;
  final int timeLimit; // saniye cinsinden

  TestData({
    required this.title,
    required this.questionURLs,
    required this.answerKey,
    required this.hasTimed,
    this.timeLimit = 4500, // default 75 dakika
  });
}

// Test Data Repository
class FreeTrialTestData {
  // Practice Test (50 soru - 75 dakika)
  static final TestData practiceTest = TestData(
    title: 'Practice Test',
    hasTimed: true,
    timeLimit: 75 * 60, // 75 dakika
    questionURLs: [
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/1.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/2.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/3.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/4.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/5.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/6.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/7.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/8.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/9.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/10.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/11.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/12.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/13.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/14.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/15.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/16.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/17.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/18.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/19.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/20.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/21.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/22.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/23.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/24.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/25.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/26.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/27.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/28.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/29.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/30.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/31.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/32.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/33.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/34.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/35.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/36.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/37.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/38.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/39.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/40.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/41.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/42.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/43.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/44.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/45.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/46.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/47.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/48.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/49.png',
      'https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Free%20Deneme/50.png',
    ],
    answerKey: [
      'C', 'A', 'C', 'C', 'B', 'C', 'D', 'A', 'A', 'D',
      'C', 'C', 'B', 'E', 'A', 'D', 'B', 'E', 'A', 'B',
      'B', 'D', 'E', 'C', 'C', 'A', 'C', 'C', 'E', 'E',
      'A', 'C', 'C', 'A', 'B', 'E', 'C', 'E', 'E', 'C',
      'C', 'C', 'A', 'A', 'C', 'A', 'C', 'B', 'A', 'B',
    ],
  );

  // Math Test (10 soru)
  static final TestData mathTest = TestData(
    title: 'Math Test',
    hasTimed: false,
    questionURLs: [
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/1.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/2.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/3.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/4.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/5.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/6.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/7.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/8.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/9.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Math%20Free%20Trial/10.png"

    ],
    answerKey: [
      'E', 'E', 'A', 'B', 'D', 'E', 'C', 'B', 'A', 'C',

    ],
  );

  // Reading Test (10 soru)
  static final TestData readingTest = TestData(
    title: 'Reading Test',
    hasTimed: false,
    questionURLs: [
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/1.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/2.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/3.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/4.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/5.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/6.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/7.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/8.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/9.png",
    "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Reading/TEST%201/10.png",
],
    answerKey: [
      'B', 'D', 'B', 'C', 'B', 'C', 'B', 'C', 'C', 'C',
// ← GERÇEK CEVAPLARI BURAYA GİRİN
    ],
  );

  // Numerical Reasoning Test (10 soru)
  static final TestData numericalTest = TestData(
    title: 'Numerical Reasoning',
    hasTimed: false,
    questionURLs: [
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/1.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/2.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/3.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/4.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/5.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/6.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/7.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/8.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/9.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Numerical%20Reasoning/TEST%201/10.png",

    ],
    answerKey: [
      'D', 'D', 'C', 'D', 'D', 'A', 'B', 'A', 'D','A'
// ← GERÇEK CEVAPLARI BURAYA GİRİN
    ],
  );

  // Logic Test (10 soru)
  static final TestData logicTest = TestData(
    title: 'Logic Test',
    hasTimed: false,
    questionURLs: [
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q1.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q2.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q3.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q4.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q5.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q6.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q7.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q8.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q9.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Logic/TEST%201/Q10.png",

    ],
    answerKey: [
      'C', 'A', 'E', 'D', 'C', 'E', 'D', 'A', 'B', 'B',
      // ← GERÇEK CEVAPLARI BURAYA GİRİN
    ],
  );

  // Critical Reasoning Test (10 soru)
  static final TestData criticalTest = TestData(
    title: 'Critical Reasoning',
    hasTimed: false,
    questionURLs: [
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/1.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/2.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/3.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/4.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/5.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/6.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/7.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/8.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/9.png",
      "https://raw.githubusercontent.com/ZaferGunal/links/main/Practico/Critical%20Thinking/TEST%201/10.png",

    ],
    answerKey: [
    'B', 'C', 'B', 'A', 'B', 'C', 'B', 'B', 'B', 'B',

    ],
  );

  // Test tipine göre data getir
  static TestData? getTestData(String testType) {
    switch (testType.toLowerCase()) {
      case 'practice':
        return practiceTest;
      case 'math':
        return mathTest;
      case 'reading':
        return readingTest;
      case 'numerical':
        return numericalTest;
      case 'logic':
        return logicTest;
      case 'critical':
        return criticalTest;
      default:
        return null;
    }
  }
}