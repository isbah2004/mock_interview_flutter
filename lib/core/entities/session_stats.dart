import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/entities/interview_session.dart';
import 'package:mock_interview/core/entities/question.dart';

class SessionStats extends Equatable {
  final String sessionId;
  final String jobRole;
  final DifficultyLevel difficulty;
  final QuestionCategory category;
  final int totalQuestions;
  final int completedQuestions;
  final bool isComplete;
  final List<double> scores;
  final double averageScore;
  final List<String>? answers; // User's answers (for MCQ)
  final List<Question>? questions; // Questions with correct answers (for MCQ)
  final List<Question>? conversationHistory; // For voice interviews
  final DateTime createdAt;
  final DateTime? completedAt;

  const SessionStats({
    required this.sessionId,
    required this.jobRole,
    required this.difficulty,
    required this.category,
    required this.totalQuestions,
    required this.completedQuestions,
    required this.isComplete,
    required this.scores,
    required this.averageScore,
    required this.createdAt,
    this.answers,
    this.questions,
    this.conversationHistory,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
    sessionId,
    jobRole,
    difficulty,
    category,
    totalQuestions,
    completedQuestions,
    isComplete,
    scores,
    averageScore,
    answers,
    questions,
    conversationHistory,
    createdAt,
    completedAt,
  ];

  // Helper methods
  double get completionPercentage =>
      totalQuestions > 0 ? (completedQuestions / totalQuestions) * 100 : 0;

  String get performanceLevel {
    if (averageScore >= 80) return 'Excellent';
    if (averageScore >= 60) return 'Good';
    if (averageScore >= 40) return 'Average';
    return 'Needs Improvement';
  }

  Duration? get sessionDuration =>
      completedAt != null ? completedAt!.difference(createdAt) : null;
}