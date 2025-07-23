import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../../../../core/entities/question.dart';
import '../repositories/interview_repository.dart';

class SubmitMcqAnswerUseCase {
  final InterviewRepository repository;

  SubmitMcqAnswerUseCase(this.repository);

  Future<Either<Failure, Question>> call(SubmitMcqAnswerParams params) async {
    return await repository.submitMcqAnswer(
      sessionId: params.sessionId,
      answer: params.answer,
      userId: params.userId,
      jobRole: params.jobRole,
    );
  }
}

class SubmitMcqAnswerParams {
  final String sessionId;
  final String answer;
  final String userId;
  final String jobRole;

  SubmitMcqAnswerParams({
    required this.sessionId,
    required this.answer,
    required this.userId,
    required this.jobRole,
  });
}
