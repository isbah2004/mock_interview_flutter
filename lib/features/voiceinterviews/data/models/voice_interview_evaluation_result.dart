import 'package:mock_interview/core/entities/evaluation_result.dart';

class VoiceInterviewEvaluationResult extends EvaluationResult {
  final String feedback;
  final List<String> aiCorrectAnswers;
  final double communicationScore;
  final double contentScore;
  final double overallScore;

  const VoiceInterviewEvaluationResult({
    required super.sessionId,
    required super.totalQuestions,
    required super.results,
    required super.finalScore,
    required super.percentage,
    required super.passed,
    required super.sessionComplete,
    required super.completedAt,
    required this.feedback,
    required this.aiCorrectAnswers,
    required this.communicationScore,
    required this.contentScore,
    required this.overallScore,
  });

  factory VoiceInterviewEvaluationResult.fromJson(Map<String, dynamic> json) {
    return VoiceInterviewEvaluationResult(
      sessionId: (json['sessionId'] ?? json['session_id'] ?? '') as String,
      totalQuestions: (json['totalQuestions'] ?? json['total_questions'] ?? 0) as int,
      results: (json['results'] as List?)
              ?.map((r) => VoiceQuestionResult.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      finalScore: _parseDouble(json['finalScore'] ?? json['final_score'] ?? 0),
      percentage: _parseDouble(json['percentage'] ?? 0),
      passed: (json['passed'] ?? false) as bool,
      sessionComplete: (json['sessionComplete'] ?? json['session_complete'] ?? false) as bool,
      completedAt: _parseDateTime(json['completedAt'] ?? json['completed_at']),
      feedback: (json['feedback'] ?? '') as String,
      aiCorrectAnswers: _parseStringList(json['aiCorrectAnswers'] ?? json['ai_correct_answers']),
      communicationScore: _parseDouble(json['communicationScore'] ?? json['communication_score'] ?? 0),
      contentScore: _parseDouble(json['contentScore'] ?? json['content_score'] ?? 0),
      overallScore: _parseDouble(json['overallScore'] ?? json['overall_score'] ?? 0),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      // Try ISO format first
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (value is int) {
      // Assume it's milliseconds since epoch
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        // Maybe it's seconds since epoch
        try {
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        } catch (e) {
          return DateTime.now();
        }
      }
    }
    return DateTime.now();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item?.toString() ?? '').toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'total_questions': totalQuestions,
      'results': results.map((r) => (r as VoiceQuestionResult).toJson()).toList(),
      'final_score': finalScore,
      'percentage': percentage,
      'passed': passed,
      'session_complete': sessionComplete,
      'completed_at': completedAt.millisecondsSinceEpoch ~/ 1000,
      'feedback': feedback,
      'ai_correct_answers': aiCorrectAnswers,
      'communication_score': communicationScore,
      'content_score': contentScore,
      'overall_score': overallScore,
    };
  }
}

class VoiceQuestionResult extends QuestionResult {
  const VoiceQuestionResult({
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

  factory VoiceQuestionResult.fromJson(Map<String, dynamic> json) {
    return VoiceQuestionResult(
      questionId: (json['question_id'] ?? json['questionId'] ?? '') as String,
      questionNumber: (json['question_number'] ?? json['questionNumber'] ?? 0) as int,
      question: (json['question'] ?? '') as String,
      userAnswer: (json['user_answer'] ?? json['userAnswer'] ?? '') as String,
      correctAnswer: (json['correct_answer'] ?? json['correctAnswer'] ?? '') as String,
      isCorrect: (json['is_correct'] ?? json['isCorrect'] ?? false) as bool,
      score: (json['score'] ?? 0) as int,
      explanation: (json['explanation'] ?? '') as String,
      topic: (json['topic'] ?? '') as String,
      difficulty: (json['difficulty'] ?? '') as String,
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