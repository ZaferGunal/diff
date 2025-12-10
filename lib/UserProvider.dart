import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled5/services/authservice.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  Timer? _heartbeatTimer;

  final AuthService _authService = AuthService();

  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _userData != null;

  String? get name => _userData?['name'];
  String? get email => _userData?['email'];
  bool get isDarkMode => _userData?['isDarkMode'] ?? false;
  bool get isLoggedIn => _userData?['isLoggedIn'] ?? false;

  List<bool> get practicesSolved {
    if (_userData?['practicesSolved'] == null) return [false, false, false, false];
    return List<bool>.from(_userData!['practicesSolved']);
  }

  List<Map<String, dynamic>> get practiceTestResults {
    if (_userData?['practiceTestResults'] == null) return [];
    return List<Map<String, dynamic>>.from(_userData!['practiceTestResults']);
  }

  Future<void> checkPreviousSession() async {
    final prefs = await SharedPreferences.getInstance();
    final oldToken = prefs.getString('auth_token');

    if (oldToken != null) {
      print('⚠️ Eski oturum bulundu - kontrol ediliyor...');

      try {
        _token = oldToken;

        final val = await _authService.getinfo(oldToken);

        if (val != null && val.data["success"] == true) {
          print('✅ Eski oturum geçerli - kullanıcı giriş yapabilir');
          _userData = val.data;

          _startHeartbeat();

          notifyListeners();
        } else {
          print('⚠️ Eski token geçersiz - temizleniyor');
          await _clearSession();
        }
      } catch (e) {
        print('❌ Session kontrolünde hata: $e');
        await _clearSession();
      }
    } else {
      print('✅ Önceki oturum yok');
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _userData = null;

    _stopHeartbeat();

    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    _startHeartbeat();

    notifyListeners();
    await fetchUserInfo();
  }

  // ✅ Heartbeat - HER 30 SANİYEDE BİR kontrol et
  void _startHeartbeat() {
    _stopHeartbeat();

    print('💓 [HEARTBEAT] Starting heartbeat timer...');

    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (_token != null) {
        try {
          print('💓 [HEARTBEAT] Sending heartbeat...');
          final response = await _authService.heartbeat(_token!);

          // ✅ Response kontrol et
          if (response != null && response.data["success"] == true) {
            print('✅ [HEARTBEAT] Heartbeat OK');
          }
        } catch (e) {
          print('⚠️ [HEARTBEAT] Failed: $e');

          // ✅ 401 hatası = başka yerden giriş yapılmış
          if (e.toString().contains('401') ||
              e.toString().contains('Session expired') ||
              e.toString().contains('sessionExpired')) {
            print('❌ [HEARTBEAT] Session kapatıldı - logout yapılıyor');

            // Kullanıcıya bildir
            _showSessionExpiredDialog();

            await _clearSession();
          }
        }
      } else {
        _stopHeartbeat();
      }
    });
  }

  // ✅ Session kapatıldığında - sadece log bas
  // UI otomatik olarak login sayfasına yönlenecek
  void _showSessionExpiredDialog() {
    print('🚨 SESSION EXPIRED - Kullanıcı başka bir cihazdan giriş yaptı');
  }

  void _stopHeartbeat() {
    if (_heartbeatTimer != null) {
      print('🔴 [HEARTBEAT] Stopping heartbeat timer');
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
    }
  }

  Future<void> fetchUserInfo() async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final val = await _authService.getinfo(_token!);

      if (val != null && val.data["success"] == true) {
        _userData = val.data;
        print('✅ User info fetched successfully');
      } else if (val != null && val.data["sessionExpired"] == true) {
        print('⚠️ Session expired - logged in from another device');
        await _clearSession();
      } else {
        _userData = null;
      }
    } catch (e) {
      print('❌ Error fetching user info: $e');

      // ✅ 401 hatası kontrolü
      if (e.toString().contains('401') || e.toString().contains('sessionExpired')) {
        await _clearSession();
      }

      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ HER API İSTEĞİNDE 401 kontrolü yap
  Future<void> _handleApiError(dynamic error) async {
    if (error.toString().contains('401') ||
        error.toString().contains('sessionExpired') ||
        error.toString().contains('Session expired')) {
      print('⚠️ API Error: Session kapatılmış, logout yapılıyor');
      await _clearSession();
    }
  }

  Future<void> updatePracticeSolved(int index, bool solved) async {
    if (_token == null || _userData == null) return;

    try {
      List<bool> updated = List<bool>.from(_userData!['practicesSolved']);
      updated[index] = solved;

      await _authService.updatePracticesSolved(_token!, updated);

      _userData!['practicesSolved'] = updated;
      notifyListeners();
    } catch (e) {
      print('❌ Error updating practice: $e');
      await _handleApiError(e);
    }
  }

  Future<bool> updatePracticeTestResult({
    required int testNumber,
    required double correctAnswers,
    required double wrongAnswers,
    required double emptyAnswers,
    required double score,
  }) async {
    if (_token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.updatePracticeTestResults(
        token: _token!,
        testNumber: testNumber,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        emptyAnswers: emptyAnswers,
        score: score,
      );

      if (response != null && response['success'] == true) {
        _userData!['practiceTestResults'] = response['practiceTestResults'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating test results: $e');
      await _handleApiError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPracticeTestResults() async {
    if (_token == null) return;

    try {
      final val = await _authService.getPracticeTestResults(_token!);

      if (val != null && val.data["success"] == true) {
        _userData!['practiceTestResults'] = val.data['practiceTestResults'];
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error fetching test results: $e');
      await _handleApiError(e);
    }
  }

  Future<bool> deletePracticeTestResult(int testNumber) async {
    if (_token == null) return false;

    try {
      final val = await _authService.deletePracticeTestResult(
        token: _token!,
        testNumber: testNumber,
      );

      if (val != null && val.data["success"] == true) {
        _userData!['practiceTestResults'] = val.data['practiceTestResults'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting test result: $e');
      await _handleApiError(e);
      return false;
    }
  }

  Map<String, dynamic>? getResultForTest(int testNumber) {
    try {
      return practiceTestResults.firstWhere(
            (result) => result['testNumber'] == testNumber,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await _authService.logout(_token!);
        print('🔴 Logout başarılı - session temizlendi');
      } catch (e) {
        print('⚠️ Logout hatası: $e');
      }
    }

    await _clearSession();
  }

  Future<void> refresh() async {
    await fetchUserInfo();
  }

  @override
  void dispose() {
    _stopHeartbeat();
    super.dispose();
  }
}