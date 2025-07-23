import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../../../../core/entities/interview_session.dart';
import '../repositories/interview_repository.dart';

class GetUserSessionsUseCase {
  final InterviewRepository repository;

  GetUserSessionsUseCase(this.repository);

  Future<Either<Failure, List<InterviewSession>>> call(String userId) async {
    return await repository.getUserSessions(userId);
  }
}
