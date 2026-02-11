import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../MyColors.dart';

class AuthService {
  Dio dio = Dio();

  void _handleError(DioException e, {String? customMessage}) {
    String msg;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      if (e.error.toString().contains('SocketException') ||
          e.error.toString().contains('Failed host lookup') ||
          e.message?.contains('Failed host lookup') == true) {
        msg = "No internet connection. Please check your network.";
      } else {
        msg = "Network error. Please check your connection.";
      }
    }
    else if (e.type == DioExceptionType.connectionTimeout) {
      msg = "Connection timeout. Please check your internet.";
    }
    else if (e.type == DioExceptionType.receiveTimeout) {
      msg = "Server is not responding. Please try again.";
    }
    else if (e.type == DioExceptionType.sendTimeout) {
      msg = "Request timeout. Please check your connection.";
    }
    else if (e.response?.data != null && e.response!.data is Map) {
      msg = e.response!.data["msg"] ?? customMessage ?? "An error occurred";
    }
    else {
      msg = customMessage ?? "An error occurred. Please try again.";
    }

    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: MyColors.red,
        textColor: MyColors.white,
        fontSize: 16.0
    );
  }

  // LOGIN & SIGNUP
  login(email, password) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/authenticate",
          data: {
            "email": email,
            "password": password
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        _handleError(e, customMessage: "Invalid email or password");
      } else {
        _handleError(e, customMessage: "Login failed. Please try again.");
      }
      rethrow;
    }
  }

  googleLogin(String idToken) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/authenticate-google",
          data: {"idToken": idToken},
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Google Sign-In failed.");
      rethrow;
    }
  }

  signup(name, password, email) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/adduser",
          data: {"name": name, "password": password, "email": email},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Signup failed. Please try again.");
      rethrow;
    }
  }

  // USER INFO & SESSION
  getinfo(token) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/getinfo",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load user info");
      rethrow;
    }
  }

  heartbeat(String token) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/heartbeat",
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );

      // ✅ Session expired kontrolü
      if (response.statusCode == 401) {
        print("⚠️ [HEARTBEAT] 401 - Session expired");
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Session expired',
        );
      }

      return response;
    } on DioException catch (e) {
      print("⚠️ [HEARTBEAT] Failed: ${e.message}");
      print("⚠️ [HEARTBEAT] Status: ${e.response?.statusCode}");
      rethrow;
    }
  }

  logout(String token) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/logout",
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to logout");
      rethrow;
    }
  }

  // USER PREFERENCES
  updateDarkMode(String token, bool isDarkMode) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      var res = await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/updateDarkMode",
          data: {"isDarkMode": isDarkMode},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
      return res.data;
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to update theme");
      rethrow;
    }
  }

  updatePracticesSolved(String token, List<bool> practicesSolved) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      var res = await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/updatePracticesSolved",
          data: {"practicesSolved": practicesSolved},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
      return res.data;
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to update progress");
      rethrow;
    }
  }

  // EMAIL VERIFICATION (SIGNUP)
  sendOTP(String email) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/send-otp",
          data: {"email": email},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to send verification code");
      rethrow;
    }
  }

  verifyOTP(String userId, String otp) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/verify-otp",
          data: {"userId": userId, "otp": otp},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Verification failed");
      rethrow;
    }
  }

  resendOTP(String userId, String email) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/resend-otp",
          data: {"userId": userId, "email": email},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to resend code");
      rethrow;
    }
  }

  // PASSWORD RESET
  sendPasswordResetOTP(String email) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/password-reset/send-otp",
          data: {"email": email},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to send reset code");
      rethrow;
    }
  }

  verifyPasswordResetOTP(String userId, String otp) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/password-reset/verify-otp",
          data: {"userId": userId, "otp": otp},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Invalid verification code");
      rethrow;
    }
  }

  resetPassword(String userId, String newPassword) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/password-reset/reset",
          data: {"userId": userId, "newPassword": newPassword},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to reset password");
      rethrow;
    }
  }

  // PRACTICE TESTS
  addPracticeTest({
    required int index,
    required String title,
    required List<String> answerKey,
    required List<String> questionURLs,
  }) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/practice/add",
          data: {
            "index": index,
            "title": title,
            "answerKey": answerKey,
            "questionURLs": questionURLs
          },
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to add practice test");
      rethrow;
    }
  }

  getPracticeTest(int index) async {
    try {
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/practice/$index",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load practice test");
      rethrow;
    }
  }

  getAllPracticeTests() async {
    try {
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/practice",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load practice tests");
      rethrow;
    }
  }

  // SUBJECT TESTS
  addSubjectTest({
    required String subject,
    required int index,
    required List<String> answerKey,
    required List<String> questionURLs,
    required String topic,
  }) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/subject/add",
          data: {
            "subject": subject,
            "index": index,
            "answerKey": answerKey,
            "questionURLs": questionURLs,
            "topic": topic
          },
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to add subject test");
      rethrow;
    }
  }

  getSubjectTest(String subject, int index) async {
    try {
      String normalizedSubject = _normalizeSubject(subject);

      print('🔍 [SUBJECT TEST] Requesting: $normalizedSubject - $index');

      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/subject/$normalizedSubject/$index",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load subject test");
      rethrow;
    }
  }

  String _normalizeSubject(String subject) {
    Map<String, String> subjectMap = {
      'logic': 'Logic',
      'Logic': 'Logic',
      'math': 'Mathematics',
      'Mathematics': 'Mathematics',
      'reading': 'Reading Comprehension',
      'reading_comprehension': 'Reading Comprehension',
      'Reading Comprehension': 'Reading Comprehension',
      'numerical_reasoning': 'Numerical Reasoning',
      'Numerical Reasoning': 'Numerical Reasoning',
      'critical_thinking': 'Critical Thinking',
      'Critical Thinking': 'Critical Thinking',
    };

    return subjectMap[subject] ?? subject;
  }

  getSubjectTestsBySubject(String subject) async {
    try {
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/subject/$subject",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load subject tests");
      rethrow;
    }
  }

  // TILI SUBJECT TESTS (Text-based)
  getTILSubjectTest(String subject, int index) async {
    try {
      String normalizedSubject = _normalizeTILSubject(subject);
      print('🔍 [TILI SUBJECT TEST] Requesting: $normalizedSubject - $index');

      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/til-subject/$normalizedSubject/$index",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load TILI subject test");
      rethrow;
    }
  }

  getTILSubjectTestsBySubject(String subject) async {
    try {
      String normalizedSubject = _normalizeTILSubject(subject);
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/til-subject/$normalizedSubject",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load TILI subject tests");
      rethrow;
    }
  }

  // TILI PRACTICE EXAMS (Text-based)
  getTILPracticeExam(int index) async {
    try {
      print('🔍 [TILI PRACTICE EXAM] Requesting index: $index');
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/til-practice-exam/$index",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load TILI practice exam");
      rethrow;
    }
  }

  getAllTILPracticeExams() async {
    try {
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/til-practice-exam",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load TILI practice exams");
      rethrow;
    }
  }

  String _normalizeTILSubject(String subject) {
    // TILI backend expects lowercase for routing usually, but map known types
    Map<String, String> subjectMap = {
      'Mathematics': 'math',
      'Reading Comprehension': 'reading',
      'Physics': 'physics',
      'Technical Knowledge': 'technical knowledge',
    };
    return subjectMap[subject] ?? subject.toLowerCase();
  }

  // PRACTICE TEST RESULTS
  updatePracticeTestResults({
    required String token,
    required int testNumber,
    required double correctAnswers,
    required double wrongAnswers,
    required double emptyAnswers,
    required double score,
  }) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      var res = await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/practice-test-results/update",
          data: {
            "testNumber": testNumber,
            "correctAnswers": correctAnswers,
            "wrongAnswers": wrongAnswers,
            "emptyAnswers": emptyAnswers,
            "score": score
          },
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
      return res.data;
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to update test results");
      rethrow;
    }
  }

  getPracticeTestResults(String token) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/practice-test-results",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load test results");
      rethrow;
    }
  }

  deletePracticeTestResult({
    required String token,
    required int testNumber,
  }) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/practice-test-results/delete",
          data: {"testNumber": testNumber},
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to delete test result");
      rethrow;
    }
  }

  // TILI PRACTICE EXAM RESULTS
  saveTILPracticeExamResult({
    required String token,
    required int examIndex,
    required String title,
    required int correctCount,
    required int wrongCount,
    required int emptyCount,
    required double score,
    required Map<String, String> userAnswers,
    required List<String> correctAnswers,
  }) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      var res = await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/til-practice-exam-results/save",
          data: {
            "examIndex": examIndex,
            "title": title,
            "correctCount": correctCount,
            "wrongCount": wrongCount,
            "emptyCount": emptyCount,
            "score": score,
            "userAnswers": userAnswers,
            "correctAnswers": correctAnswers,
            "completedAt": DateTime.now().toIso8601String(),
          },
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
      return res.data;
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to save exam result");
      rethrow;
    }
  }

  getTILPracticeExamResults(String token, {int limit = 5}) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/til-practice-exam-results?limit=$limit",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load exam results");
      rethrow;
    }
  }

  getCompletedTILPracticeExamIndices(String token) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/til-practice-exam-results/completed-indices",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load completed exams");
      rethrow;
    }
  }

  verifyPayment(String userId) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/verify-payment",
          data: {"userId": userId},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Payment verification failed");
      rethrow;
    }
  }

  // SECURE IMAGE PROXY
  Future<String> getSecureImageUrl(String githubUrl, String token) async {
    final encodedUrl = Uri.encodeComponent(githubUrl);
    final proxyUrl = 'https://testauth-153e5c716660.herokuapp.com/secure-image?url=$encodedUrl';
    return proxyUrl;
  }

  Future<Response?> fetchSecureImage(String githubUrl, String token) async {
    try {
      final encodedUrl = Uri.encodeComponent(githubUrl);

      dio.options.headers["Authorization"] = "Bearer $token";

      return await dio.get(
        "https://testauth-153e5c716660.herokuapp.com/secure-image?url=$encodedUrl",
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      print('⚠️ Secure image fetch failed: ${e.message}');
      rethrow;
    }
  }

  Future<Response?> initializePayment({
    required String userId,
    required String email,
    required String name,
    required bool acceptedTerms,
    required bool acceptedPreliminaryInformation,
  }) async {
    try {
      return await dio.post(
        "https://testauth-153e5c716660.herokuapp.com/payment/initialize",
        data: {
          "userId": userId,
          "email": email,
          "name": name,
          "acceptedTerms": acceptedTerms,
          "acceptedPreliminaryInformation": acceptedPreliminaryInformation,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to initialize payment");
      rethrow;
    }
  }

  Future<Response?> checkPaymentStatus(String userId) async {
    try {
      return await dio.post(
        "https://testauth-153e5c716660.herokuapp.com/payment/check-status",
        data: {"userId": userId},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to check payment status");
      rethrow;
    }
  }

  // BOCCONI PAYMENT
  Future<Response?> initializeBocconiPayment({
    required String userId,
    required String email,
    required String name,
    required bool acceptedTerms,
    required bool acceptedPreliminaryInformation,
  }) async {
    try {
      return await dio.post(
        "https://testauth-153e5c716660.herokuapp.com/payment/bocconi/initialize",
        data: {
          "userId": userId,
          "email": email,
          "name": name,
          "acceptedTerms": acceptedTerms,
          "acceptedPreliminaryInformation": acceptedPreliminaryInformation,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to initialize Bocconi payment");
      rethrow;
    }
  }

  // TILI PAYMENT
  Future<Response?> initializeTiliPayment({
    required String userId,
    required String email,
    required String name,
    required bool acceptedTerms,
    required bool acceptedPreliminaryInformation,
    required String packageTier, // ✅ NEW
  }) async {
    try {
      return await dio.post(
        "https://testauth-153e5c716660.herokuapp.com/payment/tili/initialize",
        data: {
          "userId": userId,
          "email": email,
          "name": name,
          "acceptedTerms": acceptedTerms,
          "acceptedPreliminaryInformation": acceptedPreliminaryInformation,
          "packageTier": packageTier, // ✅ NEW
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to initialize TILI payment");
      rethrow;
    }
  }

  // WEEKLY ACTIVITY
  Future<Response?> getWeeklyActivity(String token) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      return await dio.get(
        "https://testauth-153e5c716660.herokuapp.com/user/weekly-activity",
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load weekly activity");
      rethrow;
    }
  }

  // CHECK USER PAYMENT STATUS (FOR POLLING)
  Future<Response?> checkUserPaymentStatus(String userId) async {
    try {
      return await dio.post(
        "https://testauth-153e5c716660.herokuapp.com/user/check-user-payment-status",
        data: {"userId": userId},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      print('❌ [CHECK PAYMENT STATUS] Error: $e');
      return null;
    }
  }


  getFlashcardsBySubject(String subject) async {
    try {
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/flashcard/${subject.toLowerCase()}",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load flashcards");
      rethrow;
    }
  }

  getFlashcard(String subject, int index) async {
    try {
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/flashcard/${subject.toLowerCase()}/$index",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load flashcard");
      rethrow;
    }
  }

  getAllFlashcards() async {
    try {
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/flashcards",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load all flashcards");
      rethrow;
    }
  }

  // FLASHCARD PROGRESS SYNC (Database)
  getFlashcardProgress(String userId) async {
    try {
      return await dio.get(
          "https://testauth-153e5c716660.herokuapp.com/progress/$userId",
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to load flashcard progress");
      rethrow;
    }
  }

  saveFlashcardProgress(String userId, String flashcardId, String status) async {
    try {
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/progress/update",
          data: {
            "userId": userId,
            "flashcardId": flashcardId,
            "status": status
          },
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      _handleError(e, customMessage: "Failed to save flashcard progress");
      rethrow;
    }
  }
}