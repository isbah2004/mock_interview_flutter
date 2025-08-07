import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/evaluation_result.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/interviews/domain/repositories/interview_repository.dart';

class SubmitAnswers implements UseCase<EvaluationResult, SubmitAnswersParams> {
  final InterviewRepository interviewRepository;

  SubmitAnswers(this.interviewRepository);

  @override
  Future<Either<Failure, EvaluationResult>> call(SubmitAnswersParams params) async {
    return await interviewRepository.submitAnswers(
   sessionId: params.sessionId,
      userId: params.userId,
      answers: params.answers
    );
  }
  
}

class SubmitAnswersParams {
 final String sessionId, userId;
 final List<String> answers;

  SubmitAnswersParams({
    required this.sessionId,
    required this.userId,
    required this.answers,
  });
}