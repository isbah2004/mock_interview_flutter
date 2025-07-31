import 'package:fpdart/fpdart.dart';
import '../entities/session.dart';
import '../../../../core/errors/failures.dart';

abstract class SessionRepository {
  Future<Either<Failure, List<Session>>> getUserSessions(String userId);
  Future<Either<Failure, Session>> createSession({
    required String userId,
    required String type,
    String? jobRole,
    String? difficulty,
    String? category,
  });
  Future<Either<Failure, Session>> updateSession(
    String sessionId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteSession(String sessionId);
  Future<Either<Failure, List<Session>>> getSessionsByType({
    required String userId,
    required String type,
  });
  Future<Either<Failure, List<Session>>> getSessionsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
