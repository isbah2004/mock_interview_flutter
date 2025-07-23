import 'package:equatable/equatable.dart';
import '../../../../../core/entities/interview_session.dart';

abstract class VoiceInterviewEvent extends Equatable {
  const VoiceInterviewEvent();

  @override
  List<Object?> get props => [];
}

class StartVoiceInterviewEvent extends VoiceInterviewEvent {
  final String userId;
  final String jobRole;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;

  const StartVoiceInterviewEvent({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
  });

  @override
  List<Object?> get props => [userId, jobRole, difficultyLevel, category];
}

class SubmitVoiceAnswerEvent extends VoiceInterviewEvent {
  final String sessionId;
  final String answer;
  final String userId;
  final String jobRole;

  const SubmitVoiceAnswerEvent({
    required this.sessionId,
    required this.answer,
    required this.userId,
    required this.jobRole,
  });

  @override
  List<Object?> get props => [sessionId, answer, userId, jobRole];
}

class EndVoiceInterviewEvent extends VoiceInterviewEvent {
  final String sessionId;

  const EndVoiceInterviewEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class StartRecordingEvent extends VoiceInterviewEvent {
  const StartRecordingEvent();
}

class StopRecordingEvent extends VoiceInterviewEvent {
  const StopRecordingEvent();
}

class ResetVoiceInterviewEvent extends VoiceInterviewEvent {
  const ResetVoiceInterviewEvent();
}

class SkipQuestionEvent extends VoiceInterviewEvent {
  final String sessionId;

  const SkipQuestionEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
