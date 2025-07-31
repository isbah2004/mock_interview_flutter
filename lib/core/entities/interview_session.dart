import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/interview_type.dart';
import 'package:mock_interview/core/enums/question_category.dart';

class InterviewSession extends Equatable {
  final String sessionId;
  final String userId;
  final String jobRole;
  final InterviewType interviewType;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;
  final int? numQuestions; // Only for MCQ
  final DateTime createdAt;
  final bool isComplete;

  const InterviewSession({
    required this.sessionId,
    required this.userId,
    required this.jobRole,
    required this.interviewType,
    required this.difficultyLevel,
    required this.category,
    this.numQuestions,
    required this.createdAt,
    this.isComplete = false, 
  });

  @override
  List<Object?> get props => [
    sessionId,
    userId,
    jobRole,
    interviewType,
    difficultyLevel,
    category,
    numQuestions,
    createdAt,
    isComplete,
  ];
}