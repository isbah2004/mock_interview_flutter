import 'package:fpdart/fpdart.dart';
import '../entities/session.dart';
import '../repositories/session_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetUserSessions implements UseCase<List<Session>, String> {
  final SessionRepository repository;

  GetUserSessions(this.repository);

  @override
  Future<Either<Failure, List<Session>>> call(String userId) async {
    return await repository.getUserSessions(userId);
  }
}
