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

  Future<void> pauseSpeaking();

  Future<void> resumeSpeaking();

  Future<void> stopSpeaking();

  void dispose();
}

class FlutterSpeechService implements SpeechService {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  Timer? _silenceTimer;
  bool _isListening = false;
  VoidCallback? _onCompleteCallback;
  Function(String)? _onResult;

  // TTS pause/resume functionality
  bool _isSpeaking = false;
  bool _isPaused = false;
  String? _currentSpeechText;
  VoidCallback? _currentOnComplete;

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
    await _tts.setSpeechRate(0.4); // Slower speech rate for better testing
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
      debugPrint(
        'FlutterSpeechService: Starting TTS for: ${text.substring(0, text.length > 50 ? 50 : text.length)}...',
      );

      // Stop any ongoing TTS first
      await _tts.stop();

      // Store current speech details for pause/resume functionality
      _currentSpeechText = text;
      _currentOnComplete = onComplete;
      _isSpeaking = true;
      _isPaused = false;

      // Set completion handler safely
      bool completionCalled = false;

      if (onComplete != null) {
        _tts.setCompletionHandler(() {
          // Ensure callback is called only once and safely
          if (!completionCalled && !_isPaused) {
            completionCalled = true;
            _isSpeaking = false;
            _currentSpeechText = null;
            _currentOnComplete = null;
            debugPrint('FlutterSpeechService: TTS completion handler called');
            try {
              onComplete();
            } catch (e) {
              debugPrint('Error in TTS completion callback: $e');
            }
          }
        });
      } else {
        _tts.setCompletionHandler(() {
          if (!_isPaused) {
            _isSpeaking = false;
            _currentSpeechText = null;
          }
        });
      }

      // Set error handler
      _tts.setErrorHandler((message) {
        debugPrint('FlutterSpeechService: TTS error: $message');
        if (!completionCalled && onComplete != null && !_isPaused) {
          completionCalled = true;
          _isSpeaking = false;
          _currentSpeechText = null;
          _currentOnComplete = null;
          onComplete();
        }
      });

      await _tts.speak(text);
      debugPrint('FlutterSpeechService: TTS speak method completed');
    } catch (e) {
      debugPrint('Error in TTS speak: $e');
      _isSpeaking = false;
      _isPaused = false;
      _currentSpeechText = null;
      _currentOnComplete = null;
      // Call completion callback even if speaking fails
      if (onComplete != null) {
        onComplete();
      }
    }
  }

  @override
  Future<void> pauseSpeaking() async {
    try {
      if (_isSpeaking && !_isPaused) {
        await _tts.pause();
        _isPaused = true;
        debugPrint('FlutterSpeechService: TTS paused');
      }
    } catch (e) {
      debugPrint('Error pausing TTS: $e');
    }
  }

  @override
  Future<void> resumeSpeaking() async {
    try {
      if (_isSpeaking && _isPaused) {
        // Flutter TTS pause/resume may not work reliably on all platforms
        // So we restart the speech if needed
        if (_currentSpeechText != null) {
          _isPaused = false;
          debugPrint('FlutterSpeechService: TTS resuming');
          // Try to resume, if that fails, restart the speech
          await _tts.speak(_currentSpeechText!);
        }
      }
    } catch (e) {
      debugPrint('Error resuming TTS: $e');
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
      _isPaused = false;

      // Call completion callback if stopping manually
      if (_currentOnComplete != null) {
        final callback = _currentOnComplete;
        _currentOnComplete = null;
        _currentSpeechText = null;
        callback!();
      } else {
        _currentSpeechText = null;
      }

      debugPrint('FlutterSpeechService: TTS stopped');
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
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

    // Clean up TTS pause/resume state
    _isSpeaking = false;
    _isPaused = false;
    _currentSpeechText = null;
    _currentOnComplete = null;
  }
}
