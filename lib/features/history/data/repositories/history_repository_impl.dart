import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/features/history/data/datasources/history_remote_data_source.dart';
import 'package:mock_interview/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UnifiedInterviewSession>>> getHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final result = await remoteDataSource.getUserHistory(
        userId: userId,
        limit: limit,
      );
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure('Unexpected error fetching history: $e'));
    }
  }
}
