import 'package:equatable/equatable.dart';
import '../../../../../core/entities/question.dart';

abstract class McqInterviewState extends Equatable {
  const McqInterviewState();

  @override
  List<Object?> get props => [];
}

class McqInterviewInitial extends McqInterviewState {}

class McqInterviewLoading extends McqInterviewState {}

class McqInterviewStarted extends McqInterviewState {
  final Question currentQuestion;
  final String sessionId;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int correctAnswers;

  const McqInterviewStarted({
    required this.currentQuestion,
    required this.sessionId,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  List<Object?> get props => [
    currentQuestion,
    sessionId,
    currentQuestionIndex,
    totalQuestions,
    correctAnswers,
  ];

  McqInterviewStarted copyWith({
    Question? currentQuestion,
    String? sessionId,
    int? currentQuestionIndex,
    int? totalQuestions,
    int? correctAnswers,
  }) {
    return McqInterviewStarted(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      sessionId: sessionId ?? this.sessionId,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }
}

class McqInterviewAnswerSubmitting extends McqInterviewState {
  final Question currentQuestion;
  final String sessionId;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int correctAnswers;

  const McqInterviewAnswerSubmitting({
    required this.currentQuestion,
    required this.sessionId,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  List<Object?> get props => [
    currentQuestion,
    sessionId,
    currentQuestionIndex,
    totalQuestions,
    correctAnswers,
  ];
}

class McqInterviewFeedback extends McqInterviewState {
  final Question currentQuestion;
  final Question? nextQuestion;
  final String sessionId;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int correctAnswers;
  final String feedback;
  final double score;
  final bool isCorrect;
  final bool isLastQuestion;

  const McqInterviewFeedback({
    required this.currentQuestion,
    this.nextQuestion,
    required this.sessionId,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.feedback,
    required this.score,
    required this.isCorrect,
    required this.isLastQuestion,
  });

  @override
  List<Object?> get props => [
    currentQuestion,
    nextQuestion,
    sessionId,
    currentQuestionIndex,
    totalQuestions,
    correctAnswers,
    feedback,
    score,
    isCorrect,
    isLastQuestion,
  ];
}

class McqInterviewCompleted extends McqInterviewState {
  final String sessionId;
  final int totalQuestions;
  final int correctAnswers;
  final double finalScore;

  const McqInterviewCompleted({
    required this.sessionId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.finalScore,
  });

  @override
  List<Object?> get props => [
    sessionId,
    totalQuestions,
    correctAnswers,
    finalScore,
  ];
}

class McqInterviewError extends McqInterviewState {
  final String message;

  const McqInterviewError(this.message);

  @override
  List<Object?> get props => [message];
}
