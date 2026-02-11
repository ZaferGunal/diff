import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'authservice.dart';

class FlashcardProgressService {
  static const String _progressKeyPrefix = "flashcard_progress_";
  final AuthService _authService = AuthService();

  // Status Constants
  static const String statusUnknown = 'Unknown';
  static const String statusPracticing = 'Practicing';
  static const String statusMastered = 'Mastered';

  // Save progress: Local first, then DB (Fire and forget DB sync)
  Future<void> saveProgress(String userEmail, String cardId, String status) async {
    if (userEmail.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String userKey = "$_progressKeyPrefix$userEmail";
    
    // 1. Save Locally
    Map<String, String> localProgress = await _getLocalProgress(userEmail);
    localProgress[cardId] = status;
    
    final String encoded = jsonEncode(localProgress);
    await prefs.setString(userKey, encoded);

    // 2. Sync with DB
    try {
      await _authService.saveFlashcardProgress(userEmail, cardId, status);
    } catch (e) {
      print("⚠️ [FlashcardProgressService] DB Sync failed: $e");
    }
  }

  // Get all progress: Fetch from DB, fallback to local
  Future<Map<String, String>> getAllProgress(String userEmail) async {
    if (userEmail.isEmpty) return {};

    final prefs = await SharedPreferences.getInstance();
    final String userKey = "$_progressKeyPrefix$userEmail";

    // 1. Try DB first
    try {
      final response = await _authService.getFlashcardProgress(userEmail);
      if (response.statusCode == 200 && response.data['success']) {
        Map<String, dynamic> dbProgress = response.data['progress'];
        Map<String, String> finalMap = dbProgress.map((key, value) => MapEntry(key, value.toString()));
        
        // Update local cache with DB data
        await prefs.setString(userKey, jsonEncode(finalMap));
        
        return finalMap;
      }
    } catch (e) {
      print("⚠️ [FlashcardProgressService] DB Fetch failed, using local cache: $e");
    }

    // 2. Fallback to Local
    return await _getLocalProgress(userEmail);
  }

  Future<Map<String, String>> _getLocalProgress(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final String userKey = "$_progressKeyPrefix$userEmail";
    final String? data = prefs.getString(userKey);
    
    if (data == null) return {};
    try {
      Map<String, dynamic> decoded = jsonDecode(data);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }
}
