import 'package:equatable/equatable.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/question_model.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/evaluation_result_model.dart';

abstract class McqInterviewState extends Equatable {
  const McqInterviewState();

  @override
  List<Object?> get props => [];
}

class InterviewInitial extends McqInterviewState {}

class InterviewLoading extends McqInterviewState {}

class InterviewSetupState extends McqInterviewState {}

class InterviewStarted extends McqInterviewState {
  final String sessionId;
  final List<QuestionModel> questions;

  const InterviewStarted({required this.sessionId, required this.questions});

  @override
  List<Object> get props => [sessionId, questions];
}

class InterviewInProgress extends McqInterviewState {
  final String sessionId;
  final List<dynamic> questions;
  final int currentQuestionIndex;
  final List<String> answers;

  const InterviewInProgress({
    required this.sessionId,
    required this.questions,
    required this.currentQuestionIndex,
    required this.answers,
  });

  @override
  List<Object> get props => [
    sessionId,
    questions,
    currentQuestionIndex,
    answers,
  ];
}

class InterviewCompleted extends McqInterviewState {
  final EvaluationResultModel evaluationResult;

  const InterviewCompleted({required this.evaluationResult});

  @override
  List<Object> get props => [evaluationResult];
}

class InterviewError extends McqInterviewState {
  final String message;

  const InterviewError(this.message);

  @override
  List<Object> get props => [message];
}
