import 'package:equatable/equatable.dart';

// Events
abstract class McqInterviewEvent extends Equatable {
  const McqInterviewEvent();

  @override
  List<Object> get props => [];
}

class StartInterviewEvent extends McqInterviewEvent {
  final String userId;
  final String jobRole;
  final String difficultyLevel;
  final int numQuestions;
  final String category;

  const StartInterviewEvent({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
  });

  @override
  List<Object> get props => [
    userId,
    jobRole,
    difficultyLevel,
    numQuestions,
    category,
  ];
}

class LoadQuestionsEvent extends McqInterviewEvent {
  final String sessionId;

  const LoadQuestionsEvent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class SubmitAnswersEvent extends McqInterviewEvent {
  final String sessionId;
  final String userId;
  final List<String> answers;
  final String jobRole;
  final String difficultyLevel;
  final String category;

  const SubmitAnswersEvent({
    required this.sessionId,
    required this.userId,
    required this.answers,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
  });

  @override
  List<Object> get props => [
    sessionId,
    userId,
    answers,
    jobRole,
    difficultyLevel,
    category,
  ];
}

class CompleteInterviewEvent extends McqInterviewEvent {
  final String sessionId;
  final String userId;
  final int score;
  final int timeTaken;
  final int totalQuestions;
  final int correctAnswers;

  const CompleteInterviewEvent({
    required this.sessionId,
    required this.userId,
    required this.score,
    required this.timeTaken,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  List<Object> get props => [
    sessionId,
    userId,
    score,
    timeTaken,
    totalQuestions,
    correctAnswers,
  ];
}
