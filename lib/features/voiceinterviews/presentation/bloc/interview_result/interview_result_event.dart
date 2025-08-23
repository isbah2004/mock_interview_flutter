import 'package:equatable/equatable.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';

abstract class InterviewResultEvent extends Equatable {
  const InterviewResultEvent();

  @override
  List<Object> get props => [];
}

class StartEvaluation extends InterviewResultEvent {
  final InterviewSession session;
  final InterviewConfig config;

  const StartEvaluation({required this.session, required this.config});

  @override
  List<Object> get props => [session, config];
}

class RetryEvaluation extends InterviewResultEvent {
  final InterviewSession session;
  final InterviewConfig config;

  const RetryEvaluation({required this.session, required this.config});

  @override
  List<Object> get props => [session, config];
}

class StartScoreAnimation extends InterviewResultEvent {}
