import 'package:mock_interview/core/entities/interview_session.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/question_model.dart';

class InterviewSessionModel extends InterviewSession {
  const InterviewSessionModel({
    required super.sessionId,
    super.userId,
    required super.jobRole,
    required super.difficulty,
    required super.category,
    required super.totalQuestions,
     super.timePerQuestion,
     super.questions,
    super.score,
    super.percentage,
     super.isCompleted,
    super.passed,
     super.startedAt,
    super.completedAt,
    super.duration,
    super.performanceSummary,
  });

  factory InterviewSessionModel.fromEntity(InterviewSession entity) {
    return InterviewSessionModel(
      questions: entity.questions,
      sessionId: entity.sessionId,
      userId: entity.userId,
      jobRole: entity.jobRole,
      difficulty: entity.difficulty,
      category: entity.category,
      totalQuestions: entity.totalQuestions,
      timePerQuestion: entity.timePerQuestion,
      score: entity.score,
      percentage: entity.percentage,
      isCompleted: entity.isCompleted,
      passed: entity.passed,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      duration: entity.duration,
      performanceSummary: entity.performanceSummary,
    );
  }

  InterviewSession toEntity() {
    return InterviewSession(
      questions: questions,
      sessionId: sessionId,
      userId: userId,
      jobRole: jobRole,
      difficulty: difficulty,
      category: category,
      totalQuestions: totalQuestions,
      timePerQuestion: timePerQuestion,
      score: score,
      percentage: percentage,
      isCompleted: isCompleted,
      passed: passed,
      startedAt: startedAt,
      completedAt: completedAt,
      duration: duration,
      performanceSummary: performanceSummary,
    );
  }

  factory InterviewSessionModel.fromAIResponse(Map<String, dynamic> json) {
    return InterviewSessionModel(
      sessionId: json['session_id'] ?? '',
      
      jobRole: json['job_role'] ?? '',
      difficulty: json['difficulty'],
      category: json['category'],
      totalQuestions: json['total_questions'] ?? 0,
      questions:
          json['questions'] != null
              ? (json['questions'] as List)
                  .map((q) => QuestionModel.fromAIResponse(q))
                  .toList()
              : [],

    );
  }

  factory InterviewSessionModel.fromAppwrite(Map<String, dynamic> document) {
    return InterviewSessionModel(
 
      sessionId: document['\$id'] ?? '',
      userId: document['userId'] ?? '',
      jobRole: document['jobRole'] ?? '',
      difficulty: document['difficulty'],
      category: document['category'],
      totalQuestions: document['totalQuestions'] ?? 0,
      timePerQuestion: document['timePerQuestion'] ?? 60,
      score: document['score']?.toDouble(),
      percentage: document['percentage']?.toDouble(),
      isCompleted: document['isCompleted'] ?? false,
      passed: document['passed'],
      startedAt: DateTime.parse(document['startedAt']),
      completedAt:
          document['completedAt'] != null
              ? DateTime.parse(document['completedAt'])
              : null,
      duration: document['duration'],
      performanceSummary: null,
    );
  }

  Map<String, dynamic> toAppwrite( id) {
    return {
      'userId': id,
      'sessionId': sessionId,
      'jobRole': jobRole,
      'difficulty': difficulty,
      'category': category,
      'totalQuestions': totalQuestions,
      'timePerQuestion': timePerQuestion,
      'score': score ?? 0.0,
      'percentage': percentage ?? 0.0,
      'isCompleted': isCompleted,
      'passed': passed ?? false,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'duration': duration ?? 0,
    };
  }
}
