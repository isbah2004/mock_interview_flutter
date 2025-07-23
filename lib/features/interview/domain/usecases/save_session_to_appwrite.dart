import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../../../../core/entities/interview_session.dart';
import '../repositories/interview_repository.dart';

class SaveSessionToAppwriteUseCase {
  final InterviewRepository repository;

  SaveSessionToAppwriteUseCase(this.repository);

  Future<Either<Failure, void>> call(InterviewSession session) async {
    return await repository.saveSessionToAppwrite(session);
  }
}
