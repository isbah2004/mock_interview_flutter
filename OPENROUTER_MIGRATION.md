# OpenRouter API Integration

This project has been migrated from Google Generative AI (google_generative_ai package) to OpenRouter API using HTTP requests.

## What Changed

### Removed Dependencies

- `google_generative_ai: ^0.4.7` - Removed from pubspec.yaml

### Added Dependencies

- `http: ^1.2.1` - For making HTTP requests to OpenRouter API

### New Files

- `lib/core/services/openrouter_api_service.dart` - Core service for OpenRouter API integration

### Updated Services

- `lib/core/services/gemini_ai_service/voice_interview_service.dart` - Updated to use OpenRouter
- `lib/core/services/gemini_ai_service/mcq_generation_service.dart` - Updated to use OpenRouter
- `lib/core/services/gemini_ai_service/mcq_evaluation_service.dart` - Updated to use OpenRouter

## API Configuration

The OpenRouter service is configured with:

- **Base URL**: `https://openrouter.ai/api/v1/chat/completions`
- **Model**: `google/gemini-2.0-flash-001` (Gemini 2.0 Flash via OpenRouter)
- **API Key**: `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`

## Features

### Text Generation

```dart
final response = await OpenRouterApiService.generateText(
  prompt: 'Your prompt here',
  temperature: 0.7,
  maxTokens: 4000,
);
```

### Image + Text Generation

```dart
final response = await OpenRouterApiService.generateTextWithImages(
  prompt: 'What is in this image?',
  imageUrls: ['https://example.com/image.jpg'],
  temperature: 0.7,
  maxTokens: 4000,
);
```

## Benefits

1. **Better Model Access**: Using Gemini 2.0 Flash (latest version)
2. **Unified API**: Single endpoint for all AI operations
3. **Enhanced Logging**: Comprehensive logging with AppLogger
4. **Error Handling**: Robust error handling for various HTTP status codes
5. **Image Support**: Native support for image + text prompts

## Testing

Run the OpenRouter API tests:

```bash
flutter test test/openrouter_api_test.dart
```

## Migration Notes

- All existing functionality remains the same from the app's perspective
- Conversation history is now maintained manually in the service layer
- Temperature and token limits are configurable per request
- Error handling covers HTTP status codes (400, 401, 429, 503, etc.)
- All services use the same OpenRouter endpoint for consistency

The migration maintains backward compatibility while providing access to the latest AI models through OpenRouter's unified API.
