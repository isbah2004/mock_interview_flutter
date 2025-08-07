// lib/features/interview/domain/entities/evaluation_result.dart
import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/entities/question_result.dart';

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
