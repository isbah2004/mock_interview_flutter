import 'package:equatable/equatable.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';

abstract class VoiceInterviewEvent extends Equatable {
  const VoiceInterviewEvent();

  @override
  List<Object?> get props => [];
}

// Setup Events
class StartInterviewSetup extends VoiceInterviewEvent {
  final InterviewConfig config;

  const StartInterviewSetup(this.config);

  @override
  List<Object?> get props => [config];
}

// Interview Events
class InitializeInterview extends VoiceInterviewEvent {
  final InterviewConfig config;
  final String userId;


  const InitializeInterview({required this.config, required this.userId});

  @override
  List<Object?> get props => [config, userId];
}

class SendUserResponse extends VoiceInterviewEvent {
  final String response;

  const SendUserResponse(this.response);

  @override
  List<Object?> get props => [response];
}

class StartListening extends VoiceInterviewEvent {}

class StopListening extends VoiceInterviewEvent {}

class UpdateListeningText extends VoiceInterviewEvent {
  final String text;

  const UpdateListeningText(this.text);

  @override
  List<Object?> get props => [text];
}

class SpeakResponse extends VoiceInterviewEvent {
  final String response;

  const SpeakResponse(this.response);

  @override
  List<Object?> get props => [response];
}

class PauseSpeaking extends VoiceInterviewEvent {}

class ResumeSpeaking extends VoiceInterviewEvent {}

class StopSpeaking extends VoiceInterviewEvent {}

class CompleteInterview extends VoiceInterviewEvent {}

// Evaluation Events
class StartEvaluation extends VoiceInterviewEvent {
  final InterviewSession session;
  final InterviewConfig config;
  final String userId;

  const StartEvaluation({
    required this.session,
    required this.config,
    required this.userId,
  });

  @override
  List<Object?> get props => [session, config, userId];
}

class RetryEvaluation extends VoiceInterviewEvent {
  final InterviewSession session;
  final InterviewConfig config;
  final String userId;

  const RetryEvaluation({
    required this.session,
    required this.config,
    required this.userId,
  });

  @override
  List<Object?> get props => [session, config, userId];
}

class CompleteSpeaking extends VoiceInterviewEvent {}

class ResetInterviewState extends VoiceInterviewEvent {}

// TTS Control Events
class PlayTTS extends VoiceInterviewEvent {}

class PauseTTS extends VoiceInterviewEvent {}

class StopTTS extends VoiceInterviewEvent {}

class ReplayTTS extends VoiceInterviewEvent {}

// Additional Interview Events
class EndInterview extends VoiceInterviewEvent {}

class RetryCurrentQuestion extends VoiceInterviewEvent {}

class UpdateTranscriptText extends VoiceInterviewEvent {
  final String text;

  const UpdateTranscriptText(this.text);

  @override
  List<Object?> get props => [text];
}
