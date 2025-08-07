
import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/entities/evaluation_result.dart';
import 'package:mock_interview/core/entities/interview.dart';


abstract class InterviewState extends Equatable {
  const InterviewState();

  @override
  List<Object?> get props => [];
}

class InterviewInitial extends InterviewState {}

class InterviewLoading extends InterviewState {}

class InterviewStarted extends InterviewState {
  final Interview interview;
  final List<String> userAnswers;
  final int currentQuestionIndex;

  const InterviewStarted({
    required this.interview,
    required this.userAnswers,
    required this.currentQuestionIndex,
  });

  @override
  List<Object> get props => [interview, userAnswers, currentQuestionIndex];

  InterviewStarted copyWith({
    Interview? interview,
    List<String>? userAnswers,
    int? currentQuestionIndex,
  }) {
    return InterviewStarted(
      interview: interview ?? this.interview,
      userAnswers: userAnswers ?? this.userAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }
}

class InterviewCompleted extends InterviewState {
  final EvaluationResult evaluationResult;

  const InterviewCompleted({required this.evaluationResult});

  @override
  List<Object> get props => [evaluationResult];
}

class InterviewError extends InterviewState {
  final String message;

  const InterviewError({required this.message});

  @override
  List<Object> get props => [message];
}