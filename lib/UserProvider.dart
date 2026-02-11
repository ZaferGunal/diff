import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled5/services/authservice.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  Timer? _heartbeatTimer;
  bool _isSessionExpired = false; // ✅ YENİ

  final AuthService _authService = AuthService();

  // BASIC GETTERS
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _userData != null && !_isSessionExpired; // ✅ DEĞİŞTİ
  bool get isSessionExpired => _isSessionExpired; // ✅ YENİ

  String? get userId => _userData?['_id']?.toString();
  String? get name => _userData?['name'];
  String? get email => _userData?['email'];
  bool get isDarkMode => _userData?['isDarkMode'] ?? false;
  bool get isLoggedIn => _userData?['isLoggedIn'] ?? false;

  // BOCCONI PACKAGE GETTERS
  bool get hasBocconiPackage => _userData?['hasBocconiPackage'] ?? false;

  DateTime? get bocconiPackageExpiryDate {
    if (_userData?['bocconiPackageExpiryDate'] == null) return null;
    try {
      return DateTime.parse(_userData!['bocconiPackageExpiryDate']);
    } catch (e) {
      return null;
    }
  }

  List<bool> get practicesSolved {
    if (_userData?['practicesSolved'] == null) return [false, false, false, false];
    return List<bool>.from(_userData!['practicesSolved']);
  }

  List<Map<String, dynamic>> get practiceTestResults {
    if (_userData?['practiceTestResults'] == null) return [];
    return List<Map<String, dynamic>>.from(_userData!['practiceTestResults']);
  }

  // TILI PACKAGE GETTERS
  bool get hasTiliPackage => _userData?['hasTiliPackage'] ?? false;
  String? get tiliPackageTier => _userData?['tiliPackageTier'];

  DateTime? get tiliPackageExpiryDate {
    if (_userData?['tiliPackageExpiryDate'] == null) return null;
    try {
      return DateTime.parse(_userData!['tiliPackageExpiryDate']);
    } catch (e) {
      return null;
    }
  }

  bool isTiliBasicPackage() => tiliPackageTier == 'basic';
  bool isTiliPremiumPackage() => tiliPackageTier == 'premium';

  // SESSION MANAGEMENT
  Future<void> checkPreviousSession() async {
    final prefs = await SharedPreferences.getInstance();
    final oldToken = prefs.getString('auth_token');

    if (oldToken != null) {
      print('⚠️ [SESSION] Checking previous session...');

      try {
        _token = oldToken;
        _isSessionExpired = false; // ✅ YENİ

        final val = await _authService.getinfo(oldToken);

        if (val != null && val.data["success"] == true) {
          print('✅ [SESSION] Previous session is valid');
          _userData = val.data;
          _startHeartbeat();
          notifyListeners();
        } else {
          print('⚠️ [SESSION] Previous token invalid - clearing');
          await _clearSession();
        }
      } catch (e) {
        print('❌ [SESSION] Check error: $e');
        await _clearSession();
      }
    } else {
      print('✅ [SESSION] No previous session');
    }
  }

  Future<void> _clearSession() async {
    print('🔴 [SESSION] Clearing session...');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _token = null;
    _userData = null;
    _isSessionExpired = false; // ✅ YENİ

    _stopHeartbeat();

    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;
    _isSessionExpired = false; // ✅ YENİ

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    _startHeartbeat();

    notifyListeners();
    await fetchUserInfo();
  }

  // ✅ IMPROVED HEARTBEAT SYSTEM
  void _startHeartbeat() {
    _stopHeartbeat();

    print('💓 [HEARTBEAT] Starting heartbeat timer (30s interval)...');

    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (_token != null && !_isSessionExpired) { // ✅ DEĞİŞTİ
        try {
          print('💓 [HEARTBEAT] Sending heartbeat...');
          final response = await _authService.heartbeat(_token!);

          if (response != null) {
            if (response.statusCode == 401) { // ✅ YENİ
              print('❌ [HEARTBEAT] 401 - Session expired');
              await _handleSessionExpired();
            } else if (response.data["success"] == true) {
              print('✅ [HEARTBEAT] OK');
            } else {
              print('⚠️ [HEARTBEAT] Unexpected response: ${response.data}');
            }
          }
        } catch (e) {
          print('⚠️ [HEARTBEAT] Failed: $e');

          // ✅ 401 veya session expired mesajı varsa
          if (e.toString().contains('401') ||
              e.toString().contains('Session expired') ||
              e.toString().contains('sessionExpired')) {
            print('❌ [HEARTBEAT] Session expired - forcing logout');
            await _handleSessionExpired();
          }
        }
      } else {
        print('🔴 [HEARTBEAT] No token or session expired - stopping timer');
        _stopHeartbeat();
      }
    });
  }

  // ✅ YENİ METHOD
  Future<void> _handleSessionExpired() async {
    if (_isSessionExpired) return; // Prevent multiple calls

    _isSessionExpired = true;
    print('🚨 [SESSION] Session expired - User logged in from another device');

    _stopHeartbeat();

    // Session'ı temizle
    await _clearSession();
  }

  void _stopHeartbeat() {
    if (_heartbeatTimer != null) {
      print('🔴 [HEARTBEAT] Stopping heartbeat timer');
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
    }
  }

  // USER INFO FETCHING
  Future<void> fetchUserInfo() async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final val = await _authService.getinfo(_token!);

      if (val != null && val.data["success"] == true) {
        _userData = val.data;
        _isSessionExpired = false; // ✅ YENİ

        print('✅ [USER INFO] Fetched successfully');
        print('📦 Bocconi Package: ${hasBocconiPackage}');
        print('📦 TILI Package: ${hasTiliPackage}');

        if (hasBocconiPackage) {
          print('   ⏰ Bocconi Expires: ${bocconiPackageExpiryDate}');
        }
        if (hasTiliPackage) {
          print('   📊 TILI Tier: ${tiliPackageTier}');
          print('   ⏰ TILI Expires: ${tiliPackageExpiryDate}');
        }
      } else if (val != null && val.data["sessionExpired"] == true) {
        print('⚠️ [USER INFO] Session expired');
        await _handleSessionExpired(); // ✅ DEĞİŞTİ
      } else {
        _userData = null;
      }
    } catch (e) {
      print('❌ [USER INFO] Error: $e');

      if (e.toString().contains('401') || e.toString().contains('sessionExpired')) {
        await _handleSessionExpired(); // ✅ DEĞİŞTİ
      }

      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleApiError(dynamic error) async {
    if (error.toString().contains('401') ||
        error.toString().contains('sessionExpired') ||
        error.toString().contains('Session expired')) {
      print('⚠️ [API ERROR] Session expired - forcing logout');
      await _handleSessionExpired(); // ✅ DEĞİŞTİ
    }
  }

  // PACKAGE ACTIVATION CHECKS
  bool isBocconiPackageActive() {
    if (!hasBocconiPackage) return false;
    if (bocconiPackageExpiryDate == null) return false;
    return DateTime.now().isBefore(bocconiPackageExpiryDate!);
  }

  bool isTiliPackageActive() {
    if (!hasTiliPackage) return false;
    if (tiliPackageExpiryDate == null) return false;
    return DateTime.now().isBefore(tiliPackageExpiryDate!);
  }

  int? getBocconiRemainingDays() {
    if (!isBocconiPackageActive()) return null;
    return bocconiPackageExpiryDate!.difference(DateTime.now()).inDays;
  }

  int? getTiliRemainingDays() {
    if (!isTiliPackageActive()) return null;
    return tiliPackageExpiryDate!.difference(DateTime.now()).inDays;
  }

  // BOCCONI PACKAGE METHODS
  Future<void> updatePracticeSolved(int index, bool solved) async {
    if (_token == null || _userData == null) return;

    try {
      List<bool> updated = List<bool>.from(_userData!['practicesSolved']);
      updated[index] = solved;

      await _authService.updatePracticesSolved(_token!, updated);

      _userData!['practicesSolved'] = updated;
      notifyListeners();
    } catch (e) {
      print('❌ [PRACTICE] Error updating: $e');
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
      print('❌ [TEST RESULT] Error: $e');
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
      print('❌ [TEST RESULTS] Error: $e');
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
      print('❌ [DELETE RESULT] Error: $e');
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

  // GENERAL METHODS
  Future<void> logout() async {
    if (_token != null) {
      try {
        await _authService.logout(_token!);
        print('🔴 [LOGOUT] Successful - session cleared');
      } catch (e) {
        print('⚠️ [LOGOUT] Error: $e');
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