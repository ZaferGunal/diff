import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../MyColors.dart';

class AuthService {
  Dio dio = Dio();

  void _handleError(DioException e, {String? customMessage}) {
    String msg;

    // ✅ Network bağlantısı yok - Öncelikli kontrol
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      // Daha spesifik kontrol
      if (e.error.toString().contains('SocketException') ||
          e.error.toString().contains('Failed host lookup') ||
          e.message?.contains('Failed host lookup') == true) {
        msg = "No internet connection. Please check your network.";
      } else {
        msg = "Network error. Please check your connection.";
      }
    }
    // ✅ Timeout hataları
    else if (e.type == DioExceptionType.connectionTimeout) {
      msg = "Connection timeout. Please check your internet.";
    }
    else if (e.type == DioExceptionType.receiveTimeout) {
      msg = "Server is not responding. Please try again.";
    }
    else if (e.type == DioExceptionType.sendTimeout) {
      msg = "Request timeout. Please check your connection.";
    }
    // ✅ Server response varsa
    else if (e.response?.data != null && e.response!.data is Map) {
      msg = e.response!.data["msg"] ?? customMessage ?? "An error occurred";
    }
    // ✅ Diğer hatalar
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

  // ==========================================
  // LOGIN & SIGNUP
  // ==========================================

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

  // ==========================================
  // USER INFO & SESSION
  // ==========================================

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
      return await dio.post(
          "https://testauth-153e5c716660.herokuapp.com/heartbeat",
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (status) => status != null && status < 500,
          )
      );
    } on DioException catch (e) {
      // ✅ Heartbeat için log yeterli - toast gösterme
      print("⚠️ Heartbeat failed: ${e.message}");
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

  // ==========================================
  // USER PREFERENCES
  // ==========================================

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

  // ==========================================
  // EMAIL VERIFICATION (SIGNUP)
  // ==========================================

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

  // ==========================================
  // PASSWORD RESET
  // ==========================================

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

  // ==========================================
  // PRACTICE TESTS
  // ==========================================

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

  // ==========================================
  // SUBJECT TESTS
  // ==========================================

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
// authservice.dart içindeki getSubjectTest fonksiyonunu bununla değiştir:

  getSubjectTest(String subject, int index) async {
    try {
      // ✅ subject'i normalize et
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

// ✅ Helper fonksiyon - subject ismini normalize et
  String _normalizeSubject(String subject) {
    // "logic" -> "Logic"
    // "reading_comprehension" -> "Reading Comprehension"
    // "numerical_reasoning" -> "Numerical Reasoning"

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

  // ==========================================
  // PRACTICE TEST RESULTS
  // ==========================================

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
}