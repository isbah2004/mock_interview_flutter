import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/mcqinterviews/domain/repositories/mcq_interview_repository.dart';

class GetSessionStats implements UseCase<Map<String,dynamic>,String> {
  final InterviewRepository interviewRepository;

  GetSessionStats(this.interviewRepository);

  @override
  Future<Either<Failure, Map<String,dynamic>>> call(String sessionId) async {
    return await interviewRepository.getSessionStats(sessionId);
  }
  
}