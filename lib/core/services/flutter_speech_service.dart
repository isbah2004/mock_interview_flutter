import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

abstract class SpeechService {
  Future<void> initialize();

  Future<void> startListening({
    required Function(String) onResult,
    required VoidCallback onComplete,
  });

  void stopListening();

  Future<void> speak(String text, {VoidCallback? onComplete});

  void dispose();
}

class FlutterSpeechService implements SpeechService {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  Timer? _silenceTimer;
  bool _isListening = false;
  VoidCallback? _onCompleteCallback;
  Function(String)? _onResult;

  @override
  Future<void> initialize() async {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    await _speech.initialize();
    await _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  @override
  Future<void> startListening({
    required Function(String) onResult,
    required VoidCallback onComplete,
  }) async {
    if (_isListening) {
      debugPrint('Already listening, stopping current session first');
      stopListening();
    }

    _isListening = true;
    _onResult = onResult;
    _onCompleteCallback = onComplete;

    try {
      await _speech.listen(
        onResult: (result) {
          try {
            _onResult?.call(result.recognizedWords);

            // Reset the silence timer whenever we get new speech
            _resetSilenceTimer();

            // Only auto-complete if there's been silence for a while after speech
            if (result.finalResult &&
                result.recognizedWords.trim().isNotEmpty) {
              _startSilenceTimer();
            }
          } catch (e) {
            debugPrint('Error in speech result callback: $e');
          }
        },
        listenFor: const Duration(minutes: 10), // Extended listening time
        pauseFor: const Duration(seconds: 10), // Longer pause detection
        partialResults: true, // Enable partial results for real-time feedback
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _isListening = false;
      _onCompleteCallback?.call();
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 3), () {
      if (_isListening) {
        _completeListening();
      }
    });
  }

  void _completeListening() {
    if (!_isListening) return; // Prevent multiple calls

    _isListening = false;
    _silenceTimer?.cancel();
    _silenceTimer = null;

    try {
      _speech.stop();
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    }

    try {
      _onCompleteCallback?.call();
    } catch (e) {
      debugPrint('Error in speech completion callback: $e');
    }
  }

  @override
  void stopListening() {
    _completeListening();
  }

  @override
  Future<void> speak(String text, {VoidCallback? onComplete}) async {
    try {
      // Set completion handler safely
      if (onComplete != null) {
        _tts.setCompletionHandler(() {
          // Ensure callback is called only once and safely
          try {
            onComplete();
          } catch (e) {
            debugPrint('Error in TTS completion callback: $e');
          }
        });
      } else {
        _tts.setCompletionHandler(() {});
      }

      await _tts.speak(text);
    } catch (e) {
      debugPrint('Error in TTS speak: $e');
      // Call completion callback even if speaking fails
      if (onComplete != null) {
        onComplete();
      }
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _speech.cancel();
    _tts.stop();
    // Clear completion handler to prevent callbacks after disposal
    _tts.setCompletionHandler(() {});
    _onCompleteCallback = null;
    _onResult = null;
    _isListening = false;
  }
}
