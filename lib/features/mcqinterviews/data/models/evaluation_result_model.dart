import '../../../../core/entities/evaluation_result.dart';

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
      results:
          (json['results'] as List)
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
      'results':
          results.map((r) => (r as QuestionResultModel).toJson()).toList(),
      'final_score': finalScore,
      'percentage': percentage,
      'passed': passed,
      'session_complete': sessionComplete,
      'completed_at': completedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}

class QuestionResultModel extends QuestionResult {
  const QuestionResultModel({
    required super.questionId,
    required super.questionNumber,
    required super.question,
    required super.userAnswer,
    required super.correctAnswer,
    required super.isCorrect,
    required super.score,
    required super.explanation,
    required super.topic,
    required super.difficulty,
  });

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) {
    return QuestionResultModel(
      questionId: json['question_id'] as String,
      questionNumber: json['question_number'] as int,
      question: json['question'] as String,
      userAnswer: json['user_answer'] as String,
      correctAnswer: json['correct_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      score: json['score'] as int,
      explanation: json['explanation'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_number': questionNumber,
      'question': question,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'score': score,
      'explanation': explanation,
      'topic': topic,
      'difficulty': difficulty,
    };
  }
}