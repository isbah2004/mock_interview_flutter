import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../../../../core/entities/question.dart';
import '../../../../core/entities/interview_session.dart';
import '../repositories/interview_repository.dart';

class StartVoiceInterviewUseCase {
  final InterviewRepository repository;

  StartVoiceInterviewUseCase(this.repository);

  Stream<Either<Failure, Question>> call(StartVoiceInterviewParams params) {
    return repository.startVoiceInterview(
      userId: params.userId,
      jobRole: params.jobRole,
      difficultyLevel: params.difficultyLevel,
      category: params.category,
    );
  }
}

class StartVoiceInterviewParams {
  final String userId;
  final String jobRole;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;

  StartVoiceInterviewParams({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
  });
}
