import 'package:mock_interview/core/entities/question.dart';
import 'package:mock_interview/core/entities/session_stats.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';

class SessionStatsModel extends SessionStats {
  const SessionStatsModel({
    required super.sessionId,
    required super.jobRole,
    required super.difficulty,
    required super.category,
    required super.totalQuestions,
    required super.completedQuestions,
    required super.isComplete,
    required super.scores,
    required super.averageScore,
    required super.createdAt,
    super.answers,
    super.questions,
    super.conversationHistory,
    super.completedAt,
  });

  factory SessionStatsModel.fromJson(Map<String, dynamic> json) {
    return SessionStatsModel(
      sessionId: json['session_id'],
      jobRole: json['job_role'],
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      totalQuestions: json['total_questions'],
      completedQuestions: json['completed_questions'],
      isComplete: json['is_complete'],
      scores: List<double>.from(json['scores'] ?? []),
      averageScore: (json['average_score'] ?? 0).toDouble(),
      createdAt: DateTime.now(), // You may want to parse from json if available
      answers:
          json['answers'] != null ? List<String>.from(json['answers']) : null,
      questions:
          json['questions'] != null
              ? (json['questions'] as List)
                  .map(
                    (q) => Question(
                      questionText: q['question'],
                      options:
                          q['options'] != null
                              ? List<String>.from(q['options'])
                              : null,
                    ),
                  )
                  .toList()
              : null,
      conversationHistory:
          json['conversation_history'] != null
              ? (json['conversation_history'] as List)
                  .map(
                    (q) => Question(
                      questionText: q['question_text'],
                      feedback: q['feedback'],
                      score: q['score']?.toDouble(),
                    ),
                  )
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'job_role': jobRole,
      'difficulty': difficulty.name,
      'category': category.name,
      'total_questions': totalQuestions,
      'completed_questions': completedQuestions,
      'is_complete': isComplete,
      'scores': scores,
      'average_score': averageScore,
      'created_at': createdAt.toIso8601String(),
      'answers': answers,
      'questions':
          questions
              ?.map((q) => {'question': q.questionText, 'options': q.options})
              .toList(),
      'conversation_history':
          conversationHistory
              ?.map(
                (q) => {
                  'question_text': q.questionText,
                  'feedback': q.feedback,
                  'score': q.score,
                },
              )
              .toList(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  SessionStats toEntity() {
    return SessionStats(
      sessionId: sessionId,
      jobRole: jobRole,
      difficulty: difficulty,
      category: category,
      totalQuestions: totalQuestions,
      completedQuestions: completedQuestions,
      isComplete: isComplete,
      scores: scores,
      averageScore: averageScore,
      createdAt: createdAt,
      answers: answers,
      questions: questions,
      conversationHistory: conversationHistory,
      completedAt: completedAt,
    );
  }
}
