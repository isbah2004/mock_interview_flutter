import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';

abstract class InterviewEvent extends Equatable {
  const InterviewEvent();

  @override
  List<Object> get props => [];
}

class StartInterviewEvent extends InterviewEvent {
  final String userId;
  final String jobRole;
  final DifficultyLevel difficultyLevel;
  final int numQuestions;
  final QuestionCategory category;

  const StartInterviewEvent({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
  });

  @override
  List<Object> get props => [userId, jobRole, difficultyLevel, numQuestions, category];
}

class SelectAnswerEvent extends InterviewEvent {
  final int questionIndex;
  final String answer;

  const SelectAnswerEvent({
    required this.questionIndex,
    required this.answer,
  });

  @override
  List<Object> get props => [questionIndex, answer];
}

class NextQuestionEvent extends InterviewEvent {}

class PreviousQuestionEvent extends InterviewEvent {}

class GoToQuestionEvent extends InterviewEvent {
  final int questionIndex;

  const GoToQuestionEvent(this.questionIndex);

  @override
  List<Object> get props => [questionIndex];
}

class SubmitInterviewEvent extends InterviewEvent {
  final String sessionId;
  final String userId;
  final List<String> answers;

  const SubmitInterviewEvent({
    required this.sessionId,
    required this.userId,
    required this.answers,
  });

  @override
  List<Object> get props => [sessionId, userId, answers];
}

class ResetInterviewEvent extends InterviewEvent {}