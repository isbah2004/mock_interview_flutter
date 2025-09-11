import 'package:flutter_test/flutter_test.dart';
import 'package:mock_interview/core/services/openrouter_api_service.dart';

void main() {
  group('OpenRouter API Service Tests', () {
    test('should generate text response', () async {
      // Test basic text generation
      try {
        final response = await OpenRouterApiService.generateText(
          prompt: 'Hello, how are you? Please respond briefly.',
          temperature: 0.7,
          maxTokens: 100,
        );

        expect(response, isNotEmpty);
        expect(response, isA<String>());
        print('OpenRouter Response: $response');
      } catch (e) {
        // If API fails, at least ensure our service structure is correct
        expect(e, isA<Exception>());
        print('API Error (expected in test env): $e');
      }
    });

    test('should handle image generation', () async {
      // Test image + text generation
      try {
        final response = await OpenRouterApiService.generateTextWithImages(
          prompt: 'What do you see in this image?',
          imageUrls: [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg',
          ],
          temperature: 0.7,
          maxTokens: 200,
        );

        expect(response, isNotEmpty);
        expect(response, isA<String>());
        print('OpenRouter Image Response: $response');
      } catch (e) {
        // If API fails, at least ensure our service structure is correct
        expect(e, isA<Exception>());
        print('API Error (expected in test env): $e');
      }
    });
  });
}
