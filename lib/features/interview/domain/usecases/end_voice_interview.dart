import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../repositories/interview_repository.dart';

class EndVoiceInterviewUseCase {
  final InterviewRepository repository;

  EndVoiceInterviewUseCase(this.repository);

  Future<Either<Failure, void>> call(String sessionId) async {
    return await repository.endVoiceInterview(sessionId);
  }
}
