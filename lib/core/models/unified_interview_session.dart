import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';

class UnifiedInterviewSession extends Equatable {
  final String sessionId;
  final String userId;
  final String jobRole;
  final String interviewType; // 'mcq' or 'voice'
  final String difficulty;
  final String category;
  final int totalQuestions;
  final int? timePerQuestion;
  final bool isCompleted;
  final bool? passed;
  final double? score;
  final double? percentage;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? duration; // in seconds

  const UnifiedInterviewSession({
    required this.sessionId,
    required this.userId,
    required this.jobRole,
    required this.interviewType,
    required this.difficulty,
    required this.category,
    required this.totalQuestions,
    this.timePerQuestion = 60,
    this.isCompleted = false,
    this.passed,
    this.score = 0.0,
    this.percentage = 0.0,
    required this.startedAt,
    this.completedAt,
    this.duration = 0,
  });

  factory UnifiedInterviewSession.fromAppwrite(Map<String, dynamic> document) {
    return UnifiedInterviewSession(
      sessionId: document['id'] ?? document['\$id'] ?? '',
      userId: document['userId'] ?? '',
      jobRole: document['jobRole'] ?? '',
      interviewType: document['interviewType'] ?? AppSecrets.interviewTypeMCQ,
      difficulty: document['difficulty'] ?? AppSecrets.difficultyBeginner,
      category: document['category'] ?? AppSecrets.categoryGeneral,
      totalQuestions: document['totalQuestions'] ?? 0,
      timePerQuestion: document['timePerQuestion'] ?? 60,
      isCompleted: document['isCompleted'] ?? false,
      passed: document['passed'],
      score: document['score']?.toDouble() ?? 0.0,
      percentage: document['percentage']?.toDouble() ?? 0.0,
      startedAt: DateTime.parse(document['startedAt']),
      completedAt:
          document['completedAt'] != null
              ? DateTime.parse(document['completedAt'])
              : null,
      duration: document['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toAppwrite() {
    return {
      'userId': userId,
      'jobRole': jobRole,
      'interviewType': interviewType,
      'difficulty': difficulty,
      'category': category,
      'totalQuestions': totalQuestions,
      'timePerQuestion': timePerQuestion ?? 60,
      'isCompleted': isCompleted,
      'passed': passed,
      'score': score ?? 0.0,
      'percentage': percentage ?? 0.0,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'duration': duration ?? 0,
    };
  }

  UnifiedInterviewSession copyWith({
    String? sessionId,
    String? userId,
    String? jobRole,
    String? interviewType,
    String? difficulty,
    String? category,
    int? totalQuestions,
    int? timePerQuestion,
    bool? isCompleted,
    bool? passed,
    double? score,
    double? percentage,
    DateTime? startedAt,
    DateTime? completedAt,
    int? duration,
  }) {
    return UnifiedInterviewSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      jobRole: jobRole ?? this.jobRole,
      interviewType: interviewType ?? this.interviewType,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      isCompleted: isCompleted ?? this.isCompleted,
      passed: passed ?? this.passed,
      score: score ?? this.score,
      percentage: percentage ?? this.percentage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
    sessionId,
    userId,
    jobRole,
    interviewType,
    difficulty,
    category,
    totalQuestions,
    timePerQuestion,
    isCompleted,
    passed,
    score,
    percentage,
    startedAt,
    completedAt,
    duration,
  ];
}
