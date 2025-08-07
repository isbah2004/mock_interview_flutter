import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/interviews/domain/repositories/interview_repository.dart';

class DeleteSession implements UseCase<void, String> {
  final InterviewRepository interviewRepository;

  DeleteSession(this.interviewRepository);

  @override
  Future<Either<Failure, void>> call(String sessionId) async {
    return await interviewRepository.deleteSession(sessionId);
  }
  
}