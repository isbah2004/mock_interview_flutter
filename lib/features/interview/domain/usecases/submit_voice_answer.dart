import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../repositories/interview_repository.dart';

class SubmitVoiceAnswerUseCase {
  final InterviewRepository repository;

  SubmitVoiceAnswerUseCase(this.repository);

  Future<Either<Failure, void>> call(SubmitVoiceAnswerParams params) async {
    return await repository.submitVoiceAnswer(
      sessionId: params.sessionId,
      answer: params.answer,
      userId: params.userId,
      jobRole: params.jobRole,
    );
  }
}

class SubmitVoiceAnswerParams {
  final String sessionId;
  final String answer;
  final String userId;
  final String jobRole;

  SubmitVoiceAnswerParams({
    required this.sessionId,
    required this.answer,
    required this.userId,
    required this.jobRole,
  });
}
