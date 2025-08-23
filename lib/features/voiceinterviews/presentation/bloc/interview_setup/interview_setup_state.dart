import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';

// States
abstract class InterviewSetupState {}

class InterviewSetupInitial extends InterviewSetupState {}

class InterviewSetupConfiguring extends InterviewSetupState {
  final InterviewConfig config;
  final bool isValid;

  InterviewSetupConfiguring(this.config, this.isValid);
}

class InterviewSetupReady extends InterviewSetupState {
  final InterviewConfig config;
  InterviewSetupReady(this.config);
}
