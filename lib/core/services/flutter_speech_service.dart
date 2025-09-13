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

  bool _isSpeaking = false;
  bool _isPaused = false;
  String? _currentSpeechText;
  VoidCallback? _currentOnComplete;

  // For pause/resume functionality
  List<String> _speechChunks = [];
  int _currentChunkIndex = 0;
  Timer? _speechProgressTimer;
  DateTime? _speechStartTime;
  Duration _pausedDuration = Duration.zero;

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
    await _tts.setSpeechRate(0.4);
  }

  @override
  Future<void> startListening({
    required Function(String) onResult,
    required VoidCallback onComplete,
  }) async {
    if (_isListening) {
      stopListening();
    }

    _isListening = true;
    _onResult = onResult;
    _onCompleteCallback = onComplete;

    try {
      await _speech.listen(
        onResult: (result) {
          try {
            if (kDebugMode) {
              print(
                'STT Result: "${result.recognizedWords}", Final: ${result.finalResult}, HasSound: ${result.hasConfidenceRating}',
              );
            }

            _onResult?.call(result.recognizedWords);
            _resetSilenceTimer();

            if (result.finalResult &&
                result.recognizedWords.trim().isNotEmpty) {
              // For final results, use a longer silence timer to give user time to continue
              _startSilenceTimer(duration: const Duration(seconds: 4));
            } else if (result.recognizedWords.trim().isNotEmpty) {
              // For partial results, use shorter timer
              _startSilenceTimer(duration: const Duration(seconds: 2));
            }
          } catch (e) {
            if (kDebugMode) {
              print('STT onResult error: $e');
            }
          }
        },
        listenFor: const Duration(minutes: 10),
        pauseFor: const Duration(seconds: 8),
        partialResults: true,
        localeId: 'en-US',
      );
    } catch (e) {
      _isListening = false;
      _onCompleteCallback?.call();
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
  }

  void _startSilenceTimer({Duration duration = const Duration(seconds: 3)}) {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(duration, () {
      if (_isListening) {
        _completeListening();
      }
    });
  }

  void _completeListening() {
    if (!_isListening) return;

    if (kDebugMode) {
      print('STT: Completing listening session');
    }

    _isListening = false;
    _silenceTimer?.cancel();
    _silenceTimer = null;

    try {
      _speech.stop();
    } catch (e) {
      if (kDebugMode) {
        print('STT: Error stopping speech: $e');
      }
    }

    // Small delay to ensure any final results are processed
    Future.delayed(const Duration(milliseconds: 200), () {
      try {
        _onCompleteCallback?.call();
      } catch (e) {
        if (kDebugMode) {
          print('STT: Error in completion callback: $e');
        }
      }
    });
  }

  @override
  void stopListening() {
    _completeListening();
  }

  @override
  Future<void> speak(String text, {VoidCallback? onComplete}) async {
    try {
      await _tts.stop();
      _resetSpeechState();

      _currentSpeechText = text;
      _currentOnComplete = onComplete;
      _isSpeaking = true;
      _isPaused = false;

      // Split text into chunks for better pause/resume control
      _speechChunks = _splitTextIntoChunks(text);
      _currentChunkIndex = 0;
      _speechStartTime = DateTime.now();
      _pausedDuration = Duration.zero;

      await _speakFromCurrentChunk();
    } catch (e) {
      _resetSpeechState();
      if (onComplete != null) {
        onComplete();
      }
    }
  }

  List<String> _splitTextIntoChunks(String text) {
    // Split by sentences first, then by length if sentences are too long
    List<String> sentences = text.split(RegExp(r'[.!?]+'));
    List<String> chunks = [];

    for (String sentence in sentences) {
      sentence = sentence.trim();
      if (sentence.isEmpty) continue;

      if (sentence.length <= 100) {
        chunks.add('$sentence.');
      } else {
        // Split long sentences by commas or spaces
        List<String> parts = sentence.split(RegExp(r'[,;]+'));
        for (String part in parts) {
          part = part.trim();
          if (part.isNotEmpty) {
            if (part.length <= 100) {
              chunks.add('$part,');
            } else {
              // Further split by words if still too long
              List<String> words = part.split(' ');
              String currentChunk = '';
              for (String word in words) {
                if (('$currentChunk $word').length <= 100) {
                  currentChunk += (currentChunk.isEmpty ? '' : ' ') + word;
                } else {
                  if (currentChunk.isNotEmpty) {
                    chunks.add(currentChunk);
                    currentChunk = word;
                  } else {
                    chunks.add(word);
                  }
                }
              }
              if (currentChunk.isNotEmpty) {
                chunks.add(currentChunk);
              }
            }
          }
        }
      }
    }

    return chunks.where((chunk) => chunk.trim().isNotEmpty).toList();
  }

  Future<void> _speakFromCurrentChunk() async {
    if (_currentChunkIndex >= _speechChunks.length || !_isSpeaking) {
      // All chunks completed
      _completeSpeech();
      return;
    }

    if (_isPaused) return;

    try {
      bool chunkCompleted = false;

      _tts.setCompletionHandler(() {
        if (!chunkCompleted && !_isPaused) {
          chunkCompleted = true;
          _currentChunkIndex++;
          // Continue to next chunk
          Future.delayed(const Duration(milliseconds: 100), () {
            _speakFromCurrentChunk();
          });
        }
      });

      _tts.setErrorHandler((message) {
        if (kDebugMode) {
          print('TTS Error: $message');
        }
        _completeSpeech();
      });

      await _tts.speak(_speechChunks[_currentChunkIndex]);
    } catch (e) {
      if (kDebugMode) {
        print('TTS Speak Error: $e');
      }
      _completeSpeech();
    }
  }

  void _completeSpeech() {
    if (!_isSpeaking) return;

    _isSpeaking = false;
    _isPaused = false;

    if (_currentOnComplete != null) {
      final callback = _currentOnComplete;
      _resetSpeechState();
      callback!();
    } else {
      _resetSpeechState();
    }
  }

  void _resetSpeechState() {
    _speechProgressTimer?.cancel();
    _speechProgressTimer = null;
    _speechChunks.clear();
    _currentChunkIndex = 0;
    _speechStartTime = null;
    _pausedDuration = Duration.zero;
    _currentSpeechText = null;
    _currentOnComplete = null;
  }

  @override
  Future<void> pauseSpeaking() async {
    try {
      if (_isSpeaking && !_isPaused) {
        await _tts.stop(); // Stop current chunk
        _isPaused = true;

        if (kDebugMode) {
          print(
            'TTS Paused at chunk $_currentChunkIndex/${_speechChunks.length}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('TTS Pause Error: $e');
      }
    }
  }

  @override
  Future<void> resumeSpeaking() async {
    try {
      if (_isSpeaking && _isPaused) {
        _isPaused = false;

        if (kDebugMode) {
          print(
            'TTS Resuming from chunk $_currentChunkIndex/${_speechChunks.length}',
          );
        }

        // Resume from current chunk
        await _speakFromCurrentChunk();
      }
    } catch (e) {
      if (kDebugMode) {
        print('TTS Resume Error: $e');
      }
      _isPaused = false;
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();

      if (_currentOnComplete != null) {
        final callback = _currentOnComplete;
        _resetSpeechState();
        _isSpeaking = false;
        _isPaused = false;
        callback!();
      } else {
        _resetSpeechState();
        _isSpeaking = false;
        _isPaused = false;
      }
    } catch (e) {
      _resetSpeechState();
      _isSpeaking = false;
      _isPaused = false;
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _speechProgressTimer?.cancel();
    _speechProgressTimer = null;

    _speech.cancel();
    _tts.stop();
    _tts.setCompletionHandler(() {});

    _onCompleteCallback = null;
    _onResult = null;
    _isListening = false;
    _isSpeaking = false;
    _isPaused = false;

    _resetSpeechState();
  }
}
