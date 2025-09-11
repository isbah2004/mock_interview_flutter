import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mock_interview/core/utils/app_logger.dart';

class OpenRouterApiService {
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _apiKey =
      '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';
  static const String _model = 'google/gemini-2.0-flash-001';

  static Future<String> generateText({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 4000,
  }) async {
    try {
      AppLogger.info(
        'OpenRouter API: Sending request with prompt length: ${prompt.length}',
      );

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout: API took too long to respond');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        AppLogger.info('OpenRouter API: Successfully received response');
        return content;
      } else {
        AppLogger.error(
          'OpenRouter API Error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('OpenRouter API Exception: $e');
      rethrow;
    }
  }

  static Future<String> generateTextWithImages({
    required String prompt,
    required List<String> imageUrls,
    double temperature = 0.7,
    int maxTokens = 4000,
  }) async {
    try {
      AppLogger.info(
        'OpenRouter API: Sending request with images. Prompt length: ${prompt.length}, Images: ${imageUrls.length}',
      );

      List<Map<String, dynamic>> content = [
        {'type': 'text', 'text': prompt},
      ];

      // Add images to content
      for (String imageUrl in imageUrls) {
        content.add({
          'type': 'image_url',
          'image_url': {'url': imageUrl},
        });
      }

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': content},
              ],
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout: API took too long to respond');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseContent =
            data['choices'][0]['message']['content'] as String;
        AppLogger.info(
          'OpenRouter API: Successfully received response with images',
        );
        return responseContent;
      } else {
        AppLogger.error(
          'OpenRouter API Error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('OpenRouter API Exception: $e');
      rethrow;
    }
  }
}
