import 'package:equatable/equatable.dart';
import 'package:mock_interview/features/voiceinterviews/data/models/voice_interview_evaluation_result.dart';

abstract class InterviewResultState extends Equatable {
  const InterviewResultState();

  @override
  List<Object?> get props => [];
}

class InterviewResultInitial extends InterviewResultState {}

class InterviewResultEvaluating extends InterviewResultState {}

class InterviewResultEvaluated extends InterviewResultState {
  final VoiceInterviewEvaluationResult evaluationResult;
  final bool shouldAnimateScore;

  const InterviewResultEvaluated({
    required this.evaluationResult,
    this.shouldAnimateScore = false,
  });

  InterviewResultEvaluated copyWith({
    VoiceInterviewEvaluationResult? evaluationResult,
    bool? shouldAnimateScore,
  }) {
    return InterviewResultEvaluated(
      evaluationResult: evaluationResult ?? this.evaluationResult,
      shouldAnimateScore: shouldAnimateScore ?? this.shouldAnimateScore,
    );
  }

  @override
  List<Object?> get props => [evaluationResult, shouldAnimateScore];
}

class InterviewResultError extends InterviewResultState {
  final String message;

  const InterviewResultError(this.message);

  @override
  List<Object> get props => [message];
}
