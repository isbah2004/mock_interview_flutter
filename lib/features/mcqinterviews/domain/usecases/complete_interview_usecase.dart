import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/mcqinterviews/domain/repositories/mcq_interview_repository.dart';

class CompleteInterviewUseCase
    implements UseCase<Map<String, dynamic>, CompleteInterviewParams> {
  final InterviewRepository repository;

  CompleteInterviewUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    CompleteInterviewParams params,
  ) async {
    return await repository.completeInterview(
      sessionId: params.sessionId,
      userId: params.userId,
      score: params.score,
      timeTaken: params.timeTaken,
      totalQuestions: params.totalQuestions,
      correctAnswers: params.correctAnswers,
    );
  }
}

class CompleteInterviewParams {
  final String sessionId;
  final String userId;
  final int score;
  final int timeTaken;
  final int totalQuestions;
  final int correctAnswers;

  CompleteInterviewParams({
    required this.sessionId,
    required this.userId,
    required this.score,
    required this.timeTaken,
    required this.totalQuestions,
    required this.correctAnswers,
  });
}
