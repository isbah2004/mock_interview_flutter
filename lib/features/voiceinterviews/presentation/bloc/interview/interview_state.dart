import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';

// States
abstract class InterviewState {}

class InterviewInitial extends InterviewState {}

class InterviewLoading extends InterviewState {}

class InterviewInProgress extends InterviewState {
  final InterviewSession session;
  InterviewInProgress(this.session);
}

class InterviewError extends InterviewState {
  final String message;
  InterviewError(this.message);
}
