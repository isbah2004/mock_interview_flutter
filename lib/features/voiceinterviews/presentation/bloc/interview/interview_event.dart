import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';

// Events
abstract class InterviewEvent {}

class InitializeInterview extends InterviewEvent {
  final InterviewConfig config;
  InitializeInterview(this.config);
}

class SendUserResponse extends InterviewEvent {
  final String response;
  SendUserResponse(this.response);
}

class StartListening extends InterviewEvent {}

class StopListening extends InterviewEvent {}

class UpdateListeningText extends InterviewEvent {
  final String text;
  UpdateListeningText(this.text);
}

class SpeakResponse extends InterviewEvent {
  final String text;
  SpeakResponse(this.text);
}

class CompleteSpeaking extends InterviewEvent {}
