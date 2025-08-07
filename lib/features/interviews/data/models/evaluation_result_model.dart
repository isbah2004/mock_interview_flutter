

import 'package:mock_interview/core/entities/evaluation_result.dart';
import 'package:mock_interview/features/interviews/data/models/question_result_model.dart';

class EvaluationResultModel extends EvaluationResult {
  const EvaluationResultModel({
    required super.sessionId,
    required super.totalQuestions,
    required super.results,
    required super.finalScore,
    required super.percentage,
    required super.passed,
    required super.sessionComplete,
    required super.completedAt,
  });

  factory EvaluationResultModel.fromJson(Map<String, dynamic> json) {
    return EvaluationResultModel(
      sessionId: json['session_id'] as String,
      totalQuestions: json['total_questions'] as int,
      results: (json['results'] as List)
          .map((r) => QuestionResultModel.fromJson(r))
          .toList(),
      finalScore: (json['final_score'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      passed: json['passed'] as bool,
      sessionComplete: json['session_complete'] as bool,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['completed_at'] as num).toInt() * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'total_questions': totalQuestions,
      'results': results.map((r) => (r as QuestionResultModel).toJson()).toList(),
      'final_score': finalScore,
      'percentage': percentage,
      'passed': passed,
      'session_complete': sessionComplete,
      'completed_at': completedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}

