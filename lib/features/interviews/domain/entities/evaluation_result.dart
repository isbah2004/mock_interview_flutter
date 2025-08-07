// lib/features/interview/domain/entities/evaluation_result.dart
import 'package:equatable/equatable.dart';

class EvaluationResult extends Equatable {
  final String sessionId;
  final int totalQuestions;
  final List<QuestionResult> results;
  final double finalScore;
  final double percentage;
  final bool passed;
  final bool sessionComplete;
  final DateTime completedAt;

  const EvaluationResult({
    required this.sessionId,
    required this.totalQuestions,
    required this.results,
    required this.finalScore,
    required this.percentage,
    required this.passed,
    required this.sessionComplete,
    required this.completedAt,
  });

  @override
  List<Object> get props => [
    sessionId,
    totalQuestions,
    results,
    finalScore,
    percentage,
    passed,
    sessionComplete,
    completedAt,
  ];
}

class QuestionResult extends Equatable {
  final int questionId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int score;
  final String explanation;

  const QuestionResult({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.score,
    required this.explanation,
  });

  @override
  List<Object> get props => [
    questionId,
    question,
    userAnswer,
    correctAnswer,
    isCorrect,
    score,
    explanation,
  ];
}
