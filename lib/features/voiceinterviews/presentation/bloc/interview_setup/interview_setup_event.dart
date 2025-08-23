import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';

// Events
abstract class InterviewSetupEvent {}

class UpdateJobRole extends InterviewSetupEvent {
  final String jobRole;
  UpdateJobRole(this.jobRole);
}

class UpdateCategory extends InterviewSetupEvent {
  final InterviewCategory category;
  UpdateCategory(this.category);
}

class UpdateDifficulty extends InterviewSetupEvent {
  final InterviewDifficulty difficulty;
  UpdateDifficulty(this.difficulty);
}

class UpdateQuestionCount extends InterviewSetupEvent {
  final int count;
  UpdateQuestionCount(this.count);
}

class StartInterview extends InterviewSetupEvent {}
