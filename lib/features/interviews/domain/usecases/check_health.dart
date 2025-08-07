import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/interviews/domain/repositories/interview_repository.dart';

class CheckHealth implements UseCase<bool, NoParams> {
  final InterviewRepository repository;

  CheckHealth(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkHealth();
  }
  
}