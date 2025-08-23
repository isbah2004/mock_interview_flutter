import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/entities/performance_summary.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/question_model.dart';

class InterviewSession extends Equatable {
  final String sessionId;
  final String? userId;
  final String jobRole;
  final String difficulty;
  final String category;
  final int totalQuestions;
  final int? timePerQuestion;
  final double? score;
  final double? percentage;
  final bool? isCompleted;
  final bool? passed;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? duration;
  final PerformanceSummary? performanceSummary;
  final List<QuestionModel>? questions;

  const InterviewSession({
    required this.sessionId,
     this.questions,
     this.userId,
    required this.jobRole,
    required this.difficulty,
    required this.category,
    required this.totalQuestions,
     this.timePerQuestion,
    this.score,
    this.percentage,
     this.isCompleted,
    this.passed,
     this.startedAt,
    this.completedAt,
    this.duration,
    this.performanceSummary,
  });

  @override
  List<Object?> get props => [
    sessionId,
    userId,
    jobRole,
    difficulty,
    category,
    totalQuestions,
    timePerQuestion,
    questions,
    score,
    percentage,
    isCompleted,
    passed,
    startedAt,
    completedAt,
    duration,
    performanceSummary,
  ];

  InterviewSession copyWith({
    String? sessionId,
    String? userId,
    String? jobRole,
    String? difficulty,
    String? category,
    int? totalQuestions,
    int? timePerQuestion,
    double? score,
    double? percentage,
    bool? isCompleted,
    bool? passed,
    DateTime? startedAt,
    DateTime? completedAt,
    int? duration,
    PerformanceSummary? performanceSummary,
    List<QuestionModel>? questions,
  }) {
    return InterviewSession(
      questions: questions ?? this.questions,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      jobRole: jobRole ?? this.jobRole,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      score: score ?? this.score,
      percentage: percentage ?? this.percentage,
      isCompleted: isCompleted ?? this.isCompleted,
      passed: passed ?? this.passed,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
      performanceSummary: performanceSummary ?? this.performanceSummary,
    );
  }

  bool get isPassed => passed ?? false;
  bool get hasPerformanceData => performanceSummary != null;
  
  Duration? get sessionDuration {
    if (duration != null) {
      return Duration(seconds: duration!);
    }
    if (completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }

  double get scorePercentage => percentage ?? 0.0;
}