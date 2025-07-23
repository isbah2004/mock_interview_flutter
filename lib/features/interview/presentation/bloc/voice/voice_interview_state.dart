import 'package:equatable/equatable.dart';
import '../../../../../core/entities/question.dart';

abstract class VoiceInterviewState extends Equatable {
  const VoiceInterviewState();

  @override
  List<Object?> get props => [];
}

class VoiceInterviewInitial extends VoiceInterviewState {}

class VoiceInterviewLoading extends VoiceInterviewState {}

class VoiceInterviewStarted extends VoiceInterviewState {
  final Question currentQuestion;
  final String sessionId;
  final bool isListening;
  final bool isRecording;

  const VoiceInterviewStarted({
    required this.currentQuestion,
    required this.sessionId,
    required this.isListening,
    required this.isRecording,
  });

  @override
  List<Object?> get props => [
    currentQuestion,
    sessionId,
    isListening,
    isRecording,
  ];

  VoiceInterviewStarted copyWith({
    Question? currentQuestion,
    String? sessionId,
    bool? isListening,
    bool? isRecording,
  }) {
    return VoiceInterviewStarted(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      sessionId: sessionId ?? this.sessionId,
      isListening: isListening ?? this.isListening,
      isRecording: isRecording ?? this.isRecording,
    );
  }
}

class VoiceInterviewQuestionReceived extends VoiceInterviewState {
  final Question question;
  final String sessionId;

  const VoiceInterviewQuestionReceived({
    required this.question,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [question, sessionId];
}

class VoiceInterviewAnswerSubmitting extends VoiceInterviewState {
  final Question currentQuestion;
  final String sessionId;
  final String answer;

  const VoiceInterviewAnswerSubmitting({
    required this.currentQuestion,
    required this.sessionId,
    required this.answer,
  });

  @override
  List<Object?> get props => [currentQuestion, sessionId, answer];
}

class VoiceInterviewCompleted extends VoiceInterviewState {
  final String sessionId;
  final double score;
  final int totalQuestions;
  final String feedback;

  const VoiceInterviewCompleted({
    required this.sessionId,
    required this.score,
    required this.totalQuestions,
    required this.feedback,
  });

  @override
  List<Object?> get props => [sessionId, score, totalQuestions, feedback];
}

class VoiceInterviewError extends VoiceInterviewState {
  final String message;

  const VoiceInterviewError(this.message);

  @override
  List<Object?> get props => [message];
}
