import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/core/entities/evaluation_result.dart';
import 'package:mock_interview/features/mcqinterviews/domain/repositories/mcq_interview_repository.dart';

class SubmitAnswersUseCase
    implements UseCase<EvaluationResult, SubmitAnswersParams> {
  final InterviewRepository repository;

  SubmitAnswersUseCase(this.repository);

  @override
  Future<Either<Failure, EvaluationResult>> call(
    SubmitAnswersParams params,
  ) async {
    return await repository.submitAnswers(
      sessionId: params.sessionId,
      userId: params.userId,
      answers: params.answers,
      jobRole: params.jobRole,
      difficultyLevel: params.difficultyLevel,
      category: params.category,
    );
  }
}

class SubmitAnswersParams {
  final String sessionId;
  final String userId;
  final List<String> answers;
  final String jobRole;
  final String difficultyLevel;
  final String category;

  SubmitAnswersParams({
    required this.sessionId,
    required this.userId,
    required this.answers,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
  });
}
