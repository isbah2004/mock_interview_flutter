
import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/entities/question.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';

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
  final List<String>? answers; // MCQ
  final List<Question>? questions; // MCQ
  final List<Question>? conversationHistory; // Voice
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
}