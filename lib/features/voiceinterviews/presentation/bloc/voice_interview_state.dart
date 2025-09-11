import 'package:equatable/equatable.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/data/models/voice_interview_evaluation_result.dart';

abstract class VoiceInterviewState extends Equatable {
  const VoiceInterviewState();

  @override
  List<Object?> get props => [];
}

// Initial State
class VoiceInterviewInitial extends VoiceInterviewState {}

// Setup States
class VoiceInterviewSetupConfiguring extends VoiceInterviewState {
  final InterviewConfig config;
  final bool isValid;

  const VoiceInterviewSetupConfiguring(this.config, this.isValid);

  @override
  List<Object?> get props => [config, isValid];
}

class VoiceInterviewSetupReady extends VoiceInterviewState {
  final InterviewConfig config;

  const VoiceInterviewSetupReady(this.config);

  @override
  List<Object?> get props => [config];
}

// Interview Session States
class VoiceInterviewLoading extends VoiceInterviewState {}

class VoiceInterviewReady extends VoiceInterviewState {
  final InterviewSession session;
  final String? currentListeningText;
  final bool isListening;
  final bool isSpeaking;
  final bool isSpeakingPaused; // Added for TTS pause/play functionality
  final bool isProcessing;
  final String sessionId;

  const VoiceInterviewReady({
    required this.session,
    required this.sessionId,
    this.currentListeningText,
    this.isListening = false,
    this.isSpeaking = false,
    this.isSpeakingPaused = false,
    this.isProcessing = false,
  });

  @override
  List<Object?> get props => [
    session,
    sessionId,
    currentListeningText,
    isListening,
    isSpeaking,
    isSpeakingPaused,
    isProcessing,
  ];

  VoiceInterviewReady copyWith({
    InterviewSession? session,
    String? sessionId,
    String? currentListeningText,
    bool? isListening,
    bool? isSpeaking,
    bool? isSpeakingPaused,
    bool? isProcessing,
    bool clearListeningText = false,
  }) {
    return VoiceInterviewReady(
      session: session ?? this.session,
      sessionId: sessionId ?? this.sessionId,
      currentListeningText:
          clearListeningText
              ? null
              : (currentListeningText ?? this.currentListeningText),
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isSpeakingPaused: isSpeakingPaused ?? this.isSpeakingPaused,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

// Evaluation States
class VoiceInterviewEvaluating extends VoiceInterviewState {
  final InterviewSession session;
  final String sessionId;

  const VoiceInterviewEvaluating({
    required this.session,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [session, sessionId];
}

class VoiceInterviewEvaluated extends VoiceInterviewState {
  final VoiceInterviewEvaluationResult result;
  final InterviewSession session;
  final String sessionId;
  final bool shouldAnimateScore;

  const VoiceInterviewEvaluated({
    required this.result,
    required this.session,
    required this.sessionId,
    this.shouldAnimateScore = false,
  });

  @override
  List<Object?> get props => [result, session, sessionId, shouldAnimateScore];

  VoiceInterviewEvaluated copyWith({
    VoiceInterviewEvaluationResult? result,
    InterviewSession? session,
    String? sessionId,
    bool? shouldAnimateScore,
  }) {
    return VoiceInterviewEvaluated(
      result: result ?? this.result,
      session: session ?? this.session,
      sessionId: sessionId ?? this.sessionId,
      shouldAnimateScore: shouldAnimateScore ?? this.shouldAnimateScore,
    );
  }
}

// Error States
class VoiceInterviewError extends VoiceInterviewState {
  final String message;
  final String? sessionId;

  const VoiceInterviewError({required this.message, this.sessionId});

  @override
  List<Object?> get props => [message, sessionId];
}

class VoiceInterviewEvaluationError extends VoiceInterviewState {
  final String message;
  final InterviewSession session;
  final String sessionId;

  const VoiceInterviewEvaluationError({
    required this.message,
    required this.session,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [message, session, sessionId];
}
