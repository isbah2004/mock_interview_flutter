// lib/features/interview/domain/entities/interview.dart
import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';
import 'question.dart';

class Interview extends Equatable {
  final String sessionId;
  final String jobRole;
  final DifficultyLevel difficulty;
  final QuestionCategory category;
  final int totalQuestions;
  final List<Question> questions;
  final String message;
  final DateTime sessionCreatedAt;

  const Interview({
    required this.sessionId,
    required this.jobRole,
    required this.difficulty,
    required this.category,
    required this.totalQuestions,
    required this.questions,
    required this.message,
    required this.sessionCreatedAt,
  });

  @override
  List<Object> get props => [
    sessionId,
    jobRole,
    difficulty,
    category,
    totalQuestions,
    questions,
    message,
    sessionCreatedAt,
  ];
}
