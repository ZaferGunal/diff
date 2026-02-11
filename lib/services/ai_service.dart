import 'package:dio/dio.dart';
import '../models/ai_chat_message.dart';

class AIService {
  final Dio dio = Dio();
  final String baseUrl = "https://testauth-153e5c716660.herokuapp.com";

  // İlk analiz
  Future<Map<String, dynamic>?> analyzeQuestion({
    required String token,
    required String questionImageUrl,
  }) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";

      final response = await dio.post(
        "$baseUrl/ai/analyze-question",
        data: {
          "questionImageUrl": questionImageUrl,
          "conversationHistory": []
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'analysis': response.data['analysis'],
          'usage': response.data['usage'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['msg'] ?? 'Analysis failed'
        };
      }
    } catch (e) {
      print('❌ AI Analysis Error: $e');
      return {
        'success': false,
        'message': 'Failed to analyze question: $e'
      };
    }
  }

  // Chat devam
  Future<Map<String, dynamic>?> chatWithAI({
    required String token,
    required String questionImageUrl,
    required String userMessage,
    required List<AIChatMessage> conversationHistory,
  }) async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";

      final response = await dio.post(
        "$baseUrl/ai/chat",
        data: {
          "questionImageUrl": questionImageUrl,
          "userMessage": userMessage,
          "conversationHistory": conversationHistory.map((msg) => {
            "role": msg.isUser ? "user" : "model",
            "text": msg.text
          }).toList()
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'response': response.data['response'],
          'usage': response.data['usage'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['msg'] ?? 'Chat failed'
        };
      }
    } catch (e) {
      print('❌ AI Chat Error: $e');
      return {
        'success': false,
        'message': 'Failed to send message: $e'
      };
    }
  }
}