import 'dart:ui';

import 'package:mock_interview/core/services/flutter_speech_service.dart';
class HandleSpeechUseCase {
  final SpeechService _speechService;

  HandleSpeechUseCase(this._speechService);

  Future<void> startListening({
    required Function(String) onResult,
    required VoidCallback onComplete,
  }) async {
    await _speechService.startListening(
      onResult: onResult,
      onComplete: onComplete,
    );
  }

  void stopListening() {
    _speechService.stopListening();
  }

  Future<void> speak(String text, {VoidCallback? onComplete}) async {
    await _speechService.speak(text, onComplete: onComplete);
  }
}
