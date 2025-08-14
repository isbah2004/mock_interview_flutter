import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/interview_session_model.dart';
import 'package:mock_interview/features/mcqinterviews/domain/repositories/mcq_interview_repository.dart';

class StartInterviewUseCase
    implements UseCase<InterviewSessionModel, StartInterviewParams> {
  final InterviewRepository repository;

  StartInterviewUseCase(this.repository);

  @override
  Future<Either<Failure, InterviewSessionModel>> call(
    StartInterviewParams params,
  ) async {
    return await repository.startInterview(
      userId: params.userId,
      jobRole: params.jobRole,
      difficultyLevel: params.difficultyLevel,
      numQuestions: params.numQuestions,
      category: params.category,
    );
  }
}

class StartInterviewParams {
  final String userId;
  final String jobRole;
  final String difficultyLevel;
  final int numQuestions;
  final String category;

  StartInterviewParams({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
  });
}
