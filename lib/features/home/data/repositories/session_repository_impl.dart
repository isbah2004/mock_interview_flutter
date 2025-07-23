import 'package:fpdart/fpdart.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_data_source.dart';
import '../../../../core/errors/failures.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;

  SessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Session>>> getUserSessions(String userId) async {
    try {
      final sessions = await remoteDataSource.getUserSessions(userId);
      return Right(sessions);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get user sessions: $e'));
    }
  }

  @override
  Future<Either<Failure, Session>> createSession({
    required String userId,
    required String type,
    String? jobRole,
    String? difficulty,
    String? category,
  }) async {
    try {
      final session = await remoteDataSource.createSession(
        userId: userId,
        type: type,
        jobRole: jobRole,
        difficulty: difficulty,
        category: category,
      );
      return Right(session);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to create session: $e'));
    }
  }

  @override
  Future<Either<Failure, Session>> updateSession(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final session = await remoteDataSource.updateSession(sessionId, data);
      return Right(session);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to update session: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await remoteDataSource.deleteSession(sessionId);
      return const Right(null);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to delete session: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Session>>> getSessionsByType({
    required String userId,
    required String type,
  }) async {
    try {
      final sessions = await remoteDataSource.getSessionsByType(
        userId: userId,
        type: type,
      );
      return Right(sessions);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get sessions by type: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Session>>> getSessionsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final sessions = await remoteDataSource.getSessionsInDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(sessions);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get sessions in date range: $e'));
    }
  }
}
