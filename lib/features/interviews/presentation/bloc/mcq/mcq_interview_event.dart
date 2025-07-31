import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';

abstract class McqInterviewEvent extends Equatable {
  const McqInterviewEvent();

  @override
  List<Object?> get props => [];
}

class StartMcqInterviewEvent extends McqInterviewEvent {
  final String userId;
  final String jobRole;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;
  final int numQuestions;

  const StartMcqInterviewEvent({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
    required this.numQuestions,
  });

  @override
  List<Object?> get props => [
    userId,
    jobRole,
    difficultyLevel,
    category,
    numQuestions,
  ];
}

class SubmitMcqAnswerEvent extends McqInterviewEvent {
  final String sessionId;
  final String answer;
  final String userId;
  final String jobRole;

  const SubmitMcqAnswerEvent({
    required this.sessionId,
    required this.answer,
    required this.userId,
    required this.jobRole,
  });

  @override
  List<Object?> get props => [sessionId, answer, userId, jobRole];
}

class ProceedToNextQuestionEvent extends McqInterviewEvent {
  const ProceedToNextQuestionEvent();
}

class CompleteInterviewEvent extends McqInterviewEvent {
  const CompleteInterviewEvent();
}

class ResetInterviewEvent extends McqInterviewEvent {
  const ResetInterviewEvent();
}
