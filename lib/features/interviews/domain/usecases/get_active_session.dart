import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/interviews/domain/repositories/interview_repository.dart';

class GetActiveSessions implements UseCase<Map<String,dynamic>, NoParams> {
  final InterviewRepository interviewRepository;

  GetActiveSessions(this.interviewRepository);

  @override
  Future<Either<Failure, Map<String,dynamic>>> call(NoParams params) async {
    return await interviewRepository.getActiveSessions();
  }
  
}